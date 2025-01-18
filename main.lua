-- https://sheepolution.com/learn/book/contents
-- TODO: https://love2d.org/wiki/Canvas, https://sheepolution.com/learn/book/22

function love.load()
    Object = require "classic"
    require "utils"
    require "vector"
    require "tileset"
    require "tilemap"
    require "canvas"
    require "player"

    -- load tileset
    tileset = TileSet("example", 16)

    -- load tilemap
    tilemap = TileMap("example")

    -- create canvas
    canvas = create_canvas(800, 600)

    -- draw tilemap to canvas
    set_canvas(canvas)
    tilemap.draw(tilemap, tileset, 0, 0)
    unset_canvas()

    -- initialise player
    player = Player("example")

end

function love.update(dt)
    player:update(dt)
end

function love.draw()
    -- love.graphics.scale(2)
    draw_canvas(canvas, 0, 0)
    player:draw()
end