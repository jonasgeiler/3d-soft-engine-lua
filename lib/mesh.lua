local Vector3 = require('lib.vector3')

---@class Mesh
---@field position Vector3
---@field rotation Vector3
---@field vertices Vertex[]
---@field faces Face[]
---@field texture Texture?
local Mesh = {}
Mesh.__index = Mesh

---Creates a new mesh instance
---@param vertices Vertex[]?
---@param faces Face[]?
---@param rotation Vector3?
---@param position Vector3?
---@param texture Texture?
---@return Mesh
---@nodiscard
function Mesh.new(vertices, faces, rotation, position, texture)
	local self = setmetatable({}, Mesh)

	self.vertices = vertices or {}
	self.faces = faces or {}
	self.rotation = rotation or Vector3.new()
	self.position = position or Vector3.new()
	self.texture = texture

	return self
end

return Mesh
