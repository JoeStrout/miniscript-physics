// Simple physics simulation for Mini Micro.
// A physics body is an object containing a .localBounds property,
// which in this case can be either a Bounds object or a list of
// Bounds objects.

import "listUtil"
import "collisions"
import "mathUtil"

// Global physics constants
gravity = 700		// gravity, in downward pixels/sec^2 (1000 means 1 meter = 100 pixels)

gravityForce = [0, -gravity]

// Function to find the area of a physics body.
area = function(body)
    if body.localBounds isa list then
        // sum up the mass of each part
        result = 0
        for b in body.localBounds
            result = result + b.width * b.height
        end for
        return result
    else
        // simple case: only one part (Bounds)
        return body.localBounds.width * body.localBounds.height
    end if
end function	

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


initPhys = function(body, static=false, density=0.01, elasticity=0.4)
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

    if static then
        body.mass = 1 / 0
    else
        body.mass = area(body) * density * scale
    end if

    body.static = static
    body.elasticity = elasticity
    body.vx = 0
    body.vy = 0
    body.drag = 0.01
    body.rotInertia = rotInertia(body, density, scale)
    body.rotSpeed = 0
    body.rotDrag = 0.01
    body.forces = []
end function

collide = function(b1, b2)
    if b1.static and b2.static then return

    overlap = collisions.findOverlap(b1, b2)

    if overlap then
        // Calculate impulse vector needed to push b1 out of b2

        elasticity = mathUtil.min(b1.elasticity, b2.elasticity)
        vrel = [b1.vx - b2.vx, b1.vy - b2.vy]

        impulseMagnitude = -(1 + elasticity) * vrel.dot(overlap.normal) / ((1 / b1.mass) + (1 / b2.mass))
        impulse = overlap.normal.times(impulseMagnitude)

        // First push objects out of the way to prevent them from overlapping
        displacement = overlap.normal.times(overlap.depth)

        // If neither object is static we push each one out of the way by half of the displacement.
        // If one of them is static we push the non-static object by the entire displacement.

        if b1.static then
            b2.x += displacement.x
            b2.y += displacement.y
        else if b2.static then
            b1.x -= displacement.x
            b1.y -= displacement.y
        else
            b1.x -= displacement.x / 2
            b1.y -= displacement.y / 2
            b2.x += displacement.x / 2
            b2.y += displacement.y / 2
        end if

        b1.forces.push impulse
        b2.forces.push impulse.times(-1)
    end if
end function

resetForces = function(bodies)
    for b in bodies
        b.forces = [gravityForce]
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
    if body.static then return

    accelX = 0
    accelY = 0

    // F = m*a => a = F/m
    for f in body.forces
        accelX += f.x / body.mass
        accelY += f.y / body.mass
    end for

    body.vx += accelX
    body.vy += accelY

    // ToDo: drag

    body.x = body.x + body.vx * dt
    body.y = body.y + body.vy * dt
    
    body.rotation = body.rotation + body.rotSpeed * dt
end function

updateMany = function(bodies, dt=0.01)
    if collisions.debugDraw then
        collisions.debugDrawDisplay.clear
    end if

    resetForces bodies
    calcCollisions bodies

    for body in bodies
        updateBody body, dt
    end for
end function
