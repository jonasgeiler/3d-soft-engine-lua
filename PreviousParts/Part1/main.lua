local BABYLON = require "lib.babylon"
local SoftEngine = require "SoftEngine"

local device, mesh, mera
local meshes = {}

function love.load()
	mesh = SoftEngine.Mesh("Cube")
	table.insert(meshes, mesh)
	mera = SoftEngine.Camera()
	device = SoftEngine.Device()
	
	mesh.vertices[1] = BABYLON.Vector3(-1, 1, 1)
	mesh.vertices[2] = BABYLON.Vector3(1, 1, 1)
	mesh.vertices[3] = BABYLON.Vector3(-1, -1, 1)
	mesh.vertices[4] = BABYLON.Vector3(-1, -1, -1)
	mesh.vertices[5] = BABYLON.Vector3(-1, 1, -1)
	mesh.vertices[6] = BABYLON.Vector3(1, 1, -1)
	mesh.vertices[7] = BABYLON.Vector3(1, -1, 1)
	mesh.vertices[8] = BABYLON.Vector3(1, -1, -1)
	
	mera.position = BABYLON.Vector3(0, 0, 10)
	mera.target = BABYLON.Vector3(0, 0, 0)
end

function love.update()
	mesh.rotation.x = mesh.rotation.x + 0.01
	mesh.rotation.y = mesh.rotation.y + 0.01
end

function love.draw()
	love.graphics.setCanvas(device.workingCanvas)
	device:clear()
	
	device:render(mera, meshes)
	love.graphics.setCanvas()
	
	device:present()
end


