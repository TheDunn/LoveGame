Terry = Object.extend(Object)

function Terry.new(self, character)
    -- load character sprite
    self.character = character
    self.sprite = love.graphics.newImage(string.format("assets/characters/%s.png", character))
    self.x_size = self.sprite:getWidth()
    self.y_size = self.sprite:getHeight()

    -- init position & physics variables
    self.pos = Vector2D(100, 100)

end
function Terry.draw(self)
    love.graphics.draw(self.sprite, round(self.pos.x - self.x_size/2), round(self.pos.y - self.y_size/2))
end