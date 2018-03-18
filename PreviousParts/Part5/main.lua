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

function love.update(dt)
	for _,mesh in pairs(meshes) do
		mesh.rotation.y = mesh.rotation.y + 0.3 * dt
		mesh.rotation.x = mesh.rotation.x + 0.3 * dt
	end
end

function love.draw()
	love.graphics.setCanvas(device.workingCanvas)
	device:clear()
	
	device:render(mera, meshes)
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	
	love.graphics.setCanvas()
	
	device:present()
end


