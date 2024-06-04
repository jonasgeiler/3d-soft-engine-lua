local class = require('lib.class')
local Vector3 = require('lib.vector3')

---@class Camera
---@overload fun(position: Vector3?, target: Vector3?): Camera
---@field position Vector3
---@field target Vector3
local Camera = class()

---Creates a new camera instance
---@param position Vector3?
---@param target Vector3?
function Camera:new(position, target)
	self.position = position or Vector3()
	self.target = target or Vector3()
end

return Camera
