Car = Object.extend(Object)

function Car.new(self, character, map)
    -- load character sprite
    self.character = character
    self.sprite = love.graphics.newImage(string.format("assets/characters/%s.png", character))
    self.x_size = self.sprite:getWidth()
    self.y_size = self.sprite:getHeight()

    -- init position & physics variables
    self.pos = Vector2D(0, 0)  -- Initialize with a default position
    self.vel = Vector2D(0, 0)

    self.normal_acceleration = 200
    self.drag_active = 0.9
    self.drag_passive = 0.7
    self.max_speed = 800
    self.max_speed_sq = self.max_speed * self.max_speed
    self.boost_speed = 1200
    self.has_boost = true

    -- Load the tilemap and generate the path
    self.tilemap = self:loadTilemap(map)
    self.path = self:generatePath()

    -- Set car's starting position to the first road tile (if available)
    self:setStartPosition()

    -- Set the initial path index
    self.path_index = 1
end

-- Function to set the car's starting position to the first road tile ('R')
function Car.setStartPosition(self)
    for y = 1, self.tilemap.height do
        for x = 1, self.tilemap.width do
            if self.tilemap.tiles[y][x] == "R" then
                self.pos = Vector2D(x * 16, y * 16)
                return
            end
        end
    end
end

-- Function to load tilemap from a .txt file
function Car.loadTilemap(self, filename)
    local map = {tiles = {}, width = 0, height = 0}
    local file = love.filesystem.read(filename)
    
    local lines = {}
    for line in file:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    -- Store the map width and height
    map.height = #lines
    map.width = #lines[1]

    -- Process each line into tiles (e.g., '.' for empty, 'R' for road)
    for y = 1, map.height do
        map.tiles[y] = {}
        for x = 1, map.width do
            map.tiles[y][x] = lines[y]:sub(x, x)
        end
    end

    return map
end

-- Function to generate path from road tiles ('R') in the tilemap
function Car.generatePath(self)
    local path = {}
    local tile_size = 16

    for y = 1, self.tilemap.height do
        for x = 1, self.tilemap.width do
            if self.tilemap.tiles[y][x] == "R" then
                table.insert(path, Vector2D(x * tile_size, y * tile_size))
            end
        end
    end

    return path
end

function Car.update(self, dt)
    if #self.path == 0 then 
        return 
    end

    local target = self.path[self.path_index]

    if not target then
        return
    end

    local direction = target:copy()  
    direction:subtract(self.pos)

    local distance = direction:magnitude()

    if distance < 5 then
        self.path_index = self.path_index + 1
        if self.path_index > #self.path then
            self.path_index = 1
        end
        target = self.path[self.path_index]

        if not target then
            return
        end

        direction = target:copy()  
        direction:subtract(self.pos)
    end

    if distance > 0 then
        direction:normalise()
    end

    self.vel:add(direction:scale(self.normal_acceleration * dt)) 

    if self.vel:magnitude() > self.max_speed then
        self.vel:normalise()
        self.vel:scale(self.max_speed)
    end

    self.pos:add(self.vel:scale(dt))
end

function Car.draw(self)
    local rounded_x = math.floor(self.pos.x - self.x_size / 2)
    local rounded_y = math.floor(self.pos.y - self.y_size / 2)

    love.graphics.draw(self.sprite, rounded_x, rounded_y)
end