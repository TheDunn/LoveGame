Tile = {}
Tile.__index = Tile

function Tile:new(x, y, tileSize, imageWidth, imageHeight, properties)
    local self = setmetatable({}, Tile)

    -- The coordinates (x, y) represent the tile's position in the tilesheet, in grid space
    -- So we calculate the pixel position based on the tile size and the grid position.
    local pixelX = x * tileSize
    local pixelY = y * tileSize

    self.quad = love.graphics.newQuad(pixelX, pixelY, tileSize, tileSize, imageWidth, imageHeight)

    self.properties = properties or {}

    return self
end

function Tile:getProperty(property)
    return self.properties[property]
end

function Tile:setProperty(property, value)
    self.properties[property] = value
end