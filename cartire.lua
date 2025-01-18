-- https://www.iforce2d.net/b2dtut/top-down-car

CarTire = Object.extend(Object)

function CarTire.new(
    self,
    world,
    diameter,
    thickness,
    max_forward_speed,
    max_backward_speed,
    max_drive_force
    max_lateral_impulse,
    img_name
)
    self.body = love.physics.newBody(world, 0, 0, "dynamic")  -- pos = (0, 0)
    local rect = love.physics.newRectangleShape(thickness, diameter)
    self.fixture = love.physics.newFixture(self.body, rect, 1)  -- density = 1
    self.body.setUserData(self)

    self.max_forward_speed = max_forward_speed
    self.max_backward_speed = max_backward_speed
    self.max_drive_force = max_drive_force
    self.max_lateral_impulse = max_lateral_impulse

    -- TODO: temporary
    self.sprite = love.graphics.newImage(string.format("assets/characters/%s.png", img_name))
    self.x_size = self.sprite:getWidth()
    self.y_size = self.sprite:getHeight()
end

function CarTire.get_lateral_velocity(self)
    right_normal_x, right_normal_y = self.body.getWorldVector(1, 0)
    right_normal = Vector2D(right_normal_x, right_normal_y)

    vel_x, vel_y = self.body.getLinearVelocity()
    velocity = Vector2D(vel_x, vel_y)

    return velocity:project_onto(right_normal)
end

function CarTire.get_forward_normal(self)
    forward_normal_x, forward_normal_y = self.body.getWorldVector(0, 1)
    return Vector2D(forward_normal_x, forward_normal_y)
end

function CarTire.get_forward_velocity(self)
    forward_normal = self.get_forward_normal()

    vel_x, vel_y = self.body.getLinearVelocity()
    velocity = Vector2D(vel_x, vel_y)

    return velocity:project_onto(forward_normal)
end

function CarTire.update_friction(self)
    -- kill lateral velocity
    impulse_vec = self.get_lateral_velocity()
    impulse_vec.scale(-self.body.GetMass())
    if impulse_vec.magnitude() > self.max_lateral_impulse then
        impulse_vec.scale(self.max_lateral_impulse / impulse_vec.magnitude())
    end

    world_center_x, world_center_y = self.body.getWorldCenter()
    self.body.applyLinearImpulse(impulse_vec.x, impulse_vec.y, world_center_x, world_center_y)

    -- kill angular velocity to stop tire rotating around its center
    angular_x, angular_y = self.body.getAngularVelocity()
    impulse_vec = Vector2D(angular_x, angular_y)
    impulse_vec.scale(-0.1 * self.body.getInertia())
    self.body.applyAngularImpulse(impulse_vec.x, impulse_vec.y)

    -- apply drag in forward direction
    forward_vel = self.get_forward_velocity()
    drag_force = forward_vel.copy()
    drag_force.scale(-2 * forward_vel.magnitude())
    self.body.applyForce(drag_force.x, drag_force.y, world_center_x, world_center_y)
end

function CarTire.update_drive(self, input_forward, input_reverse)
    desired_speed = 0
    if input_forward then
        desired_speed = self.max_forward_speed
    elseif input_reverse then
        desired_speed = self.max_backward_speed
    else
        return
    end

    forward_normal = self.get_forward_normal()
    current_speed = forward_normal:dot_product(self.get_forward_velocity())

    force_scale = 0
    if desired_speed > current_speed then
        force_scale = self.max_drive_force
    elseif desired_speed < current_speed then
        force_scale = -self.max_drive_force
    else
        return
    end

    world_center_x, world_center_y = self.body.getWorldCenter()
    force_vec = forward_normal.copy()
    force_vec.scale(force_scale)
    self.body.applyForce(force_vec.x, force_vec.y, world_center_x, world_center_y)
end

-- TODO: temporary while car is impl. as single tire
function CarTire.update_turn(self, input_left, input_right)
    local desired_torque = 0
    if input_left then
        desired_torque = 15
    elseif input_right then
        desired_torque = -15
    else
        return
    end

    self.body.applyTorque(desired_torque)
end

function update(self)
    -- TODO: move this
    input_forward = love.keyboard.isDown("up") or love.keyboard.isDown("w")
    input_reverse = love.keyboard.isDown("down") or love.keyboard.isDown("s")
    input_left = love.keyboard.isDown("left") or love.keyboard.isDown("a")
    input_right = love.keyboard.isDown("right") or love.keyboard.isDown("d")

    self.update_friction()
    self.update_drive(input_forward, input_reverse)
    self.update_turn(input_left, input_right)
end

function CarTire.destroy(self)
    self.body.getWorld().destroyBody(self.body)
end

function draw(self)
    pos_x, pos_y = self.body.getPosition()
    angle_rad = self.body.getAngle()
    love.graphics.draw(self.sprite, round(pos_x - self.x_size/2), round(pos_y - self.y_size/2), angle_rad)
end
