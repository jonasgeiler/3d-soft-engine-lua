require "lib.class"
local BABYLON = require "lib.babylon"
require "lib.bit"

SoftEngine = {}


--[[ Camera ]]--
SoftEngine.Camera = class()
function SoftEngine.Camera:init()
	self.position = BABYLON.Vector3.Zero() -- (x: 0, y: 0, z: 0)
	self.target = BABYLON.Vector3.Zero()
end


--[[ Mesh ]]--
SoftEngine.Mesh = class()
function SoftEngine.Mesh:init(name)
	self.name = name
	self.vertices = {}
	self.rotation = BABYLON.Vector3.Zero()
	self.position = BABYLON.Vector3.Zero()
end


--[[ Device ]]--
SoftEngine.Device = class()
function SoftEngine.Device:init()
	self.workingCanvas = love.graphics.newCanvas()
	self.workingWidth = self.workingCanvas:getWidth()
	self.workingHeight = self.workingCanvas:getHeight()
end

function SoftEngine.Device:clear()
	love.graphics.clear()
end

function SoftEngine.Device:present()
	love.graphics.draw(self.workingCanvas)
end

function SoftEngine.Device:putPixel(x, y, color)
	love.graphics.setColor(color:toArray())
	love.graphics.points(x, y)
end

function SoftEngine.Device:project(coord, transMat)
	local point = BABYLON.Vector3.TransformCoordinates(coord, transMat)
	
	local x = bit.brshift(math.floor(point.x  * self.workingWidth  + self.workingWidth / 2.0), 0)
	local y = bit.brshift(math.floor(-point.y * self.workingHeight + self.workingHeight / 2.0), 0)
	
	return BABYLON.Vector2(x, y)
end

function SoftEngine.Device:drawPoint(point)
	if point.x >= 0 and point.y >= 0 and point.x < self.workingWidth and point.y < self.workingHeight then
		self:putPixel(point.x, point.y, BABYLON.Color4(255, 255, 0, 255))
	end
end

function SoftEngine.Device:render(camera, meshes)
	local viewMatrix = BABYLON.Matrix.LookAtLH(camera.position, camera.target, BABYLON.Vector3.Up())
	local projectionMatrix = BABYLON.Matrix.PerspectiveFovLH(0.78, self.workingWidth / self.workingHeight, 0.01, 1.0)
	
	for _,cMesh in pairs(meshes) do
		local worldMatrix = BABYLON.Matrix.RotationYawPitchRoll(cMesh.rotation.y, cMesh.rotation.x, cMesh.rotation.z) * BABYLON.Matrix.Translation(cMesh.position.x, cMesh.position.y, cMesh.position.z)
		
		local transformMatrix = worldMatrix * viewMatrix * projectionMatrix
		
		for indexVertices in pairs(cMesh.vertices) do
			local projectedPoint = self:project(cMesh.vertices[indexVertices], transformMatrix)
			self:drawPoint(projectedPoint)
		end
	end
end






return SoftEngine