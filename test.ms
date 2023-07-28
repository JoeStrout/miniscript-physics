clear

import "physics"
import "shapes"

sprDisp = display(4)

createBlock = function(x, y, tint, scale)
    body = new Sprite
    body.image = file.loadImage("/sys/pics/Block4.png")
    body.scale = scale
    body.tint = tint
    body.x = x
    body.y = y
    physics.initPhys body
    sprDisp.sprites.push body

    return body
end function

createCircle = function(x, y, tint, scale)
    body = new Sprite
    body.image = file.loadImage("/sys/pics/shapes/Circle.png")
    body.scale = scale
    body.tint = tint
    body.x = x
    body.y = y
    physics.initPhys body, shapes.Circle(32 * scale)
    sprDisp.sprites.push body

    return body
end function

b1 = createCircle(300, 200, color.blue, 2)
b1.setStatic true

b2 = createCircle(300, 400, color.orange, 1)

// ground = new Sprite
// ground.image = file.loadImage("/sys/pics/Block4.png")
// ground.scale = 4
// ground.tint = color.yellow
// sprDisp.sprites.push ground
// ground.x = 480; ground.y = -55
// physics.initPhys ground, true

control = b2

dt = 1/60
while not key.available
    physics.updateMany sprDisp.sprites, dt

    if mouse.button(0) then
        control.x = mouse.x
        control.y = mouse.y
        control.vx = 0
        control.vy = 0
    end if

    if mouse.button(1) then
        control.rotation = control.rotation + 1
    end if
    yield
end while
key.clear
