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

    self.tiles["RoadTileHorTopLeft"] = RoadTile:new(8, 17, tileSize, self.image)
    self.tiles["RoadTileHorTopRight"] = RoadTile:new(7, 17, tileSize, self.image)

    self.tiles["RoadTileHorTop"] = RoadTile:new(1, 15, tileSize, self.image)
    self.tiles["RoadTileHor"] = RoadTile:new(1, 16, tileSize, self.image)
    self.tiles["RoadTileHorBottom"] = RoadTile:new(1, 17, tileSize, self.image)

    self.tiles["RoadTileHorTopCrossing"] = RoadTile:new(0, 15, tileSize, self.image)
    self.tiles["RoadTileHorCrossing"] = RoadTile:new(0, 16, tileSize, self.image)
    self.tiles["RoadTileHorBottomCrossing"] = RoadTile:new(0, 17, tileSize, self.image)

    self.tiles["RoadTileHorBottomLeft"] = RoadTile:new(7, 16, tileSize, self.image)
    self.tiles["RoadTileHorBottomRight"] = RoadTile:new(8, 16, tileSize, self.image)

    self.tiles["RoadTileVerLeftCornerRight"] = RoadTile:new(5, 16, tileSize, self.image)
    self.tiles["RoadTileVerLeft"] = RoadTile:new(2, 17, tileSize, self.image)
    self.tiles["RoadTileVer"] = RoadTile:new(3, 17, tileSize, self.image)
    self.tiles["RoadTileVerRight"] = RoadTile:new(4, 17, tileSize, self.image)

    self.tiles["RoadTileTurnLeftTop"] = RoadTile:new(8, 17, tileSize, self.image)

    return self
end

function TileSet:getTileByName(name)
    return self.tiles[name]
end