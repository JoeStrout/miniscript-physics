clear

import "physics"
import "shapes"
import "debugDraw"

debugDrawEnabled = false

sprDisp = display(4)

control = null

createBlock = function(x, y, tint, scale)
    body = new Sprite
    body.image = file.loadImage("/sys/pics/Block4.png")
    body.scale = scale
    body.tint = tint
    body.x = x
    body.y = y
    physics.initPhys(body)
    sprDisp.sprites.push(body)

    return body
end function

createCircle = function(x, y, tint, scale=1)
    body = new Sprite
    body.image = file.loadImage("/sys/pics/shapes/Circle.png")
    body.scale = scale
    body.tint = tint
    body.x = x
    body.y = y
    physics.initPhys(body, shapes.Circle(32 * scale))
    sprDisp.sprites.push(body)

    return body
end function

createWalls = function()
    b = createBlock(480, -75, color.yellow, 4)
    b.setStatic(true)

    l = createBlock(-130, 480, color.yellow, 4)
    l.rotation = 90
    l.setStatic(true)

    r = createBlock(1090, 480, color.yellow, 4)
    r.rotation = 90
    r.setStatic(true)

    return { "bottom": b, "left": l, "right": r }
end function

scenarioBalls = function()
    createWalls()
    debugDrawEnabled = false

    for i in range(25) do
        clr = color.rgb(rnd * 255, rnd * 255, rnd * 255)

        createCircle(display(5).width * rnd, display(5).height * rnd, clr, 1)
    end for
end function

scenarioBallsCollision = function()
    createWalls()

    c = createCircle(300, 500, color.yellow)
    c.vel[0] = 200

    c = createCircle(600, 500, color.green)
    c.vel[0] = -200
    globals.control = c
end function

scenarioBallSlope = function()
    b = createBlock(400, 400, color.blue, 1)
    b.setStatic(true)
    b.rotation = -20

    b = createBlock(620, 200, color.blue, 1)
    b.setStatic(true)
    b.rotation = 20

    globals.control = createCircle(350, 500, color.yellow, 1)
end function

scenarioOneBall = function()
    walls = createWalls()
    walls.left.elasticity = 1
    walls.right.elasticity = 1

    c = createCircle(600, 300, color.green)
    c.vel[0] = -500
    c.elasticity = 1
    globals.control = c
end function

scenarioSqueeze = function()
    b = createBlock(480, -75, color.yellow, 4)
    b.setStatic(true)

    b = createBlock(300, 480, color.yellow, 4)
    b.rotation = 90
    b.setStatic(true)

    b = createBlock(700, 480, color.yellow, 4)
    b.rotation = 90
    b.setStatic(true)

    createCircle(495, 300, color.green)
    createCircle(498, 400, color.orange)
    createCircle(492, 500, color.red)
end function

scenarioDragRace = function()
    createWalls()

    balls = 10
    for i in range(balls - 1) do
        clr = color.rgb(rnd * 255, rnd * 255, rnd * 255)

        createCircle(display(5).width * (i / balls) + 50, 600, clr, 1 - (i / balls) * 0.5)
    end for
end function

scenarioCannonBall = function()
    createWalls()

    impulse = 1500

    c = createCircle(100, 400, color.green, 1)
    c.vel[0] = impulse

    c = createCircle(100, 500, color.red, 1)
    c.vel[0] = impulse
    c.dragCoef = 0
end function

scenarioDragRace()

dt = 1/60
while not key.available do
    physics.updateMany(sprDisp.sprites, dt)

    if control != null then
        if mouse.button(0) then
            control.x = mouse.x
            control.y = mouse.y
            control.vel[0] = 0
            control.vel[1] = 0
        end if

        if mouse.button(1) then
            control.rotation = control.rotation + 1
        end if
    end if

    yield
end while
key.clear
