local class = require('lib.class')

---Represents a material
---@class material
---@overload fun(tex: texture): material
---@field tex texture
local material = class()

---Init the material
---@param tex texture
function material:new(tex)
	self.tex = tex
end

return material
