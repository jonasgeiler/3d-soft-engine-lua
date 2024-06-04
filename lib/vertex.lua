local class = require('lib.class')

local Vector3 = require('lib.vector3')
local Vector2 = require('lib.vector2')

---@class Vertex
---@overload fun(coordinates: Vector3, normal: Vector3, world_coordinates: Vector3?, texture_coordinates: Vector2?): Vertex
---@field coordinates Vector3
---@field normal Vector3
---@field world_coordinates Vector3
---@field texture_coordinates Vector2
local Vertex = class()

---Creates a new vertex instance
---@param coordinates Vector3
---@param normal Vector3
---@param world_coordinates Vector3?
---@param texture_coordinates Vector2?
function Vertex:new(coordinates, normal, world_coordinates, texture_coordinates)
	self.coordinates = coordinates
	self.normal = normal
	self.world_coordinates = world_coordinates or Vector3()
	self.texture_coordinates = texture_coordinates or Vector2()
end

return Vertex
