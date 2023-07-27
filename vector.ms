list.x = function
    return self[0]
end function

list.y = function
    return self[1]
end function

list.sub = function(x)
    return [self[0] - x[0], self[1] - x[1]]
end function

// rotates this vector around the origin. r is the angle to rotate this vector by in radians
list.rotatedBy = function(r)
    return [cos(r) * self[0] - sin(r) * self[1], sin(r) * self[0] + cos(r) * self[1]]
end function

list.normalized = function
    mag = self.magnitude
    return [self[0] / mag, self[1] / mag]
end function

list.magnitude = function
    return sqrt(self[0] ^ 2 + self[1] ^ 2)
end function

list.draw = function(start, length, display)
    _end = self.normalized.times(length)
    display.line start[0], start[1], start[0] + _end[0], start[1] + _end[1]
end function
