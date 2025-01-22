-- https://sheepolution.com/learn/book/contents
-- TODO: https://love2d.org/wiki/Canvas, https://sheepolution.com/learn/book/22

local json = require "json"
local cars = {}  -- List of cars
local spawnTimer = 0
local spawnIntervalMin = 0.5
local spawnIntervalMax = 2
local carCount = 0

function love.load()
    Object = require "classic"
    require "utils"
    require "vector"
    require "tileset"
    require "tilemap"
    require "canvas"
    require "car"
    require "cartire"

    love.graphics.setDefaultFilter("nearest", "nearest")
    tileset = TileSet:new("assets/tiles/tilemap.png", 16, 1)

    -- load tileset
    local mapData = love.filesystem.read("assets/maps/level.json")
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
    -- player = CarTire(world, 2, 0.5, 100, -20, 150, 2.5, "van")

    spawnTimer = math.random(spawnIntervalMin * 1000, spawnIntervalMax * 1000) / 1000
end

function love.update(dt)
    --NPC car spawn timer
    
    spawnTimer = spawnTimer - dt
    if spawnTimer <= 0 then
        local car = Car("van")
        if car then
            table.insert(cars, car)
            carCount = carCount + 1
        else
            print("Warning: Failed to create car instance.")
        end
        spawnTimer = math.random(spawnIntervalMin * 1000, spawnIntervalMax * 1000) / 1000
    end

    for i = #cars, 1, -1 do
        local car = cars[i]
        car:update(dt)
        if car.is_destroyed then
            table.remove(cars, i)  -- Remove destroyed car from the list
        end
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(2)
    draw_canvas(canvas, 0, 0)
    
    -- Draw all cars
    for _, car in ipairs(cars) do
        -- car:drawPath()
        car:draw()
    end
    love.graphics.pop()
end