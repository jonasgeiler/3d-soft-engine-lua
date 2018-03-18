local BABYLON = require "lib.babylon"
local SoftEngine = require "SoftEngine"

local device, mera
local meshes = {}

function love.load()
	mera = SoftEngine.Camera()
	device = SoftEngine.Device()
	
	mera.position = BABYLON.Vector3(0, 0, 10)
	mera.target = BABYLON.Vector3(0, 0, 0)
	
	meshes = device:loadJSON("models/monkey.babylon")
end

function love.update()
	for i = 1, #meshes do
		meshes[i].rotation.y = meshes[i].rotation.y + 0.03
		meshes[i].rotation.x = meshes[i].rotation.x + 0.03
	end
end

function love.draw()
	love.graphics.setCanvas(device.workingCanvas)
	device:clear()
	
	device:render(mera, meshes)
	love.graphics.setCanvas()
	
	device:present()
end


