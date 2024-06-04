local class = require('lib.class')
local vec3 = require('lib.vec3')
local vec2 = require('lib.vec2')

---Represents a geometric vertex
---@class vertex
---@overload fun(coordinates: vec3, normal: vec3, world_coordinates: vec3?, texture_coordinates: vec2?): vertex
---@field coordinates vec3
---@field normal vec3
---@field world_coordinates vec3
---@field texture_coordinates vec2
local vertex = class()

---Init the vertex
---@param coordinates vec3
---@param normal vec3
---@param world_coordinates vec3?
---@param texture_coordinates vec2?
function vertex:new(coordinates, normal, world_coordinates, texture_coordinates)
	self.coordinates = coordinates
	self.normal = normal
	self.world_coordinates = world_coordinates or vec3()
	self.texture_coordinates = texture_coordinates or vec2()
end

return vertex
