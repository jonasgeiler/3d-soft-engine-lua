local assert = assert
local io = io
local type = type
local math = math
local class = require('lib.class')
local vec3 = require('lib.vec3')
local matrix = require('lib.matrix')
local dkjson = require('dkjson')
local mesh = require('lib.mesh')
local face = require('lib.face')
local fenster = require('fenster')
local vertex = require('lib.vertex')
local scan_line_data = require('lib.scan_line_data')

---Represents the rendering device (window)
---@class device
---@overload fun(window: window*): device
---@field window window*
---@field width integer
---@field height integer
---@field aspect number
---@field half_width number
---@field half_height number
---@field depth_buffer number[]
---@field depth_buffer_size integer
local device = class()

---Init the device
---@param window window*
function device:new(window)
	self.window = window

	self.width = window.width
	self.height = window.height
	self.aspect = self.width / self.height
	self.half_width = self.width / 2
	self.half_height = self.height / 2

	self.depth_buffer = {}
	self.depth_buffer_size = self.width * self.height
end

---This function is called to clear the window buffer with a specific color
function device:clear()
	-- Clearing with black color by default
	self.window:clear()

	-- Clearing the depth buffer
	for i = 1, self.depth_buffer_size do
		-- Max possible value
		self.depth_buffer[i] = math.huge
	end
end

---Once everything is ready, we can update the window
function device:present()
	return self.window:loop() and not self.window.keys[27]
end

---Called to put a pixel on screen at a specific X,Y coordinates
---@param x integer
---@param y integer
---@param z number
---@param color integer
function device:put_pixel(x, y, z, color)
	local index = x + y * self.width
	if self.depth_buffer[index] < z then
		return
	end
	self.depth_buffer[index] = z

	self.window:set(x, y, color)
end

---Project takes some 3D coordinates and transform them
---in 2D coordinates using the transformation matrix.
---It also transform the same coordinates and the normal to the vertex
---in the 3D world
---@param vert vertex
---@param trans_mat matrix
---@param world matrix
---@return vertex
---@nodiscard
function device:project(vert, trans_mat, world)
	-- Transforming the coordinates
	local point_2d = vert.coordinates:transform_coordinates(trans_mat)

	-- Transforming the coordinates & the normal to the vertex in the 3D world
	local point_3d_world = vert.coordinates:transform_coordinates(world)
	local normal_3d_world = vert.normal:transform_coordinates(world)

	-- The transformed coordinates will be based on coordinate system
	-- starting on the center of the screen. But drawing on screen normally starts
	-- from top left. We then need to transform them again to have x:0, y:0 on top left.
	local x = point_2d.x * self.width + self.half_width
	local y = -point_2d.y * self.height + self.half_height

	return vertex(vec3(x, y, point_2d.z), normal_3d_world, point_3d_world)
end

---Calls put_pixel but does the clipping operation before
---@param point vec3
---@param color integer
function device:draw_point(point, color)
	-- Clipping what's visible on screen
	if point.x >= 0 and point.y >= 0 and point.x < self.width and point.y < self.height then
		-- Drawing a point
		self:put_pixel(math.floor(point.x), math.floor(point.y), point.z, color)
	end
end

---Clamping values to keep them between 0 and 1
---@param value number
---@param min number?
---@param max number?
---@return number
---@nodiscard
function device:clamp(value, min, max)
	return math.max(min or 0, math.min(value, max or 1))
end

---Interpolating the value between 2 vertices
---min is the starting point, max the ending point
---and gradient the % between the 2 points
---@param min number
---@param max number
---@param gradient number
function device:interpolate(min, max, gradient)
	return min + (max - min) * self:clamp(gradient)
end

