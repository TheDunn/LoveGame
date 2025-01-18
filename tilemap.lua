TileMap = Object.extend(Object)

function TileMap.new(self, name)
    -- load tilemap from txt file
    local map_file = io.open(string.format("assets/maps/%s.txt", name), "r")
    self.map = {}
    for line in map_file:lines() do
        local row = {}
        for tile_ch in string.gmatch(line, ".") do
            table.insert(row, tonumber(tile_ch))
        end
        table.insert(self.map, row)
    end
    map_file:close()
end

function TileMap.draw(self, tileset, x_init, y_init)
    for i,row in ipairs(self.map) do
        for j,tile in ipairs(row) do
            tileset.draw_tile(
                tileset, tile,
                x_init + (j-1) * tileset.tile_size,
                y_init + (i-1) * tileset.tile_size
            )
        end
    end
end