local assert = assert
local setmetatable = setmetatable
local type = type
local io = io
local math = math

local fenster = require('fenster')
local json = require('dkjson')

local Vector3 = require('lib.vector3')
local Matrix = require('lib.matrix')
local Mesh = require('lib.mesh')
local Face = require('lib.face')
local Vertex = require('lib.vertex')
local ScanLineData = require('lib.scanlinedata')
local Material = require('lib.material')
local Vector2 = require('lib.vector2')
local Texture = require('lib.texture')

---@class Device
---@field window window*
---@field width integer
---@field height integer
---@field aspect number
---@field half_width number
---@field half_height number
---@field depth_buffer number[]
---@field depth_buffer_size integer
local Device = {}
Device.__index = Device

---Creates a new device instance
---@param window window*
---@return Device
---@nodiscard
function Device.new(window)
	local self = setmetatable({}, Device)

	self.window = window

	self.width = window.width
	self.height = window.height
	self.aspect = self.width / self.height
	self.half_width = self.width / 2
	self.half_height = self.height / 2

	self.depth_buffer = {}
	self.depth_buffer_size = self.width * self.height

	return self
end

---This function is called to clear the window buffer with a specific color
function Device:clear()
	-- Clearing with black color by default
	self.window:clear()

	-- Clearing the depth buffer
	for i = 1, self.depth_buffer_size do
		-- Max possible value
		self.depth_buffer[i] = math.huge
	end
end

---Called to put a pixel on screen at a specific X,Y coordinates
---@param x integer
---@param y integer
---@param z number
---@param color integer
function Device:put_pixel(x, y, z, color)
	-- As we have a 1-D Array for our back buffer
	-- we need to know the equivalent cell index in 1-D based
	-- on the 2D coordinates of the screen
	local index = x + y * self.width

	if self.depth_buffer[index] < z then
		return -- Discard
	end
	self.depth_buffer[index] = z

	self.window:set(x, y, color)
end

---Calls put_pixel but does the clipping operation before
---@param x integer
---@param y integer
---@param z number
---@param color integer
function Device:draw_point(x, y, z, color)
	-- Clipping what's visible on screen
	if x >= 0 and y >= 0 and x < self.width and y < self.height then
		-- Drawing a point
		self:put_pixel(x, y, z, color)
	end
end

---Once everything is ready, we can update the window
---@return boolean
function Device:present()
	return self.window:loop() and not self.window.keys[27]
end

---Clamping values to keep them between 0 and 1
---@param value number
---@param min number?
---@param max number?
---@return number
---@nodiscard
function Device.clamp(value, min, max)
	return math.max(min or 0, math.min(value, max or 1))
end

---Interpolating the value between 2 vertices
---min is the starting point, max the ending point
---and gradient the % between the 2 points
---@param min number
---@param max number
---@param gradient number
---@return number
---@nodiscard
function Device.interpolate(min, max, gradient)
	return min + (max - min) * Device.clamp(gradient)
end

---Project takes some 3D coordinates and transform them
---in 2D coordinates using the transformation matrix.
---It also transform the same coordinates and the normal to the vertex
---in the 3D world
---@param vertex Vertex
---@param trans_mat Matrix
---@param world Matrix
---@return Vertex
---@nodiscard
function Device:project(vertex, trans_mat, world)
	-- Transforming the coordinates
	local point_2d = vertex.coordinates:transform_coordinates(trans_mat)

	-- Transforming the coordinates & the normal to the vertex in the 3D world
	local point_3d_world = vertex.coordinates:transform_coordinates(world)
	local normal_3d_world = vertex.normal:transform_coordinates(world)

	-- The transformed coordinates will be based on coordinate system
	-- starting on the center of the screen. But drawing on screen normally starts
	-- from top left. We then need to transform them again to have x:0, y:0 on top left.
	local x = point_2d.x * self.width + self.half_width
	local y = -point_2d.y * self.height + self.half_height

	return Vertex.new(
		Vector3.new(x, y, point_2d.z),
		normal_3d_world,
		point_3d_world,
		vertex.texture_coordinates
	)
