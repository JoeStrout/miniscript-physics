import "importUtil"

import "sat"
import "debugDraw"
ensureImport "shapes"

testCircles = function(b1, b2)
    r1 = b1.shape.radius
    r2 = b2.shape.radius

    if debugDraw.enabled then
        debugDraw.drawDisplay.line b1.x, b1.y, b2.x, b2.y, color.gray
        debugDraw.circle b1.x, b1.y, r1
        debugDraw.circle b2.x, b2.y, r2
    end if

    normal = b2.pos.sub(b1.pos)

    dist = normal.magnitude
    if dist > r1 + r2 then
        return false
    end if

    return {
        "normal": normal.normalized,
        "depth": r1 + r2 - dist,
    }
end function

collideBodies = function(b1, b2)
    if b1.shape isa shapes.RectangleShape and b2.shape isa shapes.RectangleShape then
        // Box-box collision

        //TODO: Optimize for case where both rectangles have rotation = 0
        return sat.testRectangles(b1, b2)
    else if b1.shape isa shapes.CircleShape and b2.shape isa shapes.RectangleShape then
        // Circle-box collision
    else if b1.shape isa shapes.RectangleShape and b2.shape isa shapes.CircleShape then
        // Box-circle collision
    else if b1.shape isa shapes.CircleShape and b2.shape isa shapes.CircleShape then
        // Circle-circle collision
        return testCircles(b1, b2)
    end if
end function
