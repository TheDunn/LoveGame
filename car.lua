Car = Object.extend(Object)

function Car.new(self, character, map)
    -- load character sprite
    self.character = character
    self.sprite = love.graphics.newImage(string.format("assets/characters/%s.png", character))
    self.x_size = self.sprite:getWidth()
    self.y_size = self.sprite:getHeight()

    -- init position & physics variables
    self.pos = Vector2D(0, 0)
    self.vel = Vector2D(0, 0)

    self.normal_acceleration = 200
	self.drag_active = 0.9
	self.drag_passive = 0.7
	self.max_speed = 800
	self.max_speed_sq = self.max_speed * self.max_speed
	self.boost_speed = 1200
	self.has_boost = true

    self.tilemap = self:loadTilemap(map)
    self.path = self:generatePath() -- Generate the path based on the tilemap
    self.path_index = 1
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
    local tile_size = 32  -- Assuming tile size of 32x32
    for y = 1, self.tilemap.height do
        for x = 1, self.tilemap.width do
            if self.tilemap.tiles[y][x] == "R" then
                print(x, y)
                -- Add the position of road tiles to the path (scaled by tile size)
                table.insert(path, Vector2D(x * tile_size, y * tile_size))
            end
        end
    end
    return path
end

-- Update the car's position to follow the path
function Car.update(self, dt)
    -- Check if there's a path to follow
    if #self.path == 0 then return end

    local target = self.path[self.path_index]
    local direction = target - self.pos
    local distance = direction:length()

    if distance < 5 then
        self.path_index = self.path_index + 1
        if self.path_index > #self.path then
            self.path_index = 1 -- loop the path if you want to make the car go in a loop
        end
        target = self.path[self.path_index]
        direction = target - self.pos
    end

    -- Normalize the direction vector
    direction:normalizeInplace()

    -- Apply acceleration to move towards the target
    self.vel = self.vel + direction * self.normal_acceleration * dt
    if self.vel:length() > self.max_speed then
        self.vel:normalizeInplace()
        self.vel = self.vel * self.max_speed
    end

    -- Update position based on velocity
    self.pos = self.pos + self.vel * dt
end

function Car.draw(self)
    love.graphics.draw(self.sprite, round(self.pos.x - self.x_size/2), round(self.pos.y - self.y_size/2))
end