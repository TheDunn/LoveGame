local Tile = require "Tiles.tile"

RoadTile = setmetatable({}, {__index = Tile})
RoadTile.__index = RoadTile

function RoadTile:new(x, y, tileSize, image)
    local self = Tile.new(self, x, y, tileSize, image, {drivable = false})
    return self
end

return RoadTile