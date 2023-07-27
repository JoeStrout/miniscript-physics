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

findOverlapOnAxis = function(b1, b2, axis)
    p1 = getPoints(b1)
    p2 = getPoints(b2)

    minmax1 = findMinMaxInAxis(p1, axis)
    minmax2 = findMinMaxInAxis(p2, axis)

    if axis.x == 1 and axis.y == 0 then
        gfx.line(minmax1.min, 20, minmax1.max, 20)
        gfx.line(minmax2.min, 30, minmax2.max, 30)
    end if

    if not (minmax1.max > minmax2.min and minmax1.min < minmax2.max) then
        return false
    end if

    a = minmax1.max - minmax2.min
    b = minmax2.max - minmax1.min

    if a > b then
        return b
    else
        return -a
    end if
end function

findOverlap = function(b1, b2)
    // todo: remove duplicates
    axes = getAxes(b1) + getAxes(b2)

    hasOverlap = false
    minOverlap = null

    for axis in axes
        overlap = findOverlapOnAxis(b1, b2, axis)

        if overlap == false then
            return false
        end if

        if not hasOverlap or abs(overlap) < minOverlap.magnitude then
            hasOverlap = true
            minOverlap = axis.multiply(overlap)
        end if
    end for

    return minOverlap
end function
