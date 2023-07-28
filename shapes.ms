import "qa"

Shape = {}

Shape.vertices = null

// Default implementation simply returns each edge's normal
Shape.axes = function(rot, otherBody)
    points = self.vertices
    axes = []

    if points == null then
        print self
        qa.abort "Neither axes nor vertices member has been set"
        return []
    end if

    for i in range(points.len - 1)
        p1 = points[i]
        p2 = points[(i + 1) % points.len]

        edge = p2.sub(p1)
        axis = edge.normal().normalized().rotatedBy(rot)

        axes.push axis
    end for

    return axes
end function

// Default implementation projects each vertex and takes the maximum and minimum
Shape.projectOn = function(axis, pos, rot)
    min = 0
    hasMin = false
    max = 0
    hasMax = false

    for p in self.vertices
        transformedP = p.rotatedBy(rot).plus(pos)
        proj = transformedP.dot(axis)

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

Rectangle = function(width, height)
    obj = new Shape

    hw = width / 2
    hh = height / 2

    obj.vertices = [
        [-hw, hh],
        [hw , hh],
        [hw, -hh],
        [-hw, -hh],
    ]

    obj.draw = function(disp, pos, rot)
        for v in obj.vertices
            p = v.rotatedBy(rot).plus(pos)
            disp.fillEllipse p.x - 2, p.y - 2, 4, 4
        end for
    end function

    return obj
end function

Circle = function(radius)
    obj = new Shape

    obj.projectOn = function(axis, pos, rot)
        projCenter = pos.dot(axis)

        return { "min": projCenter - radius, "max": projCenter + radius }
    end function

    obj.draw = function(disp, pos, rot)
        disp.drawEllipse pos.x - radius, pos.y - radius, radius * 2, radius * 2
    end function

    return obj
end function