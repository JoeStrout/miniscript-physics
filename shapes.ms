Shape = {}

RectangleShape = new Shape
CircleShape = new Shape

Rectangle = function(width, height)
    obj = new RectangleShape
    obj.width = width
    obj.height = height
    obj.area = width * height

    return obj
end function

Circle = function(radius)
    obj = new CircleShape
    obj.radius = radius
    obj.area = pi * (radius ^ 2)

    return obj
end function