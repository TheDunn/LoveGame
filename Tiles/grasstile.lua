local Tile = require "Tiles.tile"

GrassTile = setmetatable({}, {__index = Tile})
GrassTile.__index = GrassTile

function GrassTile:new(x, y, tileSize, image)
    local self = Tile.new(self, x, y, tileSize, image, {drivable = true})
    return self
end

return GrassTile