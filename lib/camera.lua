local class = require('lib.class')
local vec3 = require('lib.vec3')

---Represents a camera
---@class camera
---@overload fun(): camera
---@field position vec3
---@field target vec3
local camera = class()

---Init the camera
function camera:new()
	self.position = vec3()
	self.target = vec3()
end

return camera
