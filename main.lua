local fenster = require('fenster')
local mesh = require('lib.mesh')
local camera = require('lib.camera')
local device = require('lib.device')
local vec3 = require('lib.vec3')

local window = fenster.open(640, 480, '3D Soft Engine')

local meshes = {} ---@type mesh[]
local cam = camera()
local dev = device(window)

local cube = mesh({
	vec3(-1, 1, 1),
	vec3(1, 1, 1),
	vec3(-1, -1, 1),
	vec3(-1, -1, -1),
	vec3(-1, 1, -1),
	vec3(1, 1, -1),
	vec3(1, -1, 1),
	vec3(1, -1, -1),
})
meshes[#meshes + 1] = cube

cam.position = vec3(0, 0, 10)
cam.target = vec3(0, 0, 0)

while dev:present() do
	dev:clear()

	cube.rotation.x = cube.rotation.x + 0.01
	cube.rotation.y = cube.rotation.y + 0.01

	dev:render(cam, meshes)
end
