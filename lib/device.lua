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
	return self.window:loop() and not self.window.keys[27]
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
		self:put_pixel(math.floor(point.x), math.floor(point.y), 0xffff00)
	end
end

---Draws a line between two points
---@param point0 vec2
---@param point1 vec2
function device:draw_line(point0, point1)
	local dist = (point1 - point0):length()

	-- If the distance between the 2 points is less than 2 pixels
	-- we're exiting
	if dist < 2 then
		return
	end

	-- Find the middle point between first & second point
	local middle_point = (point0 + point1) / 2

	-- We draw this point on screen
	self:draw_point(middle_point)

	-- Recursive algorithm launched between first & middle point
	-- and between middle & second point
	self:draw_line(point0, middle_point)
	self:draw_line(middle_point, point1)
end

---Draws a line between two points (with bresenham algorithm)
---@param point0 vec2
---@param point1 vec2
function device:draw_b_line(point0, point1)
	local x0 = math.floor(point0.x)
	local y0 = math.floor(point0.y)
	local x1 = math.floor(point1.x)
	local y1 = math.floor(point1.y)
	local dx = math.abs(x1 - x0)
	local dy = math.abs(y1 - y0)
	local sx = (x0 < x1) and 1 or -1
	local sy = (y0 < y1) and 1 or -1
	local err = dx - dy

	while true do
		self:draw_point(vec2(x0, y0))

		if x0 == x1 and y0 == y1 then
			break
		end

		local e2 = 2 * err;
		if e2 > -dy then
			err = err - dy
			x0 = x0 + sx
		end
		if e2 < dx then
			err = err + dx
			y0 = y0 + sy
		end
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

	for mi = 1, #meshes do
		-- Current mesh to work on
		local curr_mesh = meshes[mi]

		-- Beware to apply rotation before translation
		local world_matrix = matrix.rotation_yaw_pitch_roll(
			curr_mesh.rotation.y,
			curr_mesh.rotation.x,
			curr_mesh.rotation.z
		) * matrix.translation(
			curr_mesh.position.x,
			curr_mesh.position.y,
			curr_mesh.position.z
		)

		local transform_matrix = world_matrix * view_matrix * projection_matrix

		for fi = 1, #curr_mesh.faces do
			local cur_face = curr_mesh.faces[fi]
			local vertex_a = curr_mesh.vertices[cur_face.a]
			local vertex_b = curr_mesh.vertices[cur_face.b]
			local vertex_c = curr_mesh.vertices[cur_face.c]

			local point_a = self:project(vertex_a, transform_matrix)
			local point_b = self:project(vertex_b, transform_matrix)
			local point_c = self:project(vertex_c, transform_matrix)

			self:draw_b_line(point_a, point_b)
			self:draw_b_line(point_b, point_c)
			self:draw_b_line(point_c, point_a)
		end
	end
end

return device
