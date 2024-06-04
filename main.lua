local fenster = require('fenster')

local Camera = require('lib.camera')
local Device = require('lib.device')
local Vector3 = require('lib.vector3')

local window = fenster.open(640, 480, '3D Soft Engine')

local camera = Camera(Vector3(0, 0, 10), Vector3(0, 0, 0))
local device = Device(window)

local meshes = device:load_json_file('./assets/monkey.babylon')

while device:present() do
	device:clear()

	for mi = 1, #meshes do
		local mesh = meshes[mi]
		mesh.rotation.y = mesh.rotation.y + 0.5 * device.window.delta
	end

	device:render(camera, meshes)
end
