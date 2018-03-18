require "lib.class"
local BABYLON = require "lib.babylon"
require "lib.bit"
local json = require "lib.json"


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
	self.depthBuffer = {}
end

function SoftEngine.Device:clear()
	love.graphics.clear()
	
	for i = 1, self.workingWidth * self.workingHeight do
		self.depthBuffer[i] = 10000000
	end
end

function SoftEngine.Device:present()
	love.graphics.draw(self.workingCanvas)
end

function SoftEngine.Device:putPixel(x, y, z, color)
	local index = (bit.brshift(x,0) + bit.brshift(y,0) * self.workingWidth) + 1
	
	if self.depthBuffer[index] < z then
		return
	end
	
	self.depthBuffer[index] = z
	
	love.graphics.setColor(color:toArray())
	love.graphics.points(x, y)
end

function SoftEngine.Device:project(coord, transMat)
	local point = BABYLON.Vector3.TransformCoordinates(coord, transMat)
	
	local x = point.x * self.workingWidth + self.workingWidth / 2.0
	local y = -point.y * self.workingHeight + self.workingHeight / 2.0
	
	return BABYLON.Vector3(x, y, point.z)
end

function SoftEngine.Device:drawPoint(point, color)
	if point.x >= 0 and point.y >= 0 and point.x < self.workingWidth and point.y < self.workingHeight then
		self:putPixel(point.x, point.y, point.z, color)
	end
end

function SoftEngine.Device:clamp(value, min, max)
	min = min or 0
	max = max or 1
	return math.max(min, math.min(value, max))
end

function SoftEngine.Device:interpolate(min, max, gradient)
	return min + (max - min) * self:clamp(gradient)
end

function SoftEngine.Device:processScanLine(y, pa, pb, pc, pd, color)
	local gradient1
	if pa.y ~= pb.y then
		gradient1 = (y - pa.y) / (pb.y - pa.y)
	else
		gradient1 = 1
	end
	
	local gradient2
	if pc.y ~= pd.y then
		gradient2 = (y - pc.y) / (pd.y - pc.y)
	else
		gradient2 = 1
	end
	
	local sx = bit.brshift(math.floor(self:interpolate(pa.x, pb.x, gradient1)), 0)
	local ex = bit.brshift(math.floor(self:interpolate(pc.x, pd.x, gradient2)), 0)
	
	local z1 = self:interpolate(pa.z, pb.z, gradient1)
	local z2 = self:interpolate(pc.z, pd.z, gradient2)
	
	for x = sx, ex - 1 do
		local gradient = (x - sx) / (ex - sx)
		local z = self:interpolate(z1, z2, gradient)
		self:drawPoint(BABYLON.Vector3(x, y, z), color)
	end
end

function SoftEngine.Device:drawTriangle(p1, p2, p3, color)
	if p1.y > p2.y then
		p2, p1 = p1, p2
	end
	
	if p2.y > p3.y then
		p2, p3 = p3, p2
	end
	
	if p1.y > p2.y then
		p2, p1 = p1, p2
	end
	
	local dP1P2, dP1P3
	
	if p2.y - p1.y > 0 then
		dP1P2 = (p2.x - p1.x) / (p2.y - p1.y)
	else
		dP1P2 = 0
	end
	
	if p3.y - p1.y > 0 then
		dP1P3 = (p3.x - p1.x) / (p3.y - p1.y)
	else
		dP1P3 = 0
	end
	
	if dP1P2 > dP1P3 then
		for y = bit.brshift(math.floor(p1.y), 0), bit.brshift(math.floor(p3.y), 0) do
			if y < p2.y then
				self:processScanLine(y, p1, p3, p1, p2, color)
			else
				self:processScanLine(y, p1, p3, p2, p3, color)
			end
		end
	else
		for y = bit.brshift(math.floor(p1.y), 0), bit.brshift(math.floor(p3.y), 0) do
			if y < p2.y then
				self:processScanLine(y, p1, p2, p1, p3, color)
			else
				self:processScanLine(y, p2, p3, p1, p3, color)
			end
		end
	end
end

function SoftEngine.Device:render(camera, meshes)
	local viewMatrix = BABYLON.Matrix.LookAtLH(camera.position, camera.target, BABYLON.Vector3.Up())
	local projectionMatrix = BABYLON.Matrix.PerspectiveFovLH(0.78, self.workingWidth / self.workingHeight, 0.01, 1.0)
	
	for _,cMesh in pairs(meshes) do
		local worldMatrix = BABYLON.Matrix.RotationYawPitchRoll(cMesh.rotation.y, cMesh.rotation.x, cMesh.rotation.z) * BABYLON.Matrix.Translation(cMesh.position.x, cMesh.position.y, cMesh.position.z)
		
		local transformMatrix = worldMatrix * viewMatrix * projectionMatrix
		
		for k,currentFace in pairs(cMesh.faces) do
			local vertexA = cMesh.vertices[currentFace.A]
			local vertexB = cMesh.vertices[currentFace.B]
			local vertexC = cMesh.vertices[currentFace.C]
			
			local pixelA = self:project(vertexA, transformMatrix)
			local pixelB = self:project(vertexB, transformMatrix)
			local pixelC = self:project(vertexC, transformMatrix)
			
			local color = 0.25 + ((k % #cMesh.faces) / #cMesh.faces) * 0.75
			color = BABYLON.remap(color, 0, 1, 0, 255)
		
			self:drawTriangle(pixelA, pixelB, pixelC, BABYLON.Color4(color, color, color, 255))
		end
	end
end

function SoftEngine.Device:loadJSON(filename)
	local file = love.filesystem.newFile(filename)
	file:open("r")
	local rawJson = file:read()
	file:close()
	
	local jsonData = json.decode(rawJson)
	return self:createMeshesFromJSON(jsonData)
end

function SoftEngine.Device:createMeshesFromJSON(jsonData)
	local meshes = {}
	
	for meshIndex in pairs(jsonData.meshes) do
		local verticesArray = jsonData.meshes[meshIndex].vertices
		local indicesArray = jsonData.meshes[meshIndex].indices
		
		local uvCount = jsonData.meshes[meshIndex].uvCount
		local verticesStep = 1
		
		if uvCount == 0 then
			verticesStep = 6
		elseif uvCount == 1 then
			verticesStep = 8
		elseif uvCount == 2 then
			verticesStep = 10
		end
		
		local mesh = SoftEngine.Mesh(jsonData.meshes[meshIndex].name)
		
		local verticeIndex = 1
		for index = 1, #verticesArray, verticesStep do
			local x = verticesArray[index]
			local y = verticesArray[index + 1]
			local z = verticesArray[index + 2]
			
			mesh.vertices[verticeIndex] = BABYLON.Vector3(x, y, z)
			verticeIndex = verticeIndex + 1
		end

		local facesIndex = 1
		for index = 1, #indicesArray, 3 do
			local a = indicesArray[index] + 1
			local b = indicesArray[index + 1] + 1
			local c = indicesArray[index + 2] + 1
			
			mesh.faces[facesIndex] = {
				A = a,
				B = b,
				C = c
			}
			facesIndex = facesIndex + 1
		end
		
		local position = jsonData.meshes[meshIndex].position
		mesh.position= BABYLON.Vector3(position[1], position[2], position[3])
		table.insert(meshes, mesh)
	end
	
	return meshes
end






return SoftEngine