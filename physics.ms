// Simple physics simulation for Mini Micro.
// A physics body is an object containing a .localBounds property,
// which in this case can be either a Bounds object or a list of
// Bounds objects.

import "listUtil"
import "mathUtil"
import "importUtil"

import "collisions"
import "debugDraw"
ensureImport "shapes"

// Global physics constants
gravity = 200		// gravity, in downward pixels/sec^2 (1000 means 1 meter = 100 pixels)
correctionFactor = 0.2 // usually 0.2 to 0.8
correctionSlop = 0.1  // usually 0.01 to 0.1

// Function to find the rotational inertia of a physics body.
rotInertia = function(body, density, scale)
    if body.localBounds isa list then
        // combine the inertia from each part
        result = 0
        for b in body.localBounds
            w = b.width * scale
            h = b.height * scale
            x = b.x * scale
            y = b.y * scale
            m = w * h * density
            result = result + m * ((w^2 + h^2) / 12 + x^2  + y^2)
        end for
        return result
    else
        // simple case: only one part (Bounds)
        b = body.localBounds
        w = b.width * scale
        h = b.height * scale
        x = b.x * scale
        y = b.y * scale
        m = w * h * density
        return m * ((w^2 + h^2) / 12 + x^2  + y^2)
    end if
end function	


initPhys = function(body, shape=null, density=0.01, elasticity=0.4)
    // if our "body" doesn't have a localBounds, but it does have an
    // image, assume its bounds matches the image (e.g. for a sprite)
    if not body.hasIndex("localBounds") then
        if not body.hasIndex("image") then
            print "physics.initPhys: either localBounds or image required"
            print body
            exit
        end if
        scale = 1
        body.localBounds = new Bounds
        body.localBounds.width = body.image.width
        body.localBounds.height = body.image.height
    end if
    
    // now add all the physics properties we need
    if body.hasIndex("scale") then scale = body.scale else scale = 1

    if shape == null then
        body.shape = shapes.Rectangle(body.localBounds.width * body.scale, body.localBounds.height * scale)
    else
        body.shape = shape
    end if

    calcMass = body.shape.area * density

    body.static = false
    body.elasticity = elasticity
    body.vx = 0
    body.vy = 0
    body.drag = 0.01
    body.rotInertia = rotInertia(body, density, scale)
    body.rotSpeed = 0
    body.rotDrag = 0.01
    body.forces = [0, 0]

    body.pos = function
        return [body.x, body.y]
    end function

    body.setStatic = function(s)
        body.static = s

        if s then
            body.mass = 0
            body.invMass = 0
        else
            body.mass = calcMass
            body.invMass = 1 / calcMass
        end if
    end function

    body.setStatic false
end function

correctPositions = function(b1, b2, depth, normal)
    correction = normal.times((mathUtil.max(depth - correctionSlop, 0) / (b1.invMass + b2.invMass)) * correctionFactor)
    
    corr1 = correction.times(b1.invMass)
    b1.x -= corr1.x
    b1.y -= corr1.y

    corr2 = correction.times(b2.invMass)
    b2.x += corr2.x
    b2.y += corr2.y
end function

collide = function(b1, b2)
    if b1.static and b2.static then return

    overlap = collisions.collideBodies(b1, b2)

    if overlap then
        if debugDraw.enabled then
            debugDraw.arrowLine b1.pos, overlap.normal.times(-overlap.depth), color.red, 2
            debugDraw.arrowLine b2.pos, overlap.normal.times(overlap.depth), color.red, 2
        end if

        elasticity = mathUtil.min(b1.elasticity, b2.elasticity)
        vrel = [b1.vx - b2.vx, b1.vy - b2.vy]

        vrelAlongNormal = vrel.dot(overlap.normal)
        if vrelAlongNormal < 0 then return

        impulseMagnitude = -(1 + elasticity) * vrelAlongNormal / (b1.invMass + b2.invMass)
        impulse = overlap.normal.times(impulseMagnitude)

        dv1 = impulse.times(-b1.invMass)
        b1.vx -= dv1.x
        b1.vy -= dv1.y

        dv2 = impulse.times(-b2.invMass)
        b2.vx += dv2.x
        b2.vy += dv2.y

        correctPositions b1, b2, overlap.depth, overlap.normal
    end if
end function

resetForces = function(bodies)
    for b in bodies
        b.forces = [0, -gravity]
    end for
end function

calcCollisions = function(bodies)
    maxIndex = bodies.len - 1
    for i in range(0, maxIndex-1)
        bi = bodies[i]
        for j in range(i+1, maxIndex)
            bj = bodies[j]

            collide bi, bj
        end for
    end for
end function

updateBody = function(body, dt=0.01)
    if body.static then 
        body.vx = 0
        body.vy = 0
        return
    end if

    if debugDraw.enabled then
        debugDraw.arrowLine body.pos, body.forces.times(5), color.green, 3
    end if

    // F = m*a => a = F/m
    accelX = body.forces.x / body.mass
    accelY = body.forces.y / body.mass

    body.vx += accelX
    body.vy += accelY

    if abs(body.vx) < 0.01 then
        body.vx = 0
    end if
    if abs(body.vy) < 0.01 then
        body.vy = 0
    end if

    // ToDo: drag

    body.x = body.x + body.vx * dt
    body.y = body.y + body.vy * dt

    body.rotation = body.rotation + body.rotSpeed * dt
end function

updateMany = function(bodies, dt=0.01)
    if debugDraw.enabled then
        debugDraw.drawDisplay.clear
    end if

    display(3).clear
    display(3).column = 0
    display(3).row = 0

    resetForces bodies
    calcCollisions bodies

    for body in bodies
        updateBody body, dt
    end for
end function
