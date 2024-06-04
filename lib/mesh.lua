local class = require('lib.class')
local vec3 = require('lib.vec3')

---Represents a mesh
---@class mesh
---@overload fun(vertices: vertex[]?, faces: face[]?, rotation: vec3?, position: vec3?, tex: texture?): mesh
---@field position vec3
---@field rotation vec3
---@field vertices vertex[]
---@field faces face[]
---@field tex texture?
local mesh = class()

---Init the mesh
---@param vertices vertex[]?
---@param faces face[]?
---@param rotation vec3?
---@param position vec3?
---@param tex texture?
function mesh:new(vertices, faces, rotation, position, tex)
	self.vertices = vertices or {}
	self.faces = faces or {}
	self.rotation = rotation or vec3()
	self.position = position or vec3()
	self.tex = tex
end

---Compute the normals of the faces
function mesh:compute_faces_normals()
	for fi = 1, #self.faces do
		local curr_face = self.faces[fi]

		local vertex_a = self.vertices[curr_face.a]
		local vertex_b = self.vertices[curr_face.b]
		local vertex_c = self.vertices[curr_face.c]

		self.faces[fi].normal = (vertex_a.normal + vertex_b.normal + vertex_c.normal) / 3
		self.faces[fi].normal:normalize()
	end
end

return mesh
