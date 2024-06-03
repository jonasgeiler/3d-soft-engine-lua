local class = require('lib.class')
local vec3 = require('lib.vec3')

---Represents a mesh
---@class mesh
---@overload fun(vertices: vec3[]?, rotation: vec3?, position: vec3?): mesh
---@field position vec3
---@field rotation vec3
---@field vertices vec3[]
local mesh = class()

---Init the mesh
---@param vertices vec3[]?
---@param rotation vec3?
---@param position vec3?
function mesh:new(vertices, rotation, position)
	self.vertices = vertices or {}
	self.rotation = rotation or vec3()
	self.position = position or vec3()
end

return mesh
