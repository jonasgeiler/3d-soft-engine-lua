---@class Material
---@field texture Texture
local Material = {}
Material.__index = Material

---Creates a new material instance
---@param texture Texture
---@return Material
---@nodiscard
function Material.new(texture)
	local self = setmetatable({}, Material)

	self.texture = texture

	return self
end

return Material
