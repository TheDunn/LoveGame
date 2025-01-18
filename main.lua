-- https://sheepolution.com/learn/book/contents
-- TODO: https://love2d.org/wiki/Canvas, https://sheepolution.com/learn/book/22

local json = require "json"

function love.load()
    Object = require "classic"
    require "utils"
    require "vector"
    require "tileset"
    require "tilemap"
    require "canvas"
    require "player"
    require "car"
    require "cartire"

    love.graphics.setDefaultFilter("nearest", "nearest")
    tileset = TileSet:new("assets/tiles/tilemap.png", 16)

    -- load tileset
    local mapData = love.filesystem.read("assets/maps/example.json")
    local map = json.parse(mapData)

    tilemap = TileMap:new(map)

    -- create canvas
    canvas = create_canvas(800, 600)

    -- draw tilemap to canvas
    set_canvas(canvas)
    tilemap:draw(tileset, 0, 0)
    unset_canvas()

    -- initialise physics
    love.physics.setMeter(20) -- 1 meter = 20 pixels
    world = love.physics.newWorld(0, 0, true) -- no gravity, bodies are able to sleep

    -- initialise player
    player = CarTire(world, 2, 0.5, 100, -20, 150, 2.5, "van")
    -- player = Player("van")

    -- initialise other cars
    --car = Car("van", "assets/maps/road.txt")
end

function love.update(dt)
    --player:update(dt)
    -- car:update(dt)
    player:update()
end

function love.draw()   
    love.graphics.push()
    love.graphics.scale(2) 
    draw_canvas(canvas, 0, 0)
    love.graphics.pop()
    love.graphics.scale(1.5)
    player:draw()
    --car:draw()
end