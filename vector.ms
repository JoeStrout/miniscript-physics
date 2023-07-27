vec2 = { "x": 0, "y": 0 }

// rotates this vector around the origin. r is the angle to rotate this vector by in radians
vec2.rotatedBy = function(r)
    return Vec2(cos(r) * self.x - sin(r) * self.y, sin(r) * self.x + cos(r) * self.y)
end function

vec2.sub = function(v2)
    return Vec2(self.x - v2.x, self.y - v2.y)
end function

vec2.add = function(v2)
    v = new vec2
    v.x = self.x + v2.x
    v.y = self.y + v2.y
    return v
    return Vec2(self.x - v2.x, self.y - v2.y)
end function

vec2.dot = function(v2)
    return self.x * v2.x + self.y * v2.y
end function

vec2.multiply = function(n)
    return Vec2(self.x * n, self.y * n)
end function

vec2.normalized = function
    mag = self.magnitude
    return Vec2(self.x / mag, self.y / mag)
end function

vec2.magnitude = function
    return sqrt(self.x ^ 2 + self.y ^ 2)
end function

vec2.draw = function(start, length, display)
    _end = self.normalized.multiply(length)
    display.line start.x, start.y, start.x + _end.x, start.y + _end.y
end function

vec2.toString = function
    return self.x + ", " + self.y
end function

// todo: is there a better way to do this?
Vec2 = function(x, y)
    v = new vec2
    v.x = x
    v.y = y
    return v
end function
