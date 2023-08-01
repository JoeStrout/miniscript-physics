import "mathUtil"

list.x = function
    return self[0]
end function

list.y = function
    return self[1]
end function

list.sub = function(x)
    return [self[0] - x[0], self[1] - x[1]]
end function

// Rotates returns a vector rotated around the origin. r is the angle 
// to rotate this vector by in radians
list.rotatedBy = function(r)
    return [cos(r) * self[0] - sin(r) * self[1], sin(r) * self[0] + cos(r) * self[1]]
end function

list.normalized = function
    mag = self.magnitude
    if mag == 0 then return [0, 0]

    return [self[0] / mag, self[1] / mag]
end function

list.magnitude = function
    return sqrt(self[0] ^ 2 + self[1] ^ 2)
end function

list.magnitudeSq = function
    return self[0] ^ 2 + self[1] ^ 2
end function

// Returns a vector perpendicular to this one
list.normal = function
    return [-self[1], self[0]]
end function

list.clamp = function(min, max)
    return [
        mathUtil.clamp(self[0], min[0], max[0]),
        mathUtil.clamp(self[1], min[1], max[1]),
    ]
end function

// ToDo: What is this, exactly?  It doesn't look like a cross product.
// Looks like either a dot product (with the normal of the argument),
// or a scaled perpendicular.  Can we name it better?
list.cross = function(n)
    if n isa list then
        return self[0] * n[1] + self[1] * n[0]
    else
        return [-self[1] * n, self[0] * n]
    end if
end function

// ToDo: probably don't need this, as == already works for lists
// (and is probably more efficient).
list.equals = function(other)
    return self[0] == other[0] and self[1] == other[1]
end function

list.draw = function(start, length, display)
    _end = self.normalized.times(length)
    display.line start[0], start[1], start[0] + _end[0], start[1] + _end[1]
end function

averageMany = function(vs)
    sumX = 0
    sumY = 0

    for v in vs
        sumX += v[0]
        sumY += v[1]
    end for

    return [sumX / vs.len, sumY / vs.len]
end function
