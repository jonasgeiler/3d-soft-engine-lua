local class = require('lib.class')

---@class Material
---@overload fun(texture: Texture): Material
---@field texture Texture
local Material = class()

---Creates a new material instance
---@param texture Texture
function Material:new(texture)
	self.texture = texture
end

return Material
