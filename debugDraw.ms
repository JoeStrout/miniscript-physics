enabled = false

if enabled then
    display(2).mode = displayMode.pixel

    drawDisplay = display(2)
    drawDisplay.clear
end if

axes = function(p, axes, length=500)
    for axis in axes
        edge = axis.normal
        drawDisplay.line p.x, p.y, p.x + edge.x * length, p.y + edge.y * length
    end for
end function

point = function(p, color, r=2)
    drawDisplay.fillEllipse p.x - r, p.y - r, r * 2, r * 2, color
end function

points = function(points, color, r=2)
    for p in points
        point p, color, r
    end for
end function

circle = function(x, y, r, color, width)
    drawDisplay.drawEllipse x - r, y - r, r * 2, r * 2, color, width
end function

line = function(start, dir, color, width)
    drawDisplay.line start.x, start.y, start.x + dir.x, start.y + dir.y, color, width
end function

arrowLine = function(start, dir, color, width)
    if dir.x == 0 and dir.y == 0 then return

    _end = start.plus(dir)

    w = 5
    h = w * sqrt(3)

    u = _end.sub(start).normalized
    v = u.normal

    v1 = _end.sub(u.times(h)).plus(v.times(w))
    v2 = _end.sub(u.times(h)).sub(v.times(w))

    drawDisplay.line start.x, start.y, _end.x, _end.y, color, width
    drawDisplay.line _end.x, _end.y, v1.x, v1.y, color, width
    drawDisplay.line _end.x, _end.y, v2.x, v2.y, color, width
end function