---Drawing line between 2 points from left to right
---papb -> pcpd
---pa, pb, pc, pd must then be sorted before
---@param data scan_line_data
---@param va vertex
---@param vb vertex
---@param vc vertex
---@param vd vertex
---@param color integer
function device:process_scan_line(data, va, vb, vc, vd, color)
	local pa = va.coordinates
	local pb = vb.coordinates
	local pc = vc.coordinates
	local pd = vd.coordinates
	local color_r, color_g, color_b = fenster.rgb(color)

	-- Thanks to current Y, we can compute the gradient to compute others values like
	-- the starting X (sx) and ending X (ex) to draw between
	-- if pa.Y == pb.Y or pc.Y == pd.Y, gradient is forced to 1
	local gradient1 = pa.y ~= pb.y and ((data.curr_y - pa.y) / (pb.y - pa.y)) or 1
	local gradient2 = pc.y ~= pd.y and ((data.curr_y - pc.y) / (pd.y - pc.y)) or 1

	local sx = math.floor(self:interpolate(pa.x, pb.x, gradient1))
	local ex = math.floor(self:interpolate(pc.x, pd.x, gradient2))

	-- Starting Z & Ending Z
	local z1 = self:interpolate(pa.z, pb.z, gradient1)
	local z2 = self:interpolate(pc.z, pd.z, gradient2)

	local snl = self:interpolate(data.ndotla, data.ndotlb, gradient1)
	local enl = self:interpolate(data.ndotlc, data.ndotld, gradient2)

	-- Drawing a line from left (sx) to right (ex)
	for x = sx, ex - 1 do
		local gradient = (x - sx) / (ex - sx)
		local z = self:interpolate(z1, z2, gradient)
		local ndotl = self:interpolate(snl, enl, gradient)

		-- Changing the color value using the cosine of the angle
		-- between the light vector and the normal vector
		local r = math.floor(color_r * ndotl)
		local g = math.floor(color_g * ndotl)
		local b = math.floor(color_b * ndotl)
		self:draw_point(vec3(x, data.curr_y, z), fenster.rgb(r, g, b))
	end
end

---Compute the cosine of the angle between the light vector and the normal vector.
---Returns a value between 0 and 1
---@param vert vec3
---@param normal vec3
---@param light_position vec3
function device:compute_ndotl(vert, normal, light_position)
	local light_direction = light_position - vert

	normal:normalize()
	light_direction:normalize()

	return math.max(0, normal:dot(light_direction))
end

---Drawing triangle between 3 points
---@param v1 vertex
---@param v2 vertex
---@param v3 vertex
---@param color integer
function device:draw_triangle(v1, v2, v3, color)
	-- Sorting the points in order to always have this order on screen p1, p2 & p3
	-- with p1 always up (thus having the Y the lowest possible to be near the top screen)
	-- then p2 between p1 & p3
	if v1.coordinates.y > v2.coordinates.y then
		v1, v2 = v2, v1
	end
	if v2.coordinates.y > v3.coordinates.y then
		v2, v3 = v3, v2
	end
	if v1.coordinates.y > v2.coordinates.y then
		v1, v2 = v2, v1
	end

	local p1 = v1.coordinates
	local p2 = v2.coordinates
	local p3 = v3.coordinates

	-- Light position
	local light_pos = vec3(0, 10, 10)

	-- Computing the cos of the angle between the light vector and the normal vector
	-- it will return a value between 0 and 1 that will be used as the intensity of the color
	local nl1 = self:compute_ndotl(v1.world_coordinates, v1.normal, light_pos)
	local nl2 = self:compute_ndotl(v2.world_coordinates, v2.normal, light_pos)
	local nl3 = self:compute_ndotl(v3.world_coordinates, v3.normal, light_pos)

	local data = scan_line_data()

	-- Computing lines' directions
	local d_p1_p2 ---@type number
	local d_p1_p3 ---@type number

	-- Computing slopes
	-- http://en.wikipedia.org/wiki/Slope
	if p2.y - p1.y > 0 then
		d_p1_p2 = (p2.x - p1.x) / (p2.y - p1.y)
	else
		d_p1_p2 = 0
	end
	if p3.y - p1.y > 0 then
		d_p1_p3 = (p3.x - p1.x) / (p3.y - p1.y)
	else
		d_p1_p3 = 0
	end


	if d_p1_p2 > d_p1_p3 then
		for y = math.floor(p1.y), math.floor(p3.y) do
			data.curr_y = y

			if y < p2.y then
				data.ndotla = nl1
				data.ndotlb = nl3
				data.ndotlc = nl1
				data.ndotld = nl2
				self:process_scan_line(data, v1, v3, v1, v2, color)
			else
				data.ndotla = nl1
				data.ndotlb = nl3
				data.ndotlc = nl2
				data.ndotld = nl3
				self:process_scan_line(data, v1, v3, v2, v3, color)
			end
		end
	else
		for y = math.floor(p1.y), math.floor(p3.y) do
			data.curr_y = y

			if y < p2.y then
				data.ndotla = nl1
				data.ndotlb = nl2
				data.ndotlc = nl1
				data.ndotld = nl3
				self:process_scan_line(data, v1, v2, v1, v3, color)
			else
				data.ndotla = nl2
				data.ndotlb = nl3
				data.ndotlc = nl1
				data.ndotld = nl3
				self:process_scan_line(data, v2, v3, v1, v3, color)
			end
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
		self.aspect,
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

		local curr_mesh_faces_count = #curr_mesh.faces
		for fi = 1, curr_mesh_faces_count do
			local curr_face = curr_mesh.faces[fi]
			local vertex_a = curr_mesh.vertices[curr_face.a]
			local vertex_b = curr_mesh.vertices[curr_face.b]
			local vertex_c = curr_mesh.vertices[curr_face.c]

			local point_a = self:project(vertex_a, transform_matrix, world_matrix)
			local point_b = self:project(vertex_b, transform_matrix, world_matrix)
			local point_c = self:project(vertex_c, transform_matrix, world_matrix)

			--local color = 0.25 + (((fi - 1) % curr_mesh_faces_count) / curr_mesh_faces_count) * 0.75
			--local r = math.floor(255 * color)
			--local g = math.floor(255 * color)
			--local b = math.floor(255 * color)
			self:draw_triangle(point_a, point_b, point_c, 0xffffff)
		end
	end
