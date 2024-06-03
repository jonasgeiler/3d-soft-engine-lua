local math = math
local class = require('lib.class')
local vec2 = require('lib.vec2')
local vec3 = require('lib.vec3')
local matrix = require('lib.matrix')

---Represents the rendering device (window)
---@class device
---@overload fun(window: window*): device
---@field window window*
---@field width integer
---@field height integer
local device = class()

---Init the device
---@param window window*
function device:new(window)
	self.window = window
	self.width = window.width
	self.height = window.height
end

---This function is called to clear the window buffer with a specific color
function device:clear()
	-- Clearing with black color by default
	self.window:clear()
end

---Once everything is ready, we can update the window
function device:present()
	return self.window:loop()
end

---Called to put a pixel on screen at a specific X,Y coordinates
---@param x integer
---@param y integer
---@param color integer
function device:put_pixel(x, y, color)
	self.window:set(x, y, color)
end

---Project takes some 3D coordinates and transform them in 2D coordinates using the transformation matrix
---@param coord vec3
---@param trans_mat matrix
---@return vec2
function device:project(coord, trans_mat)
	--- Transforming the coordinates
	local point = coord:transform_coordinates(trans_mat)

	-- The transformed coordinates will be based on coordinate system
	-- starting on the center of the screen. But drawing on screen normally starts
	-- from top left. We then need to transform them again to have x:0, y:0 on top left.
	local x = math.floor(point.x * self.width + self.width / 2)
	local y = math.floor(-point.y * self.height + self.height / 2)

	return vec2(x, y)
end

---Calls put_pixel but does the clipping operation before
---@param point vec2
function device:draw_point(point)
	-- Clipping what's visible on screen
	if point.x >= 0 and point.y >= 0 and point.x < self.width and point.y < self.height then
		-- Drawing a yellow point
		self:put_pixel(point.x, point.y, 0xffff00)
	end
end

---The main method of the engine that re-compute each vertex projection during each frame
---@param camera camera
---@param meshes mesh[]
function device:render(camera, meshes)
	local view_matrix = matrix.look_at_lh(
		camera.position,
		camera.target,
		vec3(0, 1, 0)
	)
	local projection_matrix = matrix.perspective_fov_lh(
		0.78,
		self.width / self.height,
		0.01,
		1
	)

	for _, mesh in ipairs(meshes) do
		-- Beware to apply rotation before translation
		local world_matrix = matrix.rotation_yaw_pitch_roll(
			mesh.rotation.y,
			mesh.rotation.x,
			mesh.rotation.z
		) * matrix.translation(
			mesh.position.x,
			mesh.position.y,
			mesh.position.z
		)

		local transform_matrix = world_matrix * view_matrix * projection_matrix

		for i = 1, #mesh.vertices do
			-- First, we project the 3D coordinates into the 2D space
			local projected_point = self:project(
				mesh.vertices[i],
				transform_matrix
			)

			-- Then we can draw on screen
			self:draw_point(projected_point)
		end
	end
end

return device
