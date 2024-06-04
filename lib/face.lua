local class = require('lib.class')

---Represents a geometric face
---@class face
---@overload fun(a: integer, b: integer, c: integer, normal: vec3?): face
---@field a integer
---@field b integer
---@field c integer
---@field normal vec3?
local face = class()

---Init the face
---@param a integer
---@param b integer
---@param c integer
---@param normal vec3?
function face:new(a, b, c, normal)
	self.a = a
	self.b = b
	self.c = c
	self.normal = normal
end

return face
