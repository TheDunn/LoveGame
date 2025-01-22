TileMap = {}
TileMap.__index = TileMap

function TileMap:new(mapData)
    local self = setmetatable({}, TileMap)
    self.layers = mapData  -- Each entry in mapData is a layer of tiles
    return self
end

-- Draw function, rendering each layer in order
function TileMap:draw(tileSet, offsetX, offsetY)
    for _, layer in ipairs(self.layers) do
        for tileIndex = 1, #layer do
            local tileData = layer[tileIndex]

            print(tileData.name, tileData.x, tileData.y)

            if tileData then
                local tile = tileSet:getTileByName(tileData.name)
                if tile then 
                    love.graphics.draw(
                        tileSet.image,
                        tile.quad,
                        (tileData.x - 1) * tileSet.tileWidth + offsetX,
                        (tileData.y - 1) * tileSet.tileHeight + offsetY
                    )
                end
            end
        end
    end
end
