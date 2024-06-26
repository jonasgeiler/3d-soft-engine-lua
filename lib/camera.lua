local setmetatable = setmetatable

local Vector3 = require('lib.vector3')

---@class Camera
---@field position Vector3
---@field target Vector3
---@field up Vector3
local Camera = {}
Camera.__index = Camera

---Creates a new camera instance
---@param position Vector3?
---@param target Vector3?
---@return Camera
---@nodiscard
function Camera.new(position, target)
	local self = setmetatable({}, Camera)

	self.position = position or Vector3.new()
	self.target = target or Vector3.new()
	self.up = Vector3.new(0, 1, 0)

	return self
end

return Camera