end

---Compute the cosine of the angle between the light vector and the normal vector.
---Returns a value between 0 and 1
---@param vertex Vector3
---@param normal Vector3
---@param light_position Vector3
function Device.compute_ndotl(vertex, normal, light_position)
	local light_direction = light_position - vertex

	normal:normalize()
	light_direction:normalize()

	return math.max(0, normal:dot(light_direction))
end

---Drawing line between 2 points from left to right
---papb -> pcpd
---pa, pb, pc, pd must then be sorted before
---@param data ScanLineData
---@param va Vertex
---@param vb Vertex
---@param vc Vertex
---@param vd Vertex
---@param texture Texture?
function Device:process_scan_line(data, va, vb, vc, vd, texture)
	local pa = va.coordinates
	local pb = vb.coordinates
	local pc = vc.coordinates
	local pd = vd.coordinates

	-- Thanks to current Y, we can compute the gradient to compute others values like
	-- the starting X (sx) and ending X (ex) to draw between
	-- if pa.Y == pb.Y or pc.Y == pd.Y, gradient is forced to 1
	local gradient1 = pa.y ~= pb.y
		and ((data.curr_y - pa.y) / (pb.y - pa.y))
		or 1
	local gradient2 = pc.y ~= pd.y
		and ((data.curr_y - pc.y) / (pd.y - pc.y))
		or 1

	local sx = math.floor(Device.interpolate(pa.x, pb.x, gradient1))
	local ex = math.floor(Device.interpolate(pc.x, pd.x, gradient2))

	-- Starting Z & Ending Z
	local z1 = Device.interpolate(pa.z, pb.z, gradient1)
	local z2 = Device.interpolate(pc.z, pd.z, gradient2)

	-- Interpolating normals on Y
	local snl = Device.interpolate(data.ndotla, data.ndotlb, gradient1)
	local enl = Device.interpolate(data.ndotlc, data.ndotld, gradient2)

	-- Interpolating texture coordinates on Y
	local su = Device.interpolate(data.ua, data.ub, gradient1)
	local eu = Device.interpolate(data.uc, data.ud, gradient2)
	local sv = Device.interpolate(data.va, data.vb, gradient1)
	local ev = Device.interpolate(data.vc, data.vd, gradient2)

	-- Drawing a line from left (sx) to right (ex)
	for x = sx, ex - 1 do
		local gradient = (x - sx) / (ex - sx)

		-- Interpolating Z, normal and texture coordinates on X
		local z = Device.interpolate(z1, z2, gradient)
		local ndotl = Device.interpolate(snl, enl, gradient)
		local u = Device.interpolate(su, eu, gradient)
		local v = Device.interpolate(sv, ev, gradient)

		local texture_color = texture and texture:map(u, v) or 0xffffff
		local texture_color_r, texture_color_g, texture_color_b = fenster.rgb(
			texture_color
		)

		-- Changing the native color value using the cosine of the angle
		-- between the light vector and the normal vector and the texture color
		local r = math.floor(texture_color_r * ndotl)
		local g = math.floor(texture_color_g * ndotl)
		local b = math.floor(texture_color_b * ndotl)
		self:draw_point(x, data.curr_y, z, fenster.rgb(r, g, b))
	end
end

