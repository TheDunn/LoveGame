local GrassTile = require "Tiles/GrassTile"
local RoadTile = require "Tiles/RoadTile"
local TreeTile = require "Tiles/TreeTile"

TileSet = {}
TileSet.__index = TileSet

function TileSet:new(imagePath, tileSize)
    local self = setmetatable({}, TileSet)
    self.image = love.graphics.newImage(imagePath)
    self.tileWidth = tileSize
    self.tileHeight = tileSize
    self.tiles = {}

    self.tiles["GrassTile"] = GrassTile:new(1, 1, tileSize, self.image)
    self.tiles["RoadTile"] = RoadTile:new(9, 16, tileSize, self.image)
    self.tiles["TreeTile"] = TreeTile:new(22, 9, tileSize, self.image)
    self.tiles["TreeTile1"] = TreeTile:new(22, 10, tileSize, self.image)

    self.tiles["RoadTileHorTop"] = RoadTile:new(1, 15, tileSize, self.image)
    self.tiles["RoadTileHor"] = RoadTile:new(1, 16, tileSize, self.image)
    self.tiles["RoadTileHorBottom"] = RoadTile:new(1, 17, tileSize, self.image)

    self.tiles["RoadTileTurnLeftTop"] = RoadTile:new(8, 17, tileSize, self.image)

    return self
end

function TileSet:getTileByName(name)
    return self.tiles[name]
end