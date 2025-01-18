Tile = {}
Tile.__index = Tile

function Tile:new(x, y, tileSize, image, properties)
    local self = setmetatable({}, Tile)

    local gap = 1
    local imageWidth, imageHeight = image:getWidth(), image:getHeight()

    -- Calculate the adjusted x and y based on gap and tile size
    x = x * (tileSize + gap)
    y = y * (tileSize + gap)

    self.quad = love.graphics.newQuad(x, y, tileSize, tileSize, imageWidth, imageHeight)
    self.properties = properties or {}

    return self
end

function Tile:getProperty(property)
    return self.properties[property]
end

function Tile:setProperty(property, value)
    self.properties[property] = value
end

return Tile