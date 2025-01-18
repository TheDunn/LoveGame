Terry = Object.extend(Object)

function Terry.new(self, character)
    -- load character sprite
    self.character = character
    self.sprite = love.graphics.newImage(string.format("assets/characters/%s.png", character))
    self.x_size = self.sprite:getWidth()
    self.y_size = self.sprite:getHeight()

end
function Terry.draw(self)
    love.graphics.draw(self.sprite, 100, 200)
end