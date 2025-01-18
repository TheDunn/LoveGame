TileSet = Object.extend(Object)

function TileSet.new(self, name, tile_size)
    -- load tileset data
    self.name = name
    self.img = love.graphics.newImage(string.format("assets/tiles/%s.png", name))
    self.tile_size = tile_size
    self.img_width = self.img:getWidth()
    self.img_height = self.img:getHeight()

    assert(
        self.img_width % tile_size == 0,
        "tileset image width must be a whole multiple of tile_size"
    )
    assert(
        self.img_height % tile_size == 0,
        "tileset image height must be a whole multiple of tile_size"
    )

    -- create tileset table
    self.tiles = {}
    for row = 0, (self.img_height / tile_size) - 1 do
        for col = 0, (self.img_width / tile_size) - 1 do
            table.insert(
                self.tiles,
                love.graphics.newQuad(
                    col * tile_size, row * tile_size,
                    tile_size, tile_size,
                    self.img_width, self.img_height
                )
            )
        end
    end
end

function TileSet.draw_tile(self, tile, x_pos, y_pos)
    assert (
        tile >= 1 and tile <= #self.tiles,
        string.format("tile index %d out of range", tile)
    )
    love.graphics.draw(self.img, self.tiles[tile], x_pos, y_pos)
end
