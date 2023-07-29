clear

import "physics"
import "shapes"

sprDisp = display(4)

control = null

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

createCircle = function(x, y, tint, scale=1)
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

createWalls = function
    b = createBlock(480, -75, color.yellow, 4)
    b.setStatic true

    b = createBlock(-130, 480, color.yellow, 4)
    b.rotation = 90
    b.setStatic true

    b = createBlock(1090, 480, color.yellow, 4)
    b.rotation = 90
    b.setStatic true
end function

scenarioBalls = function
    createWalls

    for i in range(25)
        clr = color.rgb(rnd * 255, rnd * 255, rnd * 255)

        createCircle(display(5).width * rnd, display(5).height * rnd, clr, 1)
    end for
end function

scenarioBallsCollision = function
    createWalls

    c = createCircle(300, 500, color.yellow)
    c.vx = 200

    c = createCircle(600, 500, color.green)
    c.vx = -200
end function

scenarioBallSlope = function
    b = createBlock(400, 400, color.blue, 1)
    b.setStatic true
    b.rotation = -20

    b = createBlock(620, 200, color.blue, 1)
    b.setStatic true
    b.rotation = 20

    createCircle(350, 500, color.yellow, 1)
end function

scenarioBalls

dt = 1/60
while not key.available
    physics.updateMany sprDisp.sprites, dt

    if control != null then
        if mouse.button(0) then
            control.x = mouse.x
            control.y = mouse.y
            control.vx = 0
            control.vy = 0
        end if

        if mouse.button(1) then
            control.rotation = control.rotation + 1
        end if
    end if

    yield
end while
key.clear
