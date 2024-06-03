local class = require('lib.class')

---@class vec2
---@overload fun(x: number?, y: number?): vec2
---@field x number
---@field y number
---@operator add(vec2): vec2
---@operator add(number): vec2
---@operator sub(vec2): vec2
---@operator sub(number): vec2
---@operator mul(vec2): vec2
---@operator mul(number): vec2
---@operator div(vec2): vec2
---@operator div(number): vec2
local vec2 = class()

---Init the 2-dimensional vector
---@param x number?
---@param y number?
function vec2:new(x, y, z)
	self.x = x or 0
	self.y = y or 0
end

--TODO: Remove
function vec2:__tostring()
	return 'vec2(' .. self.x .. ', ' .. self.y .. ')'
end

---Get the squared length of the vector
---@return number
---@nodiscard
function vec2:length_squared()
	return self.x * self.x + self.y * self.y
end

---Get the length of the vector
---@return number
---@nodiscard
function vec2:length()
	return math.sqrt(self:length_squared())
end

---Add two vectors or a vector and a number
---@param a vec2|number
---@param b vec2|number
---@return vec2
---@nodiscard
function vec2.__add(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec2
		return vec2(a + b.x, a + b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec2
		return vec2(a.x + b, a.y + b)
	end

	return vec2(a.x + b.x, a.y + b.y)
end

---Subtract two vectors or a vector and a number
---@param a vec2|number
---@param b vec2|number
---@return vec2
---@nodiscard
function vec2.__sub(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec2
		return vec2(a - b.x, a - b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec2
		return vec2(a.x - b, a.y - b)
	end

	return vec2(a.x - b.x, a.y - b.y)
end

---Multiply two vectors or a vector and a number
---@param a vec2|number
---@param b vec2|number
---@return vec2
---@nodiscard
function vec2.__mul(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec2
		return vec2(a * b.x, a * b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec2
		return vec2(a.x * b, a.y * b)
	end

	return vec2(a.x * b.x, a.y * b.y)
end

---Divide two vectors or a vector and a number
---@param a vec2|number
---@param b vec2|number
---@return vec2
---@nodiscard
function vec2.__div(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec2
		return vec2(a / b.x, a / b.y)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec2
		return vec2(a.x / b, a.y / b)
	end

	return vec2(a.x / b.x, a.y / b.y)
end


return vec2
