import "vector"

xAxis = vector.Vec2(1, 0)
yAxis = vector.Vec2(0, 1)

debugDraw = true

fillCircle = function(v, r)
    gfx.fillEllipse(v.x - r, v.y - r, r * 2, r * 2)
end function

degsToRads = function (d)
	return (d / 360) * 2 * pi
end function

getPoints = function(body)
	// todo: handle cases for non-rectangular objects

	hw = body.localBounds.width * body.scale / 2
	hh = body.localBounds.height * body.scale / 2
    pos = vector.Vec2(body.x, body.y)

    topLeft     = vector.Vec2(-hw, hh).rotatedBy(degsToRads(body.rotation)).add(pos)
    topRight    = vector.Vec2(hw , hh).rotatedBy(degsToRads(body.rotation)).add(pos)
    bottomLeft  = vector.Vec2(-hw, -hh).rotatedBy(degsToRads(body.rotation)).add(pos)
    bottomRight = vector.Vec2(hw, -hh).rotatedBy(degsToRads(body.rotation)).add(pos)

    points = [topLeft, topRight, bottomLeft, bottomRight]

    if debugDraw then
        for p in points
            fillCircle(p, 3)
        end for
    end if

    return points
end function

getAxes = function(body)
	// todo: handle cases for non-rectangular objects, should return one axis per face

    axes = [
        xAxis.rotatedBy(degsToRads(body.rotation)),
        yAxis.rotatedBy(degsToRads(body.rotation)),
    ]

    if debugDraw then
        for axis in axes
            axis.draw(vector.Vec2(body.x, body.y), 300)
        end for
    end if

    return axes
end function

findMinMaxInAxis = function(points, axis)
    min = 0
    hasMin = false
    max = 0
    hasMax = false

    for p in points
        dist = p.dot(axis)

        if not hasMin or dist < min then
            hasMin = true
            min = dist
        end if

        if not hasMax or dist > max then
            hasMax = true
            max = dist
        end if
    end for

    return { "min": min, "max": max }
end function

areOverlappingOnAxis = function(b1, b2, axis)
	// axisNormal = vector.Vec2(-axis.y, axis.x)

    p1 = getPoints(b1)
    p2 = getPoints(b2)

    minmax1 = findMinMaxInAxis(p1, axis)
    minmax2 = findMinMaxInAxis(p2, axis)

    // fillCircle(axis.multiply(minmax1.min).add(vector.Vec2(500, 0)))
    // fillCircle(axis.multiply(minmax1.max).add(vector.Vec2(500, 0)))
    // fillCircle(axis.multiply(minmax2.min).add(vector.Vec2(500, 0)))
    // fillCircle(axis.multiply(minmax2.max).add(vector.Vec2(500, 0)))

    return minmax1.max > minmax2.min and minmax1.min < minmax2.max

    // for i in range(points.len - 1)
    //     v1 = points[i]
    //     v2 = points[(i + 1) % points.len]

    //     fillCircle(v1.add(vector.Vec2(b1.x, b1.y)))

    //     vec = v2.sub(v1)

    // end for
end function

areOverlapping = function(b1, b2)
    // todo: remove duplicates
    axes = getAxes(b1) + getAxes(b2)

    for axis in axes
        if not areOverlappingOnAxis(b1, b2, axis) then
            return false
        end if
    end for

    return true
end function
