Vector2D = Object.extend(Object)

function Vector2D.new(self, x, y)
    self.x = x
    self.y = y
end

function Vector2D.magnitude(self)
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector2D.normalise(self)
	local mag = self:magnitude()
	if mag <= 0 then
        self.x = 0
        self.y = 0
    else
        self.x = self.x / mag
        self.y = self.y / mag
    end
end

function Vector2D.scale(self, scalar)
    self.x = self.x * scalar
    self.y = self.y * scalar
end

function Vector2D.add(self, vector)
	self.x = self.x + vector.x
    self.y = self.y + vector.y
end

function Vector2D.subtract(self, vector)
	self.x = self.x - vector.x
    self.y = self.y - vector.y
end

function Vector2D.dot_product(self, vector)
	return self.x * vector.x + self.y * vector.y
end

function Vector2D.project_onto(self, vector)
    scale = self:dot_product(vector) / vector:dot_product(vector)
    return Vector2D(scale * vector.x, scale * vector.y)
end

function Vector2D.copy(self)
    return Vector2D(self.x, self.y)
end

function Vector2D.to_string(self)
    return string.format("(%.4f, %.4f)", self.x, self.y)
end
