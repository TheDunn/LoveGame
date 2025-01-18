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

    -- initialise player
    player = Player("van")

    -- initialise other cars
    car = Car("van", "assets/maps/road.txt")
end

function love.update(dt)
    player:update(dt)
    -- car:update(dt) 
end

function love.draw()   
    love.graphics.push()
    love.graphics.scale(2) 
    draw_canvas(canvas, 0, 0)
    love.graphics.pop()
    love.graphics.scale(1.5) 
    player:draw()
    car:draw()
end