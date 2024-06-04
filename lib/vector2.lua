local setmetatable = setmetatable
local type = type
local math = math

---@class Vector2
---@field x number
---@field y number
---@operator add(Vector2): Vector2
---@operator add(number): Vector2
---@operator sub(Vector2): Vector2
---@operator sub(number): Vector2
---@operator mul(Vector2): Vector2
---@operator mul(number): Vector2
---@operator div(Vector2): Vector2
---@operator div(number): Vector2
local Vector2 = {}
Vector2.__index = Vector2

---Creates a new vector2 instance
---@param x number?
---@param y number?
---@return Vector2
---@nodiscard
function Vector2.new(x, y)
	local self = setmetatable({}, Vector2)

	self.x = x or 0
	self.y = y or 0

	return self
end

---Get the squared length of the vector
---@return number
---@nodiscard
function Vector2:length_squared()
	return self.x * self.x + self.y * self.y
end

---Get the length of the vector
---@return number
---@nodiscard
function Vector2:length()
	return math.sqrt(self:length_squared())
end

---Add two vectors or a vector and a number
---@param a Vector2|number
---@param b Vector2|number
---@return Vector2
---@nodiscard
function Vector2.__add(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be Vector2
		return Vector2.new(a + b.x, a + b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be Vector2
		return Vector2.new(a.x + b, a.y + b)
	end

	return Vector2.new(a.x + b.x, a.y + b.y)
end

---Subtract two vectors or a vector and a number
---@param a Vector2|number
---@param b Vector2|number
---@return Vector2
---@nodiscard
function Vector2.__sub(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be Vector2
		return Vector2.new(a - b.x, a - b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be Vector2
		return Vector2.new(a.x - b, a.y - b)
	end

	return Vector2.new(a.x - b.x, a.y - b.y)
end

---Multiply two vectors or a vector and a number
---@param a Vector2|number
---@param b Vector2|number
---@return Vector2
---@nodiscard
function Vector2.__mul(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be Vector2
		return Vector2.new(a * b.x, a * b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be Vector2
		return Vector2.new(a.x * b, a.y * b)
	end

	return Vector2.new(a.x * b.x, a.y * b.y)
end

---Divide two vectors or a vector and a number
---@param a Vector2|number
---@param b Vector2|number
---@return Vector2
---@nodiscard
function Vector2.__div(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be Vector2
		return Vector2.new(a / b.x, a / b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be Vector2
		return Vector2.new(a.x / b, a.y / b)
	end

	return Vector2.new(a.x / b.x, a.y / b.y)
end

return Vector2
