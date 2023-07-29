enabled = true

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

vector = function(start, dir, color, width)
    drawDisplay.line start.x, start.y, start.x + dir.x, start.y + dir.y, color, width
end function
