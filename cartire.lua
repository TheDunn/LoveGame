CarTire = Object.extend(Object)

function CarTire.new(
    self,
    world,
    diameter,
    thickness,
    max_forward_speed,
    max_backward_speed,
    max_drive_force
    max_lateral_impulse
)
    self.body = love.physics.newBody(world, 0, 0, "dynamic")  -- pos = (0, 0)
    local rect = love.physics.newRectangleShape(thickness, diameter)
    fixture = love.physics.newFixture(self.body, rect, 1)  -- density = 1 TODO: do we need a pointer to this?
    self.body.SetUserData(self)

    self.max_forward_speed = max_forward_speed
    self.max_backward_speed = max_backward_speed
    self.max_drive_force = max_drive_force
    self.max_lateral_impulse = max_lateral_impulse
end

function CarTire.get_lateral_velocity(self)
    right_normal_x, right_normal_y = self.body.GetWorldVector(1, 0)
    right_normal = Vector2D(right_normal_x, right_normal_y)

    vel_x, vel_y = self.body.GetLinearVelocity()
    velocity = Vector2D(vel_x, vel_y)

    return velocity:project_onto(right_normal)
end

function CarTire.get_forward_normal(self)
    forward_normal_x, forward_normal_y = self.body.GetWorldVector(0, 1)
    return Vector2D(forward_normal_x, forward_normal_y)
end

function CarTire.get_forward_velocity(self)
    forward_normal = self.get_forward_normal()

    vel_x, vel_y = self.body.GetLinearVelocity()
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

    world_center_x, world_center_y = self.body.GetWorldCenter()
    self.body.applyLinearImpulse(impulse_vec.x, impulse_vec.y, world_center_x, world_center_y)

    -- kill angular velocity to stop tire rotating around its center
    angular_x, angular_y = self.body.GetAngularVelocity()
    impulse_vec = Vector2D(angular_x, angular_y)
    impulse_vec.scale(-0.1 * self.body.GetInertia())
    self.body.ApplyAngularImpulse(impulse_vec.x, impulse_vec.y)

    -- apply drag in forward direction
    forward_vel = self.get_forward_velocity()
    drag_force = forward_vel.copy()
    drag_force.scale(-2 * forward_vel.magnitude())
    self.body.ApplyForce(drag_force.x, drag_force.y, world_center_x, world_center_y)
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

    world_center_x, world_center_y = self.body.GetWorldCenter()
    force_vec = forward_normal.copy()
    force_vec.scale(force_scale)
    self.body.ApplyForce(force_vec.x, force_vec.y, world_center_x, world_center_y)
end

function CarTire.destroy(self)
    self.body.GetWorld().DestroyBody(self.body)
end