Car = Object.extend(Object)

function Car.new(self, character)
    -- Load character sprite
    self.character = character
    self.sprite = love.graphics.newImage(string.format("assets/characters/%s.png", character))
    self.x_size = self.sprite:getWidth()
    self.y_size = self.sprite:getHeight()

    --TEMP
    local mapFile = math.random(1, 3) == 1 and "assets/maps/road.txt" or (math.random(1, 2) == 1 and "assets/maps/road2.txt" or "assets/maps/road3.txt")

    -- Tilemap
    self.tilemap = self:loadTilemap(mapFile)
    local startX, startY = self:getStartPosition("S");

    -- Initialize position & physics variables
    self.pos = Vector2D(startX or 0, startY or 0)  -- Use provided position or default to (0,0)
    self.vel = Vector2D(0, 0)

    -- Movement settings
    self.normal_acceleration = 50000
    self.max_speed = 1000
    self.rotation = 0

    -- Car path
    self.path = self:generatePath() -- Generate the path based on the tilemap
    self.path_index = 1 -- Start from the first point in the path
    self.is_destroyed = false
end

-- Function to set the car's starting position to the first road tile ('R')
function Car.getStartPosition(self, character)
    for y = 1, self.tilemap.height do
        for x = 1, self.tilemap.width do
            if self.tilemap.tiles[y][x] == character then
                return x * 16, y * 16
            end
        end
    end
    return nil, nil -- Return nil if no position is found
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

function Car.generatePath(self)
    local path = {}
    local visited = {}
    local startX, startY = nil, nil

    for y = 1, self.tilemap.height do
        for x = 1, self.tilemap.width do
            if self.tilemap.tiles[y][x] == "S" then
                startX, startY = x, y
                break
            end
        end
        if startX then break end
    end

    local function isRoad(x, y)
        return x > 0 and y > 0 and x <= self.tilemap.width and y <= self.tilemap.height and
               (self.tilemap.tiles[y][x] == "R" or self.tilemap.tiles[y][x] == "S") and
               not visited[y * self.tilemap.width + x]
    end

    local function tracePath(x, y)
        table.insert(path, Vector2D(x * 16, y * 16))
        visited[y * self.tilemap.width + x] = true

        local directions = {{0, -1}, {0, 1}, {-1, 0}, {1, 0}}
        for _, dir in ipairs(directions) do
            local nx, ny = x + dir[1], y + dir[2]
            if isRoad(nx, ny) then
                tracePath(nx, ny)
            end
        end
    end

    if startX and startY then
        tracePath(startX, startY)
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
        -- Update path index or loop back
        self.path_index = self.path_index + 1
        if self.path_index > #self.path then
            self.path_index = 1 -- Loop back to start
            self.is_destroyed = true
        end
    end

    direction:normalise()
    local angle = math.atan2(direction.y, direction.x)
    self.rotation = angle -- Store for drawing

    -- Movement
    direction:scale(self.normal_acceleration * dt)
    self.vel:add(direction)

    if self.vel:magnitude() > self.max_speed then
        self.vel:normalise()
        self.vel:scale(self.max_speed)
    end

    self.vel:scale(dt)
    self.pos:add(self.vel)
end

function Car.draw(self)
    -- Calculate the position to draw the sprite in the middle
    local rounded_x = math.floor(self.pos.x - self.x_size / 2) + 14
    local rounded_y = math.floor(self.pos.y - self.y_size / 2) + 14

    -- Draw the sprite with the correct rotation (adjusted pivot at the center)
    love.graphics.draw(self.sprite, rounded_x, rounded_y, self.rotation + math.pi / 2, 1, 1, self.x_size / 2, self.y_size / 2)
end

function Car.drawPath(self)
    for i = 1, #self.path - 1 do
        local p1, p2 = self.path[i], self.path[i + 1]
        love.graphics.setColor(1, 0, 0, 1) 
        love.graphics.line(p1.x, p1.y, p2.x, p2.y)
    end
    love.graphics.setColor(1, 1, 1)
end