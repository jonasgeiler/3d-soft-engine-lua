local class = require('lib.class')
local vec3 = require('lib.vec3')

---Represents a geometric vertex
---@class vertex
---@overload fun(coordinates: vec3, normal: vec3, world_coordinates: vec3?): vertex
---@field coordinates vec3
---@field normal vec3
---@field world_coordinates vec3
local vertex = class()

---Init the vertex
---@param coordinates vec3
---@param normal vec3
---@param world_coordinates vec3?
function vertex:new(coordinates, normal, world_coordinates)
	self.coordinates = coordinates
	self.normal = normal
	self.world_coordinates = world_coordinates or vec3()
end

return vertex
