import "mathUtil"

import "vector"
import "debugDraw"

getRectangleVertices = function(body)
    hw = body.shape.width / 2
    hh = body.shape.height / 2

    pos = body.pos
    rot = mathUtil.degToRad(body.rotation)

    return [
        [-hw, hh].rotatedBy(rot).plus(pos),
        [hw , hh].rotatedBy(rot).plus(pos),
        [hw, -hh].rotatedBy(rot).plus(pos),
        [-hw, -hh].rotatedBy(rot).plus(pos),
    ]
end function

getRectangleAxes = function(body)
    rot = mathUtil.degToRad(body.rotation)

    return [
        [1, 0].rotatedBy(rot),
        [0, 1].rotatedBy(rot),
    ]
end function

projectPoints = function(axis, points)
    min = 0
    hasMin = false
    max = 0
    hasMax = false

    for p in points
        proj = p.dot(axis)

        if not hasMin or proj < min then
            hasMin = true
            min = proj
        end if
        if not hasMax or proj > max then
            hasMax = true
            max = proj
        end if
    end for

    return { "min": min, "max": max }
end function

findOverlapPoints = function(axes, points1, points2)
    normal = null
    minDepth = 0

    for axis in axes
        proj1 = projectPoints(axis, points1)
        proj2 = projectPoints(axis, points2)

        if proj1.min >= proj2.max or proj2.min >= proj1.max then
            // one axis doesn't have overlap, the objects don't collide
            return false
        end if

        depth1 = proj2.max - proj1.min
        depth2 = proj1.max - proj2.min

        if depth1 > depth2 then
            depth = depth2
        else
            depth = depth1
            axis = axis.times(-1)
        end if

        if normal == null or depth < minDepth then
            normal = axis
            minDepth = depth
        end if
    end for

    return { "normal": normal, "depth": minDepth }
end function

testRectangles = function(b1, b2)
    pos1 = b1.pos
    pos2 = b2.pos

    axes = getRectangleAxes(b1) +
           getRectangleAxes(b2)

    points1 = getRectangleVertices(b1)
    points2 = getRectangleVertices(b2)

    if debugDraw.enabled then
        debugDraw.points points1
        debugDraw.points points2

        debugDraw.drawDisplay.line b1.x, b1.y, b2.x, b2.y, color.gray

        debugDraw.axes b1.pos, getRectangleAxes(b1)
        debugDraw.axes b2.pos, getRectangleAxes(b2)
    end if

    overlap1 = findOverlapPoints(axes, points1, points2)
    if not overlap1 then
        return false
    end if

    overlap2 = findOverlapPoints(axes, points2, points1)
    if not overlap2 then
        return false
    end if

    if overlap2.depth > overlap1.depth then
        overlap = overlap1
    else
        overlap = overlap2

        // invert direction because overlap2 tests b2 against b1, instead of b1 against b2
        overlap.normal = overlap2.normal.times(-1)
    end if

    if debugDraw.enabled then
        dir = overlap.normal.times(-overlap.depth)
        debugDraw.drawDisplay.line b1.x, b1.y, b1.x + dir.x, b1.y + dir.y, color.red, 4
    end if

    return overlap
end function
