// Simple physics simulation for Mini Micro.
// A physics body is an object containing a .localBounds property,
// which in this case can be either a Bounds object or a list of
// Bounds objects.

import "listUtil"
import "mathUtil"
import "importUtil"

import "collisions"
import "debugDraw"
import "vector"
ensureImport "shapes"

// Global physics constants
gravity = 1000		// gravity, in downward pixels/sec^2 (1000 means 1 meter = 100 pixels)
correctionFactor = 0.4 // usually 0.2 to 0.8
correctionSlop = 0.05  // usually 0.01 to 0.1
dragCoefficient = 0.0002
enableCollisionResponse = true

globals.lastId = 0

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

    body.id = lastId + 1
    globals.lastId += 1

    body.elasticity = elasticity
    body.vel = [0, 0]                                   // pixels per second
    body.rotationRad = mathUtil.degToRad(body.rotation) // radians
    body.rotSpeed = 0                                   // radians per second
    body.forces = [0, 0]
    body.staticFriction = 0.2
    body.dynamicFriction = 0.1
    body.dragCoef = -0.5 * dragCoefficient

    body.pos = function
        return [body.x, body.y]
    end function

    body.static = function
        return body.invMass == 0
    end function

    body.setStatic = function(s)
        if s then
            body.mass = 0
            body.invMass = 0
            body.inertia = 0
            body.invInertia = 0
        else
            body.mass = calcMass
            body.invMass = 1 / calcMass
            body.inertia = calcMass * body.shape.inertiaFactor
            body.invInertia = 1 / body.inertia
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
    if not overlap then return

    normal = overlap.normal

    if debugDrawEnabled then
        debugDraw.arrowLine b1.pos, normal.times(-overlap.depth), color.red, 2
        debugDraw.arrowLine b2.pos, normal.times(overlap.depth), color.red, 2
    end if

    if not enableCollisionResponse then return

    point = vector.averageMany(overlap.points)
    r1 = point.sub(b1.pos)
    r2 = point.sub(b2.pos)

    // Calculate normal response impulse

    vp1 = b1.vel.plus(r1.cross(b1.rotSpeed))
    vp2 = b2.vel.plus(r2.cross(b2.rotSpeed))
    vrel = vp2.sub(vp1)

    vrelAlongNormal = vrel.dot(normal)
    if vrelAlongNormal >= 0 then return

    e = mathUtil.min(b1.elasticity, b2.elasticity)

    j = -(1 + e) * vrelAlongNormal
    j /= (b1.invMass + b2.invMass) + ((r1.normal.dot(normal) ^ 2) * b1.invInertia) + ((r2.normal.dot(normal) ^ 2) * b2.invInertia)
    impulseNormal = normal.times(j)

    // Apply normal impulse

    b1.vel.add impulseNormal.times(-b1.invMass)
    b2.vel.add impulseNormal.times(b2.invMass)

    b1.rotSpeed -= r1.cross(impulseNormal) * b1.invInertia
    b2.rotSpeed += r2.cross(impulseNormal) * b2.invInertia

    // Calculate friction impulse

    vp1 = b1.vel.plus(r1.cross(b1.rotSpeed))
    vp2 = b2.vel.plus(r2.cross(b2.rotSpeed))
    vrel = vp2.sub(vp1)

    tangent = vrel.sub(normal.times(vrel.dot(normal))).normalized

    if debugDrawEnabled then
        debugDraw.arrowLine b1.pos, tangent.times(50), color.green, 2
        debugDraw.arrowLine b2.pos, tangent.times(50), color.green, 2
    end if

    jt = -(1 + e) * vrel.dot(tangent)
    jt /= (b1.invMass + b2.invMass) + ((r1.normal.dot(tangent) ^ 2) * b1.invInertia) + ((r2.normal.dot(tangent) ^ 2) * b2.invInertia)

    mu = sqrt(b1.staticFriction ^ 2 + b2.staticFriction ^ 2)

    if abs(jt) < j * mu then
        impulseTangent = tangent.times(jt)
    else
        dynamicFriction = sqrt(b1.dynamicFriction ^ 2 + b2.dynamicFriction ^ 2)
        impulseTangent = tangent.times(-j * dynamicFriction)
    end if

    // Apply friction impulse

    b1.vel.add impulseTangent.times(-b1.invMass)
    b2.vel.add impulseTangent.times(b2.invMass)

    b1.rotSpeed -= r1.cross(impulseTangent) * -b1.invInertia
    b2.rotSpeed += r2.cross(impulseTangent) * -b2.invInertia

    correctPositions b1, b2, overlap.depth, overlap.normal
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
        body.vel[0] = 0
        body.vel[1] = 0
        return
    end if

    if debugDrawEnabled then
        debugDraw.arrowLine body.pos, body.forces.times(5), color.green, 3
    end if

    // Apply drag forces
    velMagSq = body.vel.magnitudeSq
    body.forces.add body.vel.times(body.dragCoef * velMagSq)

    // F = m*a => a = F/m
    accel = body.forces.times(body.invMass * dt)
    body.vel.add accel

    if abs(body.vel[0]) < 0.01 then
        body.vel[0] = 0
    end if
    if abs(body.vel[1]) < 0.01 then
        body.vel[1] = 0
    end if

    body.x = body.x + body.vel[0] * dt
    body.y = body.y + body.vel[1] * dt

    body.rotationRad += body.rotSpeed * dt
    body.rotation = mathUtil.radToDeg(body.rotationRad)

    body.forces = [0, -gravity * body.mass]
end function

updateMany = function(bodies, dt=0.01)
    debugDraw.drawDisplay.clear

    display(3).clear
    display(3).column = 0
    display(3).row = 0

    calcCollisions bodies

    for body in bodies
        updateBody body, dt
    end for
end function
