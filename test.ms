clear

import "physics"

sprDisp = display(4)

b1 = new Sprite
b1.image = file.loadImage("/sys/pics/Block4.png")
b1.scale = 1
b1.tint = color.blue
physics.initPhys b1
b1.x = 300; b1.y = 200
b1.vy = 400
// b1.rotSpeed = 30
sprDisp.sprites.push b1

b2 = new Sprite
b2.image = file.loadImage("/sys/pics/Block4.png")
b2.scale = 1
b2.tint = color.orange
physics.initPhys b2
// b2.rotSpeed = 50
sprDisp.sprites.push b2
b2.x = 350; b2.y = 400


ground = new Sprite
ground.image = file.loadImage("/sys/pics/Block4.png")
ground.scale = 4
ground.tint = color.yellow
sprDisp.sprites.push ground
ground.x = 480; ground.y = -55
physics.initPhys ground, true

dt = 1/60
while not key.available
	if mouse.button(0) then
		b2.static = true
		b2.x = mouse.x
		b2.y = mouse.y
		b2.vx = 0
		b2.vy = 0
	else
		b2.static = false
	end if

	if mouse.button(1) then
		b2.rotation = b2.rotation + 1
	end if

	physics.updateMany sprDisp.sprites, dt
	yield
end while
key.clear