end

---Create meshes from a JSON object
---@param json_object table
---@return mesh[]
---@nodiscard
function device:create_meshes_from_json(json_object)
	local meshes = {} ---@type mesh[]
	for mi = 1, #json_object.meshes do
		local vertices = json_object.meshes[mi].vertices ---@type number[]
		local indices = json_object.meshes[mi].indices ---@type integer[]
		local uv_count = json_object.meshes[mi].uvCount ---@type number

		-- Depending of the number of texture's coordinates per vertex
		-- we're jumping in the vertices array  by 6, 8 & 10 windows frame
		local vertices_step = 1
		if uv_count == 0 then
			vertices_step = 6
		elseif uv_count == 1 then
			vertices_step = 8
		elseif uv_count == 2 then
			vertices_step = 10
		end

		-- The number of interesting vertices information for us
		local vertices_count = #vertices / vertices_step

		-- Number of faces is logically the size of the array divided by 3 (A, B, C)
		local faces_count = #indices / 3

		local new_mesh = mesh()
		-- Filling the vertices array of our mesh first
		for vi = 1, vertices_count do
			local x = vertices[(vi - 1) * vertices_step + 1]
			local y = vertices[(vi - 1) * vertices_step + 2]
			local z = vertices[(vi - 1) * vertices_step + 3]

			-- Loading the vertex normal exported by Blender
			local nx = vertices[(vi - 1) * vertices_step + 4]
			local ny = vertices[(vi - 1) * vertices_step + 5]
			local nz = vertices[(vi - 1) * vertices_step + 6]

			new_mesh.vertices[vi] = vertex(
				vec3(x, y, z),
				vec3(nx, ny, nz)
			)
		end
		-- Then filling the faces array
		for fi = 1, faces_count do
			new_mesh.faces[fi] = face(
				indices[(fi - 1) * 3 + 1] + 1,
				indices[(fi - 1) * 3 + 2] + 1,
				indices[(fi - 1) * 3 + 3] + 1
			)
		end

		-- Getting the position of the mesh
		new_mesh.position = vec3(
			json_object.meshes[mi].position[1],
			json_object.meshes[mi].position[2],
			json_object.meshes[mi].position[3]
		)

		meshes[#meshes + 1] = new_mesh
	end

	return meshes
end

---Loading the JSON file and returning the array of meshes loaded
---@param filename string
---@return mesh[]
---@nodiscard
function device:load_json_file(filename)
	local file = assert(io.open(filename, 'r'))
	local json_object = dkjson.decode(file:read('*all'))
	file:close()

	-- Validate the JSON object
	assert(type(json_object) == 'table', 'Error loading JSON file: ' .. filename)

	return self:create_meshes_from_json(json_object)
end

return device
