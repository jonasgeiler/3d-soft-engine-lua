local class = require('lib.class')

---@class Face
---@overload fun(a: integer, b: integer, c: integer): Face
---@field a integer
---@field b integer
---@field c integer
local Face = class()

---Creates a new face instance
---@param a integer
---@param b integer
---@param c integer
function Face:new(a, b, c)
	self.a = a
	self.b = b
	self.c = c
end

return Face
