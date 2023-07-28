import "vector"

xAxis = [1, 0]
yAxis = [0, 1]

debugDraw = true

if debugDraw then
    display(2).mode = displayMode.pixel

    debugDrawDisplay = display(2)
    debugDrawDisplay.clear
end if

debugDrawAxes = function(p, axes, length=500)
    for axis in axes
        edge = axis.normal
        debugDrawDisplay.line p.x, p.y, p.x + edge.x * length, p.y + edge.y * length
    end for
end function

degsToRads = function (d)
    return (d / 360) * 2 * pi
end function

findOverlapPoints = function(axes, body1, body2)
    normal = null
    minDepth = 0

    for axis in axes
        proj1 = body1.shape.projectOn(axis, body1.pos, degsToRads(body1.rotation))
        proj2 = body2.shape.projectOn(axis, body2.pos, degsToRads(body2.rotation))

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

findOverlap = function(b1, b2)
    pos1 = b1.pos
    pos2 = b2.pos

    //TODO: Remove duplicates
    axes = b1.shape.axes(degsToRads(b1.rotation), b2) +
           b2.shape.axes(degsToRads(b2.rotation), b1)

    if debugDraw then
        b1.shape.draw debugDrawDisplay, b1.pos, degsToRads(b1.rotation)
        b2.shape.draw debugDrawDisplay, b2.pos, degsToRads(b2.rotation)

        debugDrawDisplay.line b1.x, b1.y, b2.x, b2.y, color.gray

        debugDrawAxes b1.pos, axes
    end if

    overlap1 = findOverlapPoints(axes, b1, b2)
    if not overlap1 then
        return false
    end if

    overlap2 = findOverlapPoints(axes, b2, b1)
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

    if debugDraw then
        dir = overlap.normal.times(-overlap.depth)
        debugDrawDisplay.line b1.x, b1.y, b1.x + dir.x, b1.y + dir.y, color.red, 4
    end if

    return overlap
end function
