local type = type
local math = math
local class = require('lib.class')

---@class vec3
---@overload fun(x: number?, y: number?, z: number?): vec3
---@field x number
---@field y number
---@field z number
---@operator unm: vec3
---@operator add(vec3): vec3
---@operator add(number): vec3
---@operator sub(vec3): vec3
---@operator sub(number): vec3
---@operator mul(vec3): vec3
---@operator mul(number): vec3
---@operator div(vec3): vec3
---@operator div(number): vec3
local vec3 = class()

---Init the vector
---@param x number?
---@param y number?
---@param z number?
function vec3:new(x, y, z)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
end

--TODO: Remove
function vec3:__tostring()
	return 'vec3(' .. self.x .. ', ' .. self.y .. ', ' .. self.z .. ')'
end

---Negate the vector
---@return vec3
---@nodiscard
function vec3:__unm()
	return vec3(-self.x, -self.y, -self.z)
end

---Set all vector values at once
---@param x number?
---@param y number?
---@param z number?
function vec3:set(x, y, z)
	self.x = x or self.x
	self.y = y or self.y
	self.z = z or self.z
end

---Replace the vector with another one
---@param new_vec3 vec3
function vec3:replace(new_vec3)
	self.x = new_vec3.x
	self.y = new_vec3.y
	self.z = new_vec3.z
end

---Copy the vector
---@return vec3
---@nodiscard
function vec3:copy()
	return vec3(self.x, self.y, self.z)
end

---Get the squared length of the vector
---@return number
---@nodiscard
function vec3:length_squared()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

---Get the length of the vector
---@return number
---@nodiscard
function vec3:length()
	return math.sqrt(self:length_squared())
end

---Normalize the vector
function vec3:normalize()
	local len = self:length()
	if len == 0 then
		return
	end
	local num = 1 / len
	self.x = self.x * num
	self.y = self.y * num
	self.z = self.z * num
end

---Add two vectors or a vector and a number
---@param a vec3|number
---@param b vec3|number
---@return vec3
---@nodiscard
function vec3.__add(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec3
		return vec3(a + b.x, a + b.y, a + b.z)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec3
		return vec3(a.x + b, a.y + b, a.z + b)
	end

	return vec3(a.x + b.x, a.y + b.y, a.z + b.z)
end

---Subtract two vectors or a vector and a number
---@param a vec3|number
---@param b vec3|number
---@return vec3
---@nodiscard
function vec3.__sub(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec3
		return vec3(a - b.x, a - b.y, a - b.z)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec3
		return vec3(a.x - b, a.y - b, a.z - b)
	end

	return vec3(a.x - b.x, a.y - b.y, a.z - b.z)
end

---Multiply two vectors or a vector and a number
---@param a vec3|number
---@param b vec3|number
---@return vec3
---@nodiscard
function vec3.__mul(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec3
		return vec3(a * b.x, a * b.y, a * b.z)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec3
		return vec3(a.x * b, a.y * b, a.z * b)
	end

	return vec3(a.x * b.x, a.y * b.y, a.z * b.z)
end

---Divide two vectors or a vector and a number
---@param a vec3|number
---@param b vec3|number
---@return vec3
---@nodiscard
function vec3.__div(a, b)
	if type(a) == 'number' then
		-- if `a` is a number then `b` has to be vec3
		return vec3(a / b.x, a / b.y, a / b.z)
	elseif type(b) == 'number' then
		-- if `b` is a number then `a` has to be vec3
		return vec3(a.x / b, a.y / b, a.z / b)
	end

	return vec3(a.x / b.x, a.y / b.y, a.z / b.z)
end

---Check if two vectors are equal
---@param a vec3
---@param b vec3
---@return boolean
---@nodiscard
function vec3.__eq(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

---Return the dot product of two vectors
---@param a vec3
---@param b vec3
---@return number
---@nodiscard
function vec3.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

---Return the cross product of two vectors
---@param a vec3
---@param b vec3
---@return vec3
---@nodiscard
function vec3.cross(a, b)
	return vec3(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	)
end

---Transform a vector by a coordinates matrix
---@param vector vec3
---@param transformation matrix
---@return vec3
---@nodiscard
function vec3.transform_coordinates(vector, transformation)
	local w =
		(vector.x * transformation.m[4]) +
		(vector.y * transformation.m[8]) +
		(vector.z * transformation.m[12]) +
		transformation.m[16]

	return vec3(
		(
			(vector.x * transformation.m[1]) +
			(vector.y * transformation.m[5]) +
			(vector.z * transformation.m[9]) +
			transformation.m[13]
		) / w,
		(
			(vector.x * transformation.m[2]) +
			(vector.y * transformation.m[6]) +
			(vector.z * transformation.m[10]) +
			transformation.m[14]
		) / w,
		(
			(vector.x * transformation.m[3]) +
			(vector.y * transformation.m[7]) +
			(vector.z * transformation.m[11]) +
			transformation.m[15]
		) / w
	)
end

---Transform a vector by a normal matrix
---@param vector vec3
---@param transformation matrix
---@return vec3
---@nodiscard
function vec3.transform_normal(vector, transformation)
	return vec3(
		(vector.x * transformation.m[1]) +
		(vector.y * transformation.m[5]) +
		(vector.z * transformation.m[9]),

		(vector.x * transformation.m[2]) +
		(vector.y * transformation.m[6]) +
		(vector.z * transformation.m[10]),

		(vector.x * transformation.m[3]) +
		(vector.y * transformation.m[7]) +
		(vector.z * transformation.m[11])
	)
end

return vec3
