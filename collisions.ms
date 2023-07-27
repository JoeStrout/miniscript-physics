import "vector"
import "math"

xAxis = vector.Vec2(1, 0)
yAxis = vector.Vec2(0, 1)

debugDraw = false

if debugDraw then
    display(3).mode = displayMode.pixel

    debugDrawDisplay = display(3)
    debugDrawDisplay.clear
end if

fillCircle = function(v, r)
    debugDrawDisplay.fillEllipse(v.x - r, v.y - r, r * 2, r * 2)
end function

degsToRads = function (d)
    return (d / 360) * 2 * pi
end function

getPoints = function(body)
    // todo: handle cases for non-rectangular objects

    hw = body.localBounds.width * body.scale / 2
    hh = body.localBounds.height * body.scale / 2
    pos = vector.Vec2(body.x, body.y)
    rot = degsToRads(body.rotation)

    topLeft     = vector.Vec2(-hw, hh).rotatedBy(rot).add(pos)
    topRight    = vector.Vec2(hw , hh).rotatedBy(rot).add(pos)
    bottomRight = vector.Vec2(hw, -hh).rotatedBy(rot).add(pos)
    bottomLeft  = vector.Vec2(-hw, -hh).rotatedBy(rot).add(pos)

    points = [topLeft, topRight, bottomRight, bottomLeft]

    if debugDraw then
        for p in points
            fillCircle(p, 3)
        end for
    end if

    return points
end function

projectPoints = function(points, axis)
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

findOverlapPoints = function(points1, points2)
    normal = null
    minDepth = 0

    for i in range(points1.len - 1)
        p1 = points1[i]
        p2 = points1[(i + 1) % points1.len]

        edge = p2.sub(p1)
        axis = vector.Vec2(-edge.y, edge.x).normalized()

        proj1 = projectPoints(points1, axis)
        proj2 = projectPoints(points2, axis)

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
            axis = axis.multiply(-1)
        end if

        if normal == null or depth < minDepth then
            normal = axis
            minDepth = depth
        end if
    end for

    return { "normal": normal, "depth": minDepth }
end function

findOverlap = function(b1, b2)
    points1 = getPoints(b1)
    points2 = getPoints(b2)

    overlap1 = findOverlapPoints(points1, points2)
    if not overlap1 then
        return false
    end if
    
    overlap2 = findOverlapPoints(points2, points1)
    if not overlap2 then
        return false
    end if

    if overlap2.depth > overlap1.depth then
        return overlap1
    end if

    // invert direction because overlap2 tests b2 against b1, instead of b1 against b2
    overlap2.normal = overlap2.normal.multiply(-1)

    return overlap2
end function