---Drawing triangle between 3 points
---@param v1 Vertex
---@param v2 Vertex
---@param v3 Vertex
---@param texture Texture?
function Device:draw_triangle(v1, v2, v3, texture)
	-- Sorting the points in order to always have this order on screen p1, p2 & p3
	-- with p1 always up (thus having the Y the lowest possible to be near the top screen)
	-- then p2 between p1 & p3
	if v1.coordinates.y > v2.coordinates.y then
		---@diagnostic disable-next-line: no-unknown
		v1, v2 = v2, v1
	end
	if v2.coordinates.y > v3.coordinates.y then
		---@diagnostic disable-next-line: no-unknown
		v2, v3 = v3, v2
	end
	if v1.coordinates.y > v2.coordinates.y then
		---@diagnostic disable-next-line: no-unknown
		v1, v2 = v2, v1
	end

	local p1 = v1.coordinates
	local p2 = v2.coordinates
	local p3 = v3.coordinates

	-- Light position
	local light_pos = Vector3.new(0, 10, 10)

	-- Computing the cos of the angle between the light vector and the normal vector
	-- it will return a value between 0 and 1 that will be used as the intensity of the color
	local nl1 = Device.compute_ndotl(v1.world_coordinates, v1.normal, light_pos)
	local nl2 = Device.compute_ndotl(v2.world_coordinates, v2.normal, light_pos)
	local nl3 = Device.compute_ndotl(v3.world_coordinates, v3.normal, light_pos)

	local data = ScanLineData.new()

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

				data.ua = v1.texture_coordinates.x
				data.ub = v3.texture_coordinates.x
				data.uc = v1.texture_coordinates.x
				data.ud = v2.texture_coordinates.x

				data.va = v1.texture_coordinates.y
				data.vb = v3.texture_coordinates.y
				data.vc = v1.texture_coordinates.y
				data.vd = v2.texture_coordinates.y
				self:process_scan_line(data, v1, v3, v1, v2, texture)
			else
				data.ndotla = nl1
				data.ndotlb = nl3
				data.ndotlc = nl2
				data.ndotld = nl3

				data.ua = v1.texture_coordinates.x
				data.ub = v3.texture_coordinates.x
				data.uc = v2.texture_coordinates.x
				data.ud = v3.texture_coordinates.x

				data.va = v1.texture_coordinates.y
				data.vb = v3.texture_coordinates.y
				data.vc = v2.texture_coordinates.y
				data.vd = v3.texture_coordinates.y

				self:process_scan_line(data, v1, v3, v2, v3, texture)
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

				data.ua = v1.texture_coordinates.x
				data.ub = v2.texture_coordinates.x
				data.uc = v1.texture_coordinates.x
				data.ud = v3.texture_coordinates.x

				data.va = v1.texture_coordinates.y
				data.vb = v2.texture_coordinates.y
				data.vc = v1.texture_coordinates.y
				data.vd = v3.texture_coordinates.y

				self:process_scan_line(data, v1, v2, v1, v3, texture)
			else
				data.ndotla = nl2
				data.ndotlb = nl3
				data.ndotlc = nl1
				data.ndotld = nl3

				data.ua = v2.texture_coordinates.x
				data.ub = v3.texture_coordinates.x
				data.uc = v1.texture_coordinates.x
				data.ud = v3.texture_coordinates.x

				data.va = v2.texture_coordinates.y
				data.vb = v3.texture_coordinates.y
				data.vc = v1.texture_coordinates.y
				data.vd = v3.texture_coordinates.y

				self:process_scan_line(data, v2, v3, v1, v3, texture)
			end
		end
	end
end

