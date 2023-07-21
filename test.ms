clear

import "physics"

sprDisp = display(4)

b1 = new Sprite
b1.image = file.loadImage("/sys/pics/Block4.png")
b1.scale = 0.5
physics.initPhys b1
b1.x = 300; b1.y = 300
b1.rotSpeed = 30
sprDisp.sprites.push b1

b2 = new Sprite
b2.image = file.loadImage("/sys/pics/Block4.png")
b2.scale = 0.5
physics.initPhys b2
//b2.rotSpeed = -360
sprDisp.sprites.push b2
b2.x = 350; b2.y = 400


ground = new Sprite
ground.image = file.loadImage("/sys/pics/Block4.png")
ground.scale = 4
ground.tint = color.yellow
sprDisp.sprites.push ground
ground.x = 480; ground.y = -55
physics.initPhys ground, 0

dt = 1/60
while not key.available
	physics.updateMany sprDisp.sprites, dt
	yield
end while
key.clear

