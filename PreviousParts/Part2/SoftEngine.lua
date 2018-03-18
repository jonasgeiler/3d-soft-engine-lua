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
	self.faces = {}
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

function SoftEngine.Device:drawLine(point0, point1)
	local dist = (point1 - point0):length()
	
	if dist < 2 then
		return
	end
	
	local middlePoint = point0 + ((point1 - point0):scale(0.5))
	
	self:drawPoint(middlePoint)
	
	self:drawLine(point0, middlePoint)
	self:drawLine(middlePoint, point1)
end

function SoftEngine.Device:drawBLine(point0, point1)
	local x0 = bit.brshift(point0.x, 0)
	local y0 = bit.brshift(point0.y, 0)
	local x1 = bit.brshift(point1.x, 0)
	local y1 = bit.brshift(point1.y, 0)
	local dx = math.abs(x1 - x0)
	local dy = math.abs(y1 - y0)

	local sx
	if x0 < x1 then
		sx = 1
	else
		sx = -1
	end

	local sy
	if y0 < y1 then
		sy = 1
	else
		sy = -1
	end

	local err = dx - dy
	while true do
		self:drawPoint(BABYLON.Vector2(x0, y0))
		if x0 == x1 and y0 == y1 then break end
		local e2 = 2 * err
		if e2 > -dy then
			err = err - dy 
			x0 = x0 + sx 
		end
		
		if e2 < dx then
			err = err + dx 
			y0 = y0 + sy
		end
	end
end

function SoftEngine.Device:render(camera, meshes)
	local viewMatrix = BABYLON.Matrix.LookAtLH(camera.position, camera.target, BABYLON.Vector3.Up())
	local projectionMatrix = BABYLON.Matrix.PerspectiveFovLH(0.78, self.workingWidth / self.workingHeight, 0.01, 1.0)
	
	for _,cMesh in pairs(meshes) do
		local worldMatrix = BABYLON.Matrix.RotationYawPitchRoll(cMesh.rotation.y, cMesh.rotation.x, cMesh.rotation.z) * BABYLON.Matrix.Translation(cMesh.position.x, cMesh.position.y, cMesh.position.z)
		
		local transformMatrix = worldMatrix * viewMatrix * projectionMatrix
		
		for _,currentFace in pairs(cMesh.faces) do
			local vertexA = cMesh.vertices[currentFace.A]
			local vertexB = cMesh.vertices[currentFace.B]
			local vertexC = cMesh.vertices[currentFace.C]
			
			local pixelA = self:project(vertexA, transformMatrix)
			local pixelB = self:project(vertexB, transformMatrix)
			local pixelC = self:project(vertexC, transformMatrix)
			
			self:drawBLine(pixelA, pixelB)
			self:drawBLine(pixelB, pixelC)
			self:drawBLine(pixelC, pixelA)
		end
	end
end






return SoftEngine