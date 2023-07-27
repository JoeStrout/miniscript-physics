// Simple physics simulation for Mini Micro.
// A physics body is an object containing a .localBounds property,
// which in this case can be either a Bounds object or a list of
// Bounds objects.

import "vector"
import "collisions"

// Global physics constants
gravity = -200		// gravity, in upward pixels/sec^2 (1000 means 1 meter = 100 pixels)

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


initPhys = function(body, density=0.01, elasticity=0.9)
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
    body.mass = area(body) * density * scale
    body.elasticity = elasticity
    body.vx = 0
    body.vy = 0
    body.drag = 0.01
    body.rotInertia = rotInertia(body, density, scale)
    body.rotSpeed = 0
    body.rotDrag = 0.01
end function

collide = function(b1, b2)
    overlap = collisions.findOverlap(b1, b2)

    // todo: make this mess better
    if overlap then
        factor = 1

        if b1.mass != 0 then
            moveable = b1
            factor = -1
        else if b2.mass != 0 then
            moveable = b2
        else
            // both bodies are static, can't move either
            return
        end if

        if overlap.x != 0 then
            moveable.vx = 0
            moveable.x -= overlap.x * factor
        end if
        if overlap.y != 0 then
            moveable.vy = 0
            moveable.y -= overlap.y * factor
        end if
    end if
end function

calcCollisions = function(bodies)
    maxIndex = bodies.len - 1
    for i in range(0, maxIndex-1)
        bi = bodies[i]
        for j in range(i+1, maxIndex)
            bj = bodies[j]

            collide(bi, bj)
        end for
    end for
end function

updateBody = function(body, dt=0.01)
    if not body.mass then return  // 0 mass means a static (non-moving) body
    
    // for now, we'll do simple forward Euler integration of Newton's laws.
    body.vy = body.vy + gravity * dt
    // ToDo: drag
    
    body.x = body.x + body.vx * dt
    body.y = body.y + body.vy * dt
    
    body.rotation = body.rotation + body.rotSpeed * dt
end function

updateMany = function(bodies, dt=0.01)
	gfx.clear
    calcCollisions bodies
    for body in bodies
        updateBody body, dt
    end for
end function
