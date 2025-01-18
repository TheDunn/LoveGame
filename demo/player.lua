Player = Object.extend(Object)

function Player.new(self, character)
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

    -- init input variables
    self.input_left = false
    self.input_right = false
    self.input_up = false
    self.input_down = false
    self.input_space = false

end

function Player.handle_input(self)
    self.input_left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
    self.input_right = love.keyboard.isDown("right") or love.keyboard.isDown("d")
	if self.input_left and self.input_right then
		self.input_left = false
		self.input_right = false
	end

    self.input_up = love.keyboard.isDown("up") or love.keyboard.isDown("w")
    self.input_down = love.keyboard.isDown("down") or love.keyboard.isDown("s")
	if self.input_up and self.input_down then
		self.input_up = false
		self.input_down = false
	end

    self.input_space = love.keyboard.isDown("space")
end

function Player.acceleration(self)
	-- process input into acceleration
	local x_acc = 0
	if self.input_left then x_acc = -1
	elseif self.input_right then x_acc = 1 end

	local y_acc = 0
	if self.input_up then y_acc = -1
	elseif self.input_down then y_acc = 1 end

	local acc = Vector2D(x_acc, y_acc)

	-- compute acceleration magnitude, limited if approaching or above max speed
	local acc_mag = self.normal_acceleration
	local cur_speed = self.vel:magnitude()
	if (self.normal_acceleration + cur_speed) > self.max_speed then
		acc_mag = self.max_speed - cur_speed
		if acc_mag < 0 then acc_mag = 0 end
	end

	-- re-scale acceleration vector to desired magnitude
	acc:normalise()
	acc:scale(acc_mag)

	return acc
end

function Player.velocity(self, acc)
	-- apply one step acceleration to velocity
	self.vel:add(acc)

	-- undo acceleration if speed exceeds max
	speed = self.vel:magnitude()
	if speed > self.max_speed then
		self.vel:subtract(acc)
	end

	-- handle boost
	if not input_space then self.has_boost = true
	elseif input_space and self.has_boost then
		local boost_x_vel = 0
		if self.input_left then boost_x_vel = -1
		elseif self.input_right then boost_x_vel = 1 end

		local boost_y_vel = 0
		if self.input_up then boost_y_vel = -1
		elseif self.input_down then boost_y_vel = 1 end

		local boost_vel = Vector2D(boost_x_vel, boost_y_vel)
		boost_vel:normalise()
		boost_vel:scale(self.boost_speed)

		self.vel:add(boost_vel)

		self.has_boost = false
	end

	-- apply drag
	local drag_factor = self.drag_passive
	if self.input_left or self.input_right or self.input_up or self.input_down then
		drag_factor = self.drag_active
	end

	self.vel:scale(drag_factor)
end

function Player.update(self, dt)
	self:handle_input()
	local acc = self:acceleration()
	self:velocity(acc)

	local pos_change = self.vel:copy()
	pos_change:scale(dt)
	self.pos:add(pos_change)
end

function Player.draw(self)
    love.graphics.draw(self.sprite, round(self.pos.x - self.x_size/2), round(self.pos.y - self.y_size/2))
end