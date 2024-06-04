local class = require('lib.class')

---Represents a geometric face
---@class face
---@overload fun(a: integer, b: integer, c: integer): face
---@field a integer
---@field b integer
---@field c integer
local face = class()

---Init the face
---@param a integer
---@param b integer
---@param c integer
function face:new(a, b, c)
	self.a = a
	self.b = b
	self.c = c
end

return face
