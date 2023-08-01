import "math"

mathUtil = {}

mathUtil.degToRad = function(deg)
    return deg * (pi / 180)
end function

mathUtil.radToDeg = function(rad)
    return rad * (180 / pi)
end function

mathUtil.min = function(a, b)
    return a < b ? a : b
end function

mathUtil.max = function(a, b)
    return a > b ? a : b
end function

mathUtil.clamp = function(x, min, max)
    return mathUtil.max(min, mathUtil.min(x, max))
end function
