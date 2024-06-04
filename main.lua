local fenster = require('fenster')

local Camera = require('lib.camera')
local Device = require('lib.device')
local Vector3 = require('lib.vector3')

local window = fenster.open(640, 480, '3D Soft Engine - Rotate with arrow keys')

local camera = Camera.new(Vector3.new(0, 0, 10), Vector3.new(0, 0, 0))
local device = Device.new(window)

local meshes = Device.load_json_file('./assets/monkey.babylon')
--local meshes = Device.load_json_file('./assets/teapot.babylon')
--local meshes = Device.load_json_file('./assets/torus.babylon')

-- Set the initial rotation/position of the meshes
for mi = 1, #meshes do
	local mesh = meshes[mi]
	mesh.rotation.y = 3.14159 -- rotate 180 degrees to see the monkey's face
end

while device:present() do
	local delta_time = device.window.delta
	local keys = device.window.keys

	device:clear()

	-- Lightweight FPS indicator
	--[[
	local fps = math.floor(1 / delta_time)
	for x = 0, math.min(120, fps) do
		device.window:set(x, 0, 0x00ff00)
	end
	device.window:set(30, 0, 0x0000ff)
	device.window:set(60, 0, 0xff0000)
	--]]

	for mi = 1, #meshes do
		local mesh = meshes[mi]

		mesh.rotation.x = mesh.rotation.x + 0.5 * delta_time
		mesh.rotation.y = mesh.rotation.y + 0.5 * delta_time

		if keys[17] then -- up arrow
			mesh.rotation.x = mesh.rotation.x + 1 * delta_time
		end
		if keys[18] then -- down arrow
			mesh.rotation.x = mesh.rotation.x - 1 * delta_time
		end
		if keys[19] then -- right arrow
			mesh.rotation.y = mesh.rotation.y - 1 * delta_time
		end
		if keys[20] then -- left arrow
			mesh.rotation.y = mesh.rotation.y + 1 * delta_time
		end
	end

	device:render(camera, meshes)
end
