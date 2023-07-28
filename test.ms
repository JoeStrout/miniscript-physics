clear

import "physics"
import "shapes"

sprDisp = display(4)

circle = shapes.Circle(60)

b1 = new Sprite
b1.image = file.loadImage("/sys/pics/shapes/Circle.png")
b2.scale = 2
b1.tint = color.blue
physics.initPhys b1, true, circle
b1.x = 300; b1.y = 200
b1.vy = 400
b1.rotSpeed = 30
sprDisp.sprites.push b1

b2 = new Sprite
b2.image = file.loadImage("/sys/pics/Block4.png")
b1.scale = 1
b2.tint = color.orange
physics.initPhys b2, true
// b2.rotSpeed = 50
sprDisp.sprites.push b2
b2.x = 350; b2.y = 400


// ground = new Sprite
// ground.image = file.loadImage("/sys/pics/Block4.png")
// ground.scale = 4
// ground.tint = color.yellow
// sprDisp.sprites.push ground
// ground.x = 480; ground.y = -55
// physics.initPhys ground, true

control = b1

dt = 1/60
while not key.available
	if mouse.button(0) then
		control.static = true
		control.x = mouse.x
		control.y = mouse.y
		control.vx = 0
		control.vy = 0
	else
		// control.static = false
	end if

	if mouse.button(1) then
		control.rotation = control.rotation + 1
	end if

	physics.updateMany sprDisp.sprites, dt
	yield
end while
key.clear
