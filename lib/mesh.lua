local class = require('lib.class')
local Vector3 = require('lib.vector3')

---@class Mesh
---@overload fun(vertices: Vertex[]?, faces: Face[]?, rotation: Vector3?, position: Vector3?, texture: Texture?): Mesh
---@field position Vector3
---@field rotation Vector3
---@field vertices Vertex[]
---@field faces Face[]
---@field texture Texture?
local Mesh = class()

---Creates a new mesh instance
---@param vertices Vertex[]?
---@param faces Face[]?
---@param rotation Vector3?
---@param position Vector3?
---@param texture Texture?
function Mesh:new(vertices, faces, rotation, position, texture)
	self.vertices = vertices or {}
	self.faces = faces or {}
	self.rotation = rotation or Vector3()
	self.position = position or Vector3()
	self.texture = texture
end

return Mesh
