local BABYLON = require "lib.babylon"
local SoftEngine = require "SoftEngine"

local device, mesh, mera
local meshes = {}

function love.load()
	mera = SoftEngine.Camera()
	device = SoftEngine.Device()
	
	mesh = SoftEngine.Mesh("Cube")
	table.insert(meshes, mesh)
	
	mesh.vertices[1] = BABYLON.Vector3(-1, 1, 1)
	mesh.vertices[2] = BABYLON.Vector3(1, 1, 1)
	mesh.vertices[3] = BABYLON.Vector3(-1, -1, 1)
	mesh.vertices[4] = BABYLON.Vector3(1, -1, 1)
	mesh.vertices[5] = BABYLON.Vector3(-1, 1, -1)
	mesh.vertices[6] = BABYLON.Vector3(1, 1, -1)
	mesh.vertices[7] = BABYLON.Vector3(1, -1, -1)
	mesh.vertices[8] = BABYLON.Vector3(-1, -1, -1)
	
	mesh.faces[0] = { A = 1, B = 2, C = 3 }
	mesh.faces[1] = { A = 2, B = 3, C = 4 }
	mesh.faces[2] = { A = 2, B = 4, C = 7 }
	mesh.faces[3] = { A = 2, B = 6, C = 7 }
	mesh.faces[4] = { A = 1, B = 2, C = 5 }
	mesh.faces[5] = { A = 2, B = 5, C = 6 }

	mesh.faces[6] = { A = 3, B = 4, C = 8 }
	mesh.faces[7] = { A = 4, B = 7, C = 8 }
	mesh.faces[8] = { A = 1, B = 3, C = 8 }
	mesh.faces[9] = { A = 1, B = 5, C = 8 }
	mesh.faces[10] = { A = 5, B = 6, C = 7 }
	mesh.faces[11] = { A = 5, B = 7, C = 8 }
	
	
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


