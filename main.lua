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
	device:clear()

	for mi = 1, #meshes do
		local mesh = meshes[mi]
		mesh.rotation.y = mesh.rotation.y + 0.5 * device.window.delta
		mesh.rotation.x = mesh.rotation.x + 0.5 * device.window.delta
	end

	device:render(camera, meshes)
end
