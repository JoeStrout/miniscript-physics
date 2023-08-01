import "mathUtil"

collisions = {}

collisions.projectPoints = function(axis, points)
    min = 0
    hasMin = false
    max = 0
    hasMax = false

    for p in points do
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

    return {
        min = min,
        max = max,
    }
end function

collisions.findOverlapPoints = function(axes, points1, points2)
    minDepth = 1 / 0
    result = false

    for axis in axes do
        proj1 = collisions.projectPoints(axis, points1)
        proj2 = collisions.projectPoints(axis, points2)

        if proj1.min >= proj2.max or proj2.min >= proj1.max then
            return false
        end if

        depth1 = proj1.max - proj2.min
        depth2 = proj2.max - proj1.min

        if depth1 > depth2 then
            depth = depth2
            axis = axis.times(-1)
        else
            depth = depth1
        end if

        if depth < minDepth then
            minDepth = depth

            result = {
                normal = axis,
                depth = depth,
            }
        end if
    end for

    return result
end function

collisions.collideBodies = function(body1, body2)
    axes = body1.shape.getAxes() + body2.shape.getAxes()
    points1 = body1.shape.getVertices(body1.pos, mathUtil.degToRad(body1.rotation))
    points2 = body2.shape.getVertices(body2.pos, mathUtil.degToRad(body2.rotation))

    overlap1 = collisions.findOverlapPoints(axes, points1, points2)
    if not overlap1 then
        return false
    end if

    overlap2 = collisions.findOverlapPoints(axes, points2, points1)
    if not overlap2 then
        return false
    end if

    if overlap2.depth > overlap1.depth then
        overlap = overlap1
    else
        overlap = overlap2
        overlap.normal = overlap2.normal.times(-1)
    end if

    return overlap
end function
