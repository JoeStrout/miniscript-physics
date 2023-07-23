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
				// Collision Response
                local dx = bj.x - bi.x
                local dy = bj.y - bi.y
                local distance = math.sqrt(dx * dx + dy * dy)
                local totalMass = bi.mass + bj.mass
                local nx = dx / distance
                local ny = dy / distance
                local p = 2.0 * (bi.vx * nx + bi.vy * ny - bj.vx * nx - bj.vy * ny) / totalMass

                // Apply collision forces
                bi.vx = bi.vx - p * bi.mass * nx
                bi.vy = bi.vy - p * bi.mass * ny
                bj.vx = bj.vx + p * bj.mass * nx
                bj.vy = bj.vy + p * bj.mass * ny
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