---The main method of the engine that re-compute each vertex projection during each frame
---@param camera Camera
---@param meshes Mesh[]
function Device:render(camera, meshes)
	-- TODO: Cache theses matrices
	local view_matrix = Matrix.look_at_lh(
		camera.position,
		camera.target,
		camera.up
	)
	local projection_matrix = Matrix.perspective_fov_lh(
		0.78,
		self.aspect,
		0.01,
		1
	)

	for mi = 1, #meshes do
		-- Current mesh to work on
		local curr_mesh = meshes[mi]

		-- Beware to apply rotation before translation
		local world_matrix = Matrix.rotation_yaw_pitch_roll(
			curr_mesh.rotation.y,
			curr_mesh.rotation.x,
			curr_mesh.rotation.z
		) * Matrix.translation(
			curr_mesh.position.x,
			curr_mesh.position.y,
			curr_mesh.position.z
		)

		local transform_matrix = world_matrix * view_matrix * projection_matrix

		for fi = 1, #curr_mesh.faces do
			local curr_face = curr_mesh.faces[fi]
			local vertex_a = curr_mesh.vertices[curr_face.a]
			local vertex_b = curr_mesh.vertices[curr_face.b]
			local vertex_c = curr_mesh.vertices[curr_face.c]

			local point_a = self:project(vertex_a, transform_matrix, world_matrix)
			local point_b = self:project(vertex_b, transform_matrix, world_matrix)
			local point_c = self:project(vertex_c, transform_matrix, world_matrix)

			self:draw_triangle(point_a, point_b, point_c, curr_mesh.texture)
		end
	end
end

---Loading the JSON file and returning the array of meshes loaded
---@param filename string
---@return Mesh[]
---@nodiscard
function Device.load_json_file(filename)
	local file = assert(io.open(filename, 'r'))
	local json_object, _, err = json.decode(file:read('*all'))
	assert(not err, err)
	file:close()
	assert(type(json_object) == 'table', 'json file does not contain an object')

	return Device.create_meshes_from_json(json_object)
end

---Create meshes from a JSON object
---@param json_object table
---@return Mesh[]
---@nodiscard
function Device.create_meshes_from_json(json_object)
	local materials = {} ---@type table<string, Material>
	for mi = 1, #json_object.materials do
		---@type {id:string,diffuseTexture:{name:string}}
		local curr_material = json_object.materials[mi]

		local id = curr_material.id
		local diffuse_texture = curr_material.diffuseTexture

		if diffuse_texture then
			local texture = Texture.new('./assets/' .. diffuse_texture.name)
			materials[id] = Material.new(texture)
		end
	end

	local meshes = {} ---@type Mesh[]
	for mi = 1, #json_object.meshes do
		---@type {vertices:number[],indices:integer[],uvCount:integer,position:number[],materialId:string}
		local curr_mesh = json_object.meshes[mi]

		local vertices = curr_mesh.vertices
		local indices = curr_mesh.indices
		local uv_count = curr_mesh.uvCount

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

		local new_mesh = Mesh.new()
		-- Filling the vertices array of our mesh first
		for vi = 1, vertices_count do
			local x = vertices[(vi - 1) * vertices_step + 1]
			local y = vertices[(vi - 1) * vertices_step + 2]
			local z = vertices[(vi - 1) * vertices_step + 3]

			-- Loading the vertex normal exported by Blender
			local nx = vertices[(vi - 1) * vertices_step + 4]
			local ny = vertices[(vi - 1) * vertices_step + 5]
			local nz = vertices[(vi - 1) * vertices_step + 6]

			new_mesh.vertices[vi] = Vertex.new(
				Vector3.new(x, y, z),
				Vector3.new(nx, ny, nz)
			)

			if uv_count > 0 then
				-- Loading the texture coordinates
				local u = vertices[(vi - 1) * vertices_step + 7]
				local v = vertices[(vi - 1) * vertices_step + 8]
				new_mesh.vertices[vi].texture_coordinates = Vector2.new(u, v)
			end
		end
		-- Then filling the faces array
		for fi = 1, faces_count do
			new_mesh.faces[fi] = Face.new(
				indices[(fi - 1) * 3 + 1] + 1,
				indices[(fi - 1) * 3 + 2] + 1,
				indices[(fi - 1) * 3 + 3] + 1
			)
		end

		-- Getting the position of the mesh
		new_mesh.position = Vector3.new(
			curr_mesh.position[1],
			curr_mesh.position[2],
			curr_mesh.position[3]
		)

		if uv_count > 0 then
			new_mesh.texture = materials[curr_mesh.materialId].texture
		end

		meshes[#meshes + 1] = new_mesh
	end

	return meshes
end

return Device
