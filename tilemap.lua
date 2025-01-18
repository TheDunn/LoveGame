TileMap = {}
TileMap.__index = TileMap

function TileMap:new(mapData)
    local self = setmetatable({}, TileMap)
    self.width = #mapData[1]
    self.height = #mapData
    self.layers = mapData  -- Each entry in mapData is a layer of tiles
    return self
end

-- Draw function, rendering each layer in order
function TileMap:draw(tileSet, offsetX, offsetY)
    for _, layer in ipairs(self.layers) do
        for y = 1, #layer do
            for x = 1, #layer[y] do
                local tileName = layer[y][x]
                local tile = tileSet:getTileByName(tileName)
                if tile then
                    love.graphics.draw(
                        tileSet.image,
                        tile.quad,
                        (x - 1) * tileSet.tileWidth + offsetX,
                        (y - 1) * tileSet.tileHeight + offsetY
                    )
                end
            end
        end
    end
end
