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

b1 = createBlock(600, 300, color.blue, 2)
b1.setStatic true
b1.rotation = 20

for i in range(20)
    clr = color.rgb(rnd * 255, rnd * 255, rnd * 255)

    createCircle(display(5).width * rnd, display(5).height * rnd, clr, 1)
end for

b = createBlock(480, -55, color.yellow, 4)
b.setStatic true

b = createBlock(-75, 480, color.yellow, 4)
b.rotation = 90
b.setStatic true

b = createBlock(1070, 480, color.yellow, 4)
b.rotation = 90
b.setStatic true

control = b1

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
