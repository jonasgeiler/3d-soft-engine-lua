local fenster = require('fenster')

local Camera = require('lib.camera')
local Device = require('lib.device')
local Vector3 = require('lib.vector3')

local window = fenster.open(640, 480, '3D Soft Engine')

local camera = Camera.new(Vector3.new(0, 0, 10), Vector3.new(0, 0, 0))
local device = Device.new(window)

local meshes = Device.load_json_file('./assets/monkey.babylon')

-- Set the rotation of the meshes to 180 degrees
for mi = 1, #meshes do
	local mesh = meshes[mi]
	mesh.rotation.y = 3.14159 -- 180 degrees
end

while device:present() do
	local delta_time = device.window.delta

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
		mesh.rotation.y = mesh.rotation.y + 0.5 * delta_time
		mesh.rotation.x = mesh.rotation.x + 0.5 * delta_time
	end

	device:render(camera, meshes)
end
