local setmetatable = setmetatable

---@class Face
---@field a integer
---@field b integer
---@field c integer
local Face = {}
Face.__index = Face

---Creates a new face instance
---@param a integer
---@param b integer
---@param c integer
---@return Face
---@nodiscard
function Face.new(a, b, c)
	local self = setmetatable({}, Face)

	self.a = a
	self.b = b
	self.c = c

	return self
end

return Face
