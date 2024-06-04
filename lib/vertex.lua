local Vector3 = require('lib.vector3')
local Vector2 = require('lib.vector2')

---@class Vertex
---@field coordinates Vector3
---@field normal Vector3
---@field world_coordinates Vector3
---@field texture_coordinates Vector2
local Vertex = {}
Vertex.__index = Vertex

---Creates a new vertex instance
---@param coordinates Vector3
---@param normal Vector3
---@param world_coordinates Vector3?
---@param texture_coordinates Vector2?
---@return Vertex
---@nodiscard
function Vertex.new(coordinates, normal, world_coordinates, texture_coordinates)
	local self = setmetatable({}, Vertex)

	self.coordinates = coordinates
	self.normal = normal
	self.world_coordinates = world_coordinates or Vector3.new()
	self.texture_coordinates = texture_coordinates or Vector2.new()

	return self
end

return Vertex
