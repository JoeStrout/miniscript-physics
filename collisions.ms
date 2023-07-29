import "importUtil"
import "mathUtil"

import "sat"
import "debugDraw"
ensureImport "shapes"

testCircleCircle = function(b1, b2)
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

testCircleBox = function(circle, box)
    if debugDraw.enabled then
        debugDraw.drawDisplay.line circle.x, circle.y, box.x, box.y, color.gray

        debugDraw.points sat.getRectangleVertices(box)
        debugDraw.circle circle.x, circle.y, circle.shape.radius
    end if

    boxRot = mathUtil.degToRad(box.rotation)

    // Rotate the circle around the box to negate the box's rotation
    relCirclePos = circle.pos.sub(box.pos).rotatedBy(-boxRot)

    boxSize = [box.shape.width / 2, box.shape.height / 2]

    closestPoint = relCirclePos.clamp(boxSize.times(-1), boxSize)
    circleDist = relCirclePos.sub(closestPoint).magnitude

    if debugDraw.enabled then
        debugDraw.point closestPoint.rotatedBy(boxRot).plus(box.pos)
    end if

    if relCirclePos.equals(closestPoint) then
        // Circle is inside box
        print "inside"
        print relCirclePos
        print boxSize

        penLeft = relCirclePos.x + boxSize.x
        penRight = -relCirclePos.x + boxSize.x
        penBottom = relCirclePos.y + boxSize.y
        penTop = -relCirclePos.y + boxSize.y
        smallest = [penLeft, penRight, penBottom, penTop].min

        if penLeft == smallest then
            normal = [1, 0]
        else if penRight == smallest then
            normal = [-1, 0]
        else if penBottom == smallest then
            normal = [0, 1]
        else if penTop == smallest then
            normal = [0, -1]
        else
            return false
        end if

        return {
            "normal": normal.rotatedBy(boxRot),
            "depth": smallest + circle.shape.radius,
        }
    end if

    if circleDist <= circle.shape.radius then
        return {
            "normal": closestPoint.sub(relCirclePos).normalized.rotatedBy(boxRot),
            "depth": circle.shape.radius - circleDist,
        }
    end if

    return false
end function

collideBodies = function(b1, b2)
    if b1.shape isa shapes.RectangleShape and b2.shape isa shapes.RectangleShape then
        // Box-box collision
        //TODO: Optimize for case where both rectangles have rotation = 0
        return sat.testRectangles(b1, b2)
    else if b1.shape isa shapes.CircleShape and b2.shape isa shapes.RectangleShape then
        // Circle-box collision
        return testCircleBox(b1, b2)
    else if b1.shape isa shapes.RectangleShape and b2.shape isa shapes.CircleShape then
        // Box-circle collision
        result = testCircleBox(b2, b1)
        if not result then return false

        return {
            "normal": result.normal.times(-1),
            "depth": result.depth,
        }
    else if b1.shape isa shapes.CircleShape and b2.shape isa shapes.CircleShape then
        // Circle-circle collision
        return testCircles(b1, b2)
    end if
end function
