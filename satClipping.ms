import "debugDraw"

// https://dyn4j.org/2011/11/contact-points-using-clipping/

findBestFeature = function(points, n)
    max = -1 / 0

    for i in range(points.len - 1)
        proj = n.dot(points[i])

        if proj > max then
            max = proj
            index = i
        end if
    end for

    v = points[index]
    v1 = points[(index - 1) % points.len]
    v0 = points[(index + 1) % points.len]

    l = v.sub(v1).normalized
    r = v.sub(v0).normalized

    if r.dot(n) <= l.dot(n) then
        return {
            "max": v,
            "v1": v0,
            "v2": v,
            "edge": v.sub(v0),
        }
    else
        return {
            "max": v,
            "v1": v,
            "v2": v1,
            "edge": v1.sub(v),
        }
    end if
end function

clip = function(v1, v2, n, o)
    cp = []

    d1 = n.dot(v1) - o
    d2 = n.dot(v2) - o

    if d1 >= 0 then
        cp.push(v1)
    end if
    if d2 >= 0 then
        cp.push(v2)
    end if

    if d1 * d2 < 0 then
        e = v2.sub(v1)
        u = d1 / (d1 - d2)

        cp.push e.times(u).plus(v1)
    end if

    return cp
end function

clipPoints = function(points1, points2, normal)
    e1 = findBestFeature(points1, normal)
    e2 = findBestFeature(points2, normal.times(-1))

    if abs(e1.edge.dot(normal)) <= abs(e2.edge.dot(normal)) then
        ref = e1
        inc = e2
        flip = false
    else
        ref = e2
        inc = e1
        flip = true
    end if

    if debugDrawEnabled then
        debugDraw.drawDisplay.line ref.v1.x, ref.v1.y, ref.v2.x, ref.v2.y, color.red, 2
        debugDraw.drawDisplay.line inc.v1.x, inc.v1.y, inc.v2.x, inc.v2.y, color.green, 2
    end if

    refv = ref.edge.normalized

    o1 = refv.dot(ref.v1)
    cp = clip(inc.v1, inc.v2, refv, o1)
    if cp.len < 2 then return false

    o2 = refv.dot(ref.v2)
    cp = clip(cp[0], cp[1], refv.times(-1), -o2)
    if cp.len < 2 then return false

    refNorm = ref.edge.normal
    // if flip then
    //     refNorm.multiplyBy(-1)
    // end if

    max = refNorm.dot(ref.max)

    i = cp.len - 1
    while i >= 0
        if refNorm.dot(cp[i]) - max < 0 then
            if debugDrawEnabled then
                debugDraw.point cp[i], color.red, 3
            end if

            cp.remove i
        end if
        i = i - 1
    end while

    return cp
end function