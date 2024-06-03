local class = require('lib.class')

---@class vec2
---@overload fun(x: number?, y: number?): vec2
---@field x number
---@field y number
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

return vec2
