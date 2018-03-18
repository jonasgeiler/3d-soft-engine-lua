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

function SoftEngine.Device:project(vertex, transMat, world)
	local point2D = BABYLON.Vector3.TransformCoordinates(vertex.coordinates, transMat)
	
	local point3DWorld = BABYLON.Vector3.TransformCoordinates(vertex.coordinates, world)
	local normal3DWorld = BABYLON.Vector3.TransformCoordinates(vertex.normal, world)
	
	local x = point2D.x * self.workingWidth + self.workingWidth / 2.0
	local y = -point2D.y * self.workingHeight + self.workingHeight / 2.0
	
	return {
		coordinates = BABYLON.Vector3(x, y, point2D.z),
		normal = normal3DWorld,
		worldCoordinates = point3DWorld
	}
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

function SoftEngine.Device:processScanLine(data, va, vb, vc, vd, color)
	local pa = va.coordinates
	local pb = vb.coordinates
	local pc = vc.coordinates
	local pd = vd.coordinates
	
	local gradient1
	if pa.y ~= pb.y then
		gradient1 = (data.currentY - pa.y) / (pb.y - pa.y)
	else
		gradient1 = 1
	end
	
	local gradient2
	if pc.y ~= pd.y then
		gradient2 = (data.currentY - pc.y) / (pd.y - pc.y)
	else
		gradient2 = 1
	end
	
	local sx = bit.brshift(math.floor(self:interpolate(pa.x, pb.x, gradient1)), 0)
	local ex = bit.brshift(math.floor(self:interpolate(pc.x, pd.x, gradient2)), 0)
	
	local z1 = self:interpolate(pa.z, pb.z, gradient1)
	local z2 = self:interpolate(pc.z, pd.z, gradient2)
	
	local snl = self:interpolate(data.ndotla, data.ndotlb, gradient1)
	local enl = self:interpolate(data.ndotlc, data.ndotld, gradient2)
	
	for x = sx, ex - 1 do
		local gradient = (x - sx) / (ex - sx)
		local z = self:interpolate(z1, z2, gradient)
		local ndotl = self:interpolate(snl, enl, gradient)
		
		self:drawPoint(BABYLON.Vector3(x, data.currentY, z), BABYLON.Color4(color.r * ndotl, color.g * ndotl, color.b * ndotl, 255))
	end
end

function SoftEngine.Device:computeNDotL(vertex, normal, lightPosition)
	local lightDirection = lightPosition - vertex
	
	normal:normalize()
	lightDirection:normalize()
	
	return math.max(0, BABYLON.Vector3.Dot(normal, lightDirection))
end

function SoftEngine.Device:drawTriangle(v1, v2, v3, color)
	if v1.coordinates.y > v2.coordinates.y then
		v2, v1 = v1, v2
	end
	
	if v2.coordinates.y > v3.coordinates.y then
		v2, v3 = v3, v2
	end
	
	if v1.coordinates.y > v2.coordinates.y then
		v2, v1 = v1, v2
	end
	
	local p1 = v1.coordinates
	local p2 = v2.coordinates
	local p3 = v3.coordinates
	
	local lightPos = BABYLON.Vector3(0, 10, 10)
	
	local nl1 = self:computeNDotL(v1.worldCoordinates, v1.normal, lightPos)
	local nl2 = self:computeNDotL(v2.worldCoordinates, v2.normal, lightPos)
	local nl3 = self:computeNDotL(v3.worldCoordinates, v3.normal, lightPos)
	
	local data = {}
	
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
			data.currentY = y
			
			if y < p2.y then
				data.ndotla = nl1
				data.ndotlb = nl3
				data.ndotlc = nl1
				data.ndotld = nl2
				self:processScanLine(data, v1, v3, v1, v2, color)
			else
				data.ndotla = nl1
                data.ndotlb = nl3
                data.ndotlc = nl2
                data.ndotld = nl3
				self:processScanLine(data, v1, v3, v2, v3, color)
			end
		end
	else
		for y = bit.brshift(math.floor(p1.y), 0), bit.brshift(math.floor(p3.y), 0) do
			data.currentY = y
			
			if y < p2.y then
				data.ndotla = nl1
                data.ndotlb = nl2
                data.ndotlc = nl1
                data.ndotld = nl3
				self:processScanLine(data, v1, v2, v1, v3, color)
			else
				data.ndotla = nl2
                data.ndotlb = nl3
                data.ndotlc = nl1
                data.ndotld = nl3
				self:processScanLine(data, v2, v3, v1, v3, color)
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
			
			local pixelA = self:project(vertexA, transformMatrix, worldMatrix)
			local pixelB = self:project(vertexB, transformMatrix, worldMatrix)
			local pixelC = self:project(vertexC, transformMatrix, worldMatrix)
			
			local color = 255
		
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
			
			local nx = verticesArray[index + 3]
			local ny = verticesArray[index + 4]
			local nz = verticesArray[index + 5]
			
			mesh.vertices[verticeIndex] = {
				coordinates = BABYLON.Vector3(x, y, z),
				normal = BABYLON.Vector3(nx, ny, nz),
				worldCoordinates = nil
			}
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