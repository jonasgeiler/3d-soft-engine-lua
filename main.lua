local fenster = require('fenster')
local camera = require('lib.camera')
local device = require('lib.device')
local vec3 = require('lib.vec3')

local window = fenster.open(640, 480, '3D Soft Engine')

local cam = camera()
local dev = device(window)

cam.position = vec3(0, 0, 10)
cam.target = vec3(0, 0, 0)

local meshes = dev:create_meshes_from_json(
	dev:load_json_file('./assets/monkey/model.babylon')
)

while dev:present() do
	dev:clear()

	for mi = 1, #meshes do
		local mesh = meshes[mi]
		mesh.rotation.y = mesh.rotation.y + 0.5 * dev.window.delta
	end

	dev:render(cam, meshes)
end
