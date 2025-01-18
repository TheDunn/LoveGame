function create_canvas(x_size, y_size)
    local canvas = love.graphics.newCanvas(x_size, y_size)
    return canvas
end

function set_canvas(canvas)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setBlendMode("alpha")
end

function unset_canvas()
    love.graphics.setCanvas()
end

function draw_canvas(canvas, x_pos, y_pos)
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas, x_pos, y_pos)
end
