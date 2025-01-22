

TileSet = {}
TileSet.__index = TileSet

function TileSet:new(imagePath, tileSize, gap)
    require "tile"

    local self = setmetatable({}, TileSet)
    self.image = love.graphics.newImage(imagePath)
    self.tiles = {}

    self.tileWidth = tileSize;
    self.tileHeight = tileSize;

    local sheetWidth = self.image:getWidth()
    local sheetHeight = self.image:getHeight()

    local numTilesX = math.floor(sheetWidth / tileSize)
    local numTilesY = math.floor(sheetHeight / tileSize)

    local tileIndex = 1
    for y = 0, numTilesY - 1 do
        for x = 0, numTilesX - 1 do
            local tileName = "tile_" .. x .. "_" .. y

            self.tiles[tileName] = Tile:new(x, y, tileSize + gap, sheetWidth, sheetHeight)
            tileIndex = tileIndex + 1
        end
    end

    return self
end

function TileSet:getTileByName(name)
    return self.tiles[name]
end