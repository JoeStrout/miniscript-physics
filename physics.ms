// Simple physics simulation for Mini Micro.
// A physics body is an object containing a .localBounds property,
// which in this case can be either a Bounds object or a list of
// Bounds objects.

// Global physics constants
gravity = -1000		// gravity, in upward pixels/sec^2 (1000 means 1 meter = 100 pixels)

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
	if not (b1.localBounds isa list) and not (b2.localBounds isa list) then
		// simple case: a single Bounds for each body
		if not b1.worldBounds.overlaps(b2.worldBounds) then return null
		// Collision detected!
		if b1.mass then b1.tint = color.red
		if b2.mass then b2.tint = color.red
		return
	end if
	print "Non-trivial case of multiple bounds not handled yet in collide"
end function

calcCollisions = function(bodies)
	maxIndex = bodies.len - 1
	for i in range(0, maxIndex-1)
		bi = bodies[i]
		for j in range(i+1, maxIndex)
			bj = bodies[j]
			if collide(bi, bj) then
				// ToDo
				// Function to calculate drag force based on velocity and drag coefficient.
calculateDragForce = function(velocity, dragCoefficient)
    // The drag force opposes the velocity direction .
    local dragForce = -dragCoefficient * velocity * velocity
    return dragForce
end function

// Now function for drag calculation.
updateBody = function(body, dt, additionalForce)
    if not body.mass then return     
	 // 0 mass means static body.(non-movement)

    //  ToCalculate the drag force based on the body's velocity and drag coefficient.
    local dragCoefficient = body.drag
    local velocityMagnitude = math.sqrt(body.vx * body.vx + body.vy * body.vy)
    local dragForce = calculateDragForce(velocityMagnitude, dragCoefficient)

    // ToCalculate the total force affecting the body.
    local totalForceX = additionalForce.x - dragForce * body.vx
    local totalForceY = additionalForce.y - dragForce * body.vy + gravity * body.mass

    // ToCalculate the acceleration from the total force.
    local accelerationX = totalForceX / body.mass
    local accelerationY = totalForceY / body.mass

    body.vx = body.vx + accelerationX * dt
    body.vy = body.vy + accelerationY * dt
    body.x = body.x + body.vx * dt
    body.y = body.y + body.vy * dt

    // the body's rotation corresponding to its rotational speed.
    body.rotation = body.rotation + body.rotSpeed * dt
end function 

// Function to calculate and apply collision forces on bodies.
applyCollisionForces = function(body1, body2)
    // ToCalculate relative velocity between the two bodies.
    local relativeVelocityX = body1.vx - body2.vx
    local relativeVelocityY = body1.vy - body2.vy

    //  assuming body1 collided into body2.
    local normalX, normalY = body1.x - body2.x, body1.y - body2.y
    local normalMagnitude = math.sqrt(normalX * normalX + normalY * normalY)
    normalX, normalY = normalX / normalMagnitude, normalY / normalMagnitude

    // ToCalculate the relative velocity along the normal vector.
    local relativeVelocityAlongNormal = relativeVelocityX * normalX + relativeVelocityY * normalY

    // Check if the bodies are moving towards each other.
    if relativeVelocityAlongNormal > 0 then
        return  
		// Bodies are moving away from each other; no collision response needed.
    end if

    // average of the two bodies elasticity.
    local restitution = (body1.elasticity + body2.elasticity) / 2

    // Calculate the impulse due to the collision.
    local impulse = -(1 + restitution) * relativeVelocityAlongNormal / (1 / body1.mass + 1 / body2.mass)

    // Calculate the collision forces.
    local impulseX, impulseY = impulse * normalX, impulse * normalY

    // Applying the collision forces to the bodies.
    body1.vx = body1.vx + impulseX / body1.mass
    body1.vy = body1.vy + impulseY / body1.mass
    body2.vx = body2.vx - impulseX / body2.mass
    body2.vy = body2.vy - impulseY / body2.mass
end function

// Final calcCollisions function would be 
calcCollisions = function(bodies)
    local maxIndex = bodies.len - 1
    for i in range(0, maxIndex - 1) do
        local bi = bodies[i]
        for j in range(i + 1, maxIndex) do
            local bj = bodies[j]
            if collide(bi, bj) then
                // Collision detected! Applying collision forces
                applyCollisionForces(bi, bj)
            end if
        end for
    end for
end function
			end if
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
	calcCollisions bodies
	for body in bodies
		updateBody body, dt
	end for
end function
