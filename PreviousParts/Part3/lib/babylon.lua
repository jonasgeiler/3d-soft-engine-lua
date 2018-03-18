require "lib.class"

BABYLON = {}


--[[ Color4 ]]--
BABYLON.Color4 = class()
function BABYLON.Color4:init(initialR, initialG, initialB, initialA)
	self.r = initialR
	self.g = initialG
	self.b = initialB
	self.a = initialA
end

function BABYLON.Color4:__tostring()
	return "{R: " .. self.r .. ", G: " .. self.g .. ", B: " .. self.b .. ", A: " .. self.a .. "}";
end

function BABYLON.Color4:toArray(named)
	if named == nil or named == false then
		return {self.r, self.g, self.b, self.a}
	elseif named == true then
		color = {}
		color.r = self.r
		color.g = self.g
		color.b = self.b
		color.a = self.a
		return color
	end
end


--[[ Vector2 ]]--
BABYLON.Vector2 = class()
function BABYLON.Vector2:init(initialX, initialY)
	self.x = initialX
	self.y = initialY	
end

function BABYLON.Vector2:__tostring()
	return "{X: " .. self.x .. ", Y: " .. self.y .. "}"
end

function BABYLON.Vector2:__add(otherVec)
	return BABYLON.Vector2(self.x + otherVec.x, self.y + otherVec.y)
end

function BABYLON.Vector2:__sub(otherVec)
	return BABYLON.Vector2(self.x - otherVec.x, self.y - otherVec.y)
end

function BABYLON.Vector2:__mul(otherVec)
	return BABYLON.Vector2(self.x * otherVec.x, self.y * otherVec.y)
end

function BABYLON.Vector2:__div(otherVec)
	return BABYLON.Vector2(self.x / otherVec.x, self.y / otherVec.y)
end

function BABYLON.Vector2:__idiv(otherVec)
	return BABYLON.Vector2(math.floor(self.x / otherVec.x), math.floor(self.y / otherVec.y))
end

function BABYLON.Vector2:__mod(otherVec)
	return BABYLON.Vector2(self.x % otherVec.x, self.y % otherVec.y)
end

function BABYLON.Vector2:__pow(otherVec)
	return BABYLON.Vector2(self.x ^ otherVec.x, self.y ^ otherVec.y)
end

function BABYLON.Vector2:__unm()
	return BABYLON.Vector2(-self.x, -self.y)
end

function BABYLON.Vector2:scale(scale)
	return BABYLON.Vector2(self.x * scale, self.y * scale)
end

function BABYLON.Vector2:__eq(otherVec)
	return (self.x == otherVec.x and self.y == otherVec.y)
end

function BABYLON.Vector2:__lt(otherVec)
	return (self.x < otherVec.x and self.y < otherVec.y)
end

function BABYLON.Vector2:__le(otherVec)
	return (self.x <= otherVec.x and self.y <= otherVec.y)
end

function BABYLON.Vector2:__len()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function BABYLON.Vector2:length()
	return self:__len()
end

function BABYLON.Vector2:lengthSquared()
	return (self.x * self.x + self.y * self.y) 
end

function BABYLON.Vector2:normalize()
	local len = self:length()
	
	if len == 0 then
		return
	end
	
	local num = 1.0 / len
	self.x = self.x * num
	self.y = self.y * num
end

function BABYLON.Vector2.Zero()
	return BABYLON.Vector2(0, 0)
end

function BABYLON.Vector2.Copy(source)
	return BABYLON.Vector2(source.x, source.y)
end

function BABYLON.Vector2.Normalize(vector)
	local newVector = BABYLON.Vector2.Copy(vector)
	newVector:normalize()
	return newVector
end

function BABYLON.Vector2.Minimize(left, right)
	local x,y
	
	if left.x < right.x then x = left.x else x = right.x end
	if left.y < right.y then y = left.y else y = right.y end
	
	return BABYLON.Vector2(x,y)
end

function BABYLON.Vector2.Maximize(left, right)
	local x,y
	
	if left.x > right.x then x = left.x else x = right.x end
	if left.y > right.y then y = left.y else y = right.y end
	
	return BABYLON.Vector2(x,y)
end

function BABYLON.Vector2.Transform(vector, transformation)
	local x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4])
	local y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5])
	
	return BABYLON.Vector2(x,y)
end

function BABYLON.Vector2.Distance(value1, value2)
	return math.sqrt(BABYLON.Vector2.DistanceSquared(value1, value2))
end

function BABYLON.Vector2.DistanceSquared(value1, value2)
	local x = value1.x - value2.x
	local y = value1.y - value2.y
	return (x * x) + (y * y)
end



--[[ Vector3 ]]--
BABYLON.Vector3 = class()
function BABYLON.Vector3:init(initialX, initialY, initialZ)
	self.x = initialX
	self.y = initialY
	self.z = initialZ
end

function BABYLON.Vector3:__tostring()
	return "{X: " .. self.x .. ", Y: " .. self.y .. ", Z: " .. self.z .. "}"
end

function BABYLON.Vector3:__add(otherVec)
	return BABYLON.Vector3(self.x + otherVec.x, self.y + otherVec.y, self.z + otherVec.z)
end

function BABYLON.Vector3:__sub(otherVec)
	return BABYLON.Vector3(self.x - otherVec.x, self.y - otherVec.y, self.z - otherVec.z)
end

function BABYLON.Vector3:__mul(otherVec)
	return BABYLON.Vector3(self.x * otherVec.x, self.y * otherVec.y, self.z * otherVec.z)
end

function BABYLON.Vector3:__div(otherVec)
	return BABYLON.Vector3(self.x / otherVec.x, self.y / otherVec.y, self.z / otherVec.z)
end

function BABYLON.Vector3:__idiv(otherVec)
	return BABYLON.Vector3(math.floor(self.x / otherVec.x), math.floor(self.y / otherVec.y), math.floor(self.z / otherVec.z))
end

function BABYLON.Vector3:__mod(otherVec)
	return BABYLON.Vector3(self.x % otherVec.x, self.y % otherVec.y, self.z % otherVec.z)
end

function BABYLON.Vector3:__pow(otherVec)
	return BABYLON.Vector3(self.x ^ otherVec.x, self.y ^ otherVec.y, self.z ^ otherVec.z)
end

function BABYLON.Vector3:__unm()
	return BABYLON.Vector3(-self.x, -self.y, -self.z)
end

function BABYLON.Vector3:scale(scale)
	return BABYLON.Vector3(self.x * scale, self.y * scale, self.z * scale)
end

function BABYLON.Vector3:__eq(otherVec)
	return (self.x == otherVec.x and self.y == otherVec.y and self.z == otherVec.z)
end

function BABYLON.Vector3:__lt(otherVec)
	return (self.x < otherVec.x and self.y < otherVec.y and self.z < otherVec.z)
end

function BABYLON.Vector3:__le(otherVec)
	return (self.x <= otherVec.x and self.y <= otherVec.y and self.z <= otherVec.z)
end

function BABYLON.Vector3:__len()
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function BABYLON.Vector3:length()
	return self:__len()
end

function BABYLON.Vector3:lengthSquared()
	return (self.x * self.x + self.y * self.y + self.z * self.z)
end

function BABYLON.Vector3:normalize()
	local len = self:length()
	
	if len == 0 then
		return
	end
	
	local num = 1.0 / len
	self.x = self.x * num
	self.y = self.y * num
	self.z = self.z * num
end

function BABYLON.Vector3.FromArray(array, offset)
	if offset == nil then
		offset = 1
	end
	
	return BABYLON.Vector3(array[offset], array[offset + 1], array[offset + 2])
end

function BABYLON.Vector3.Zero()
	return BABYLON.Vector3(0, 0, 0)
end

function BABYLON.Vector3.Up()
	return BABYLON.Vector3(0, 1.0, 0)
end

function BABYLON.Vector3.Copy(source)
	return BABYLON.Vector3(source.x, source.y, source.z)
end

function BABYLON.Vector3.TransformCoordinates(vector, transformation)
	local x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4]) + (vector.z * transformation.m[8]) + transformation.m[12]
	local y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5]) + (vector.z * transformation.m[9]) + transformation.m[13]
	local z = (vector.x * transformation.m[2]) + (vector.y * transformation.m[6]) + (vector.z * transformation.m[10])+ transformation.m[14]
	local w = (vector.x * transformation.m[3]) + (vector.y * transformation.m[7]) + (vector.z * transformation.m[11])+ transformation.m[15]
	return BABYLON.Vector3(x / w, y / w, z / w)
end

function BABYLON.Vector3.TransformNormal(vector, transformation)
	local x = (vector.x * transformation.m[0]) + (vector.y * transformation.m[4]) + (vector.z * transformation.m[8])
	local y = (vector.x * transformation.m[1]) + (vector.y * transformation.m[5]) + (vector.z * transformation.m[9])
	local z = (vector.x * transformation.m[2]) + (vector.y * transformation.m[6]) + (vector.z * transformation.m[10])
end

function BABYLON.Vector3.Dot(left, right)
	return (left.x * right.x + left.y * right.y + left.z * right.z)
end

function BABYLON.Vector3.Cross(left, right)
	local x = left.y * right.z - left.z * right.y
	local y = left.z * right.x - left.x * right.z
	local z = left.x * right.y - left.y * right.x
	return BABYLON.Vector3(x, y, z)
end

function BABYLON.Vector3.Normalize(vector)
	local newVector = BABYLON.Vector3.Copy(vector)
	newVector:normalize()
	return newVector
end

function BABYLON.Vector3.Distance(value1, value2)
	return math.sqrt(BABYLON.Vector3.DistanceSquared(value1, value2))
end

function BABYLON.Vector3.DistanceSquared(value1, value2)
	local x = value1.x - value2.x
	local y = value1.y - value2.y
	local z = value1.z - value2.z
	
	return (x * x) + (y * y) + (z * z)
end



--[[ Matrix ]]--
BABYLON.Matrix = class()
function BABYLON.Matrix:init()
	self.m = {}
end

function BABYLON.Matrix:__tostring()
	output = ""
	output = output .. "{0: " .. self.m[0] .. ", 1: " .. self.m[1] .. ", 2: " .. self.m[2] .. ", 3: " .. self.m[3] .. "},"
	output = output .. "{4: " .. self.m[4] .. ", 5: " .. self.m[5] .. ", 6: " .. self.m[6] .. ", 7: " .. self.m[7] .. "},"
	output = output .. "{8: " .. self.m[8] .. ", 9: " .. self.m[9] .. ", 10: " .. self.m[10] .. ", 11: " .. self.m[11] .. "},"
	output = output .. "{12: " .. self.m[12] .. ", 13: " .. self.m[13] .. ", 14: " .. self.m[14] .. ", 15: " .. self.m[15] .. "}"
	return output
end

function BABYLON.Matrix:isIdentity()
	if self.m[0] ~= 1.0 or self.m[5] ~= 1.0 or self.m[10] ~= 1.0 or self.m[15] ~= 1.0 then
	
	return false
	end

	if self.m[12] ~= 0.0 or self.m[13] ~= 0.0 or self.m[14] ~= 0.0 or self.m[4] ~= 0.0 or self.m[6] ~= 0.0 or self.m[7] ~= 0.0 or self.m[8] ~= 0.0 or self.m[9] ~= 0.0 or self.m[11] ~= 0.0 or self.m[12] ~= 0.0 or self.m[13] ~= 0.0 or self.m[14] ~= 0.0 then
		return false
	end

	return true
end

function BABYLON.Matrix:determinant()
	local temp1 = (self.m[10] * self.m[15]) - (self.m[11] * self.m[14])
	local temp2 = (self.m[9] * self.m[15]) - (self.m[11] * self.m[13])
	local temp3 = (self.m[9] * self.m[14]) - (self.m[10] * self.m[13])
	local temp4 = (self.m[8] * self.m[15]) - (self.m[11] * self.m[12])
	local temp5 = (self.m[8] * self.m[14]) - (self.m[10] * self.m[12])
	local temp6 = (self.m[8] * self.m[13]) - (self.m[9] * self.m[12])
	return ((((self.m[0] * (((self.m[5] * temp1) - (self.m[6] * temp2)) + (self.m[7] * temp3))) - (self.m[1] * (((self.m[4] * temp1) - (self.m[6] * temp4)) + (self.m[7] * temp5)))) + (self.m[2] * (((self.m[4] * temp2) - (self.m[5] * temp4)) + (self.m[7] * temp6)))) - (self.m[3] * (((self.m[4] * temp3) - (self.m[5] * temp5)) + (self.m[6] * temp6))))
end

function BABYLON.Matrix:toArray()
	return self.m
end

function BABYLON.Matrix:invert()
	local l1 = self.m[0]
	local l2 = self.m[1]
	local l3 = self.m[2]
	local l4 = self.m[3]
	local l5 = self.m[4]
	local l6 = self.m[5]
	local l7 = self.m[6]
	local l8 = self.m[7]
	local l9 = self.m[8]
	local l10 = self.m[9]
	local l11 = self.m[10]
	local l12 = self.m[11]
	local l13 = self.m[12]
	local l14 = self.m[13]
	local l15 = self.m[14]
	local l16 = self.m[15]
	local l17 = (l11 * l16) - (l12 * l15)
	local l18 = (l10 * l16) - (l12 * l14)
	local l19 = (l10 * l15) - (l11 * l14)
	local l20 = (l9 * l16) - (l12 * l13)
	local l21 = (l9 * l15) - (l11 * l13)
	local l22 = (l9 * l14) - (l10 * l13)
	local l23 = ((l6 * l17) - (l7 * l18)) + (l8 * l19)
	local l24 = -(((l5 * l17) - (l7 * l20)) + (l8 * l21))
	local l25 = ((l5 * l18) - (l6 * l20)) + (l8 * l22)
	local l26 = -(((l5 * l19) - (l6 * l21)) + (l7 * l22))
	local l27 = 1.0 / ((((l1 * l23) + (l2 * l24)) + (l3 * l25)) + (l4 * l26))
	local l28 = (l7 * l16) - (l8 * l15)
	local l29 = (l6 * l16) - (l8 * l14)
	local l30 = (l6 * l15) - (l7 * l14)
	local l31 = (l5 * l16) - (l8 * l13)
	local l32 = (l5 * l15) - (l7 * l13)
	local l33 = (l5 * l14) - (l6 * l13)
	local l34 = (l7 * l12) - (l8 * l11)
	local l35 = (l6 * l12) - (l8 * l10)
	local l36 = (l6 * l11) - (l7 * l10)
	local l37 = (l5 * l12) - (l8 * l9)
	local l38 = (l5 * l11) - (l7 * l9)
	local l39 = (l5 * l10) - (l6 * l9)
	self.m[0] = l23 * l27
	self.m[4] = l24 * l27
	self.m[8] = l25 * l27
	self.m[12] = l26 * l27
	self.m[1] = -(((l2 * l17) - (l3 * l18)) + (l4 * l19)) * l27
	self.m[5] = (((l1 * l17) - (l3 * l20)) + (l4 * l21)) * l27
	self.m[9] = -(((l1 * l18) - (l2 * l20)) + (l4 * l22)) * l27
	self.m[13] = (((l1 * l19) - (l2 * l21)) + (l3 * l22)) * l27
	self.m[2] = (((l2 * l28) - (l3 * l29)) + (l4 * l30)) * l27
	self.m[6] = -(((l1 * l28) - (l3 * l31)) + (l4 * l32)) * l27
	self.m[10] = (((l1 * l29) - (l2 * l31)) + (l4 * l33)) * l27
	self.m[14] = -(((l1 * l30) - (l2 * l32)) + (l3 * l33)) * l27
	self.m[3] = -(((l2 * l34) - (l3 * l35)) + (l4 * l36)) * l27
	self.m[7] = (((l1 * l34) - (l3 * l37)) + (l4 * l38)) * l27
	self.m[11] = -(((l1 * l35) - (l2 * l37)) + (l4 * l39)) * l27
	self.m[15] = (((l1 * l36) - (l2 * l38)) + (l3 * l39)) * l27
end

function BABYLON.Matrix:__mul(other)
	local result = BABYLON.Matrix()
	result.m[0] = self.m[0] * other.m[0] + self.m[1] * other.m[4] + self.m[2] * other.m[8] + self.m[3] * other.m[12]
	result.m[1] = self.m[0] * other.m[1] + self.m[1] * other.m[5] + self.m[2] * other.m[9] + self.m[3] * other.m[13]
	result.m[2] = self.m[0] * other.m[2] + self.m[1] * other.m[6] + self.m[2] * other.m[10] + self.m[3] * other.m[14]
	result.m[3] = self.m[0] * other.m[3] + self.m[1] * other.m[7] + self.m[2] * other.m[11] + self.m[3] * other.m[15]
	result.m[4] = self.m[4] * other.m[0] + self.m[5] * other.m[4] + self.m[6] * other.m[8] + self.m[7] * other.m[12]
	result.m[5] = self.m[4] * other.m[1] + self.m[5] * other.m[5] + self.m[6] * other.m[9] + self.m[7] * other.m[13]
	result.m[6] = self.m[4] * other.m[2] + self.m[5] * other.m[6] + self.m[6] * other.m[10] + self.m[7] * other.m[14]
	result.m[7] = self.m[4] * other.m[3] + self.m[5] * other.m[7] + self.m[6] * other.m[11] + self.m[7] * other.m[15]
	result.m[8] = self.m[8] * other.m[0] + self.m[9] * other.m[4] + self.m[10] * other.m[8] + self.m[11] * other.m[12]
	result.m[9] = self.m[8] * other.m[1] + self.m[9] * other.m[5] + self.m[10] * other.m[9] + self.m[11] * other.m[13]
	result.m[10] = self.m[8] * other.m[2] + self.m[9] * other.m[6] + self.m[10] * other.m[10] + self.m[11] * other.m[14]
	result.m[11] = self.m[8] * other.m[3] + self.m[9] * other.m[7] + self.m[10] * other.m[11] + self.m[11] * other.m[15]
	result.m[12] = self.m[12] * other.m[0] + self.m[13] * other.m[4] + self.m[14] * other.m[8] + self.m[15] * other.m[12]
	result.m[13] = self.m[12] * other.m[1] + self.m[13] * other.m[5] + self.m[14] * other.m[9] + self.m[15] * other.m[13]
	result.m[14] = self.m[12] * other.m[2] + self.m[13] * other.m[6] + self.m[14] * other.m[10] + self.m[15] * other.m[14]
	result.m[15] = self.m[12] * other.m[3] + self.m[13] * other.m[7] + self.m[14] * other.m[11] + self.m[15] * other.m[15]
	return result
end

function BABYLON.Matrix:__eq(value)
	return (self.m[0] == value.m[0] and self.m[1] == value.m[1] and self.m[2] == value.m[2] and self.m[3] == value.m[3] and self.m[4] == value.m[4] and self.m[5] == value.m[5] and self.m[6] == value.m[6] and self.m[7] == value.m[7] and self.m[8] == value.m[8] and self.m[9] == value.m[9] and self.m[10] == value.m[10] and self.m[11] == value.m[11] and self.m[12] == value.m[12] and self.m[13] == value.m[13] and self.m[14] == value.m[14] and self.m[15] == value.m[15])
end

function BABYLON.Matrix.FromValues(initialM11, initialM12, initialM13, initialM14, initialM21, initialM22, initialM23, initialM24, initialM31, initialM32, initialM33, initialM34, initialM41, initialM42, initialM43, initialM44)
	local result = BABYLON.Matrix()
	result.m[0] = initialM11
	result.m[1] = initialM12
	result.m[2] = initialM13
	result.m[3] = initialM14
	result.m[4] = initialM21
	result.m[5] = initialM22
	result.m[6] = initialM23
	result.m[7] = initialM24
	result.m[8] = initialM31
	result.m[9] = initialM32
	result.m[10] = initialM33
	result.m[11] = initialM34
	result.m[12] = initialM41
	result.m[13] = initialM42
	result.m[14] = initialM43
	result.m[15] = initialM44
	return result
end

function BABYLON.Matrix.Identity()
	return BABYLON.Matrix.FromValues(1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0)
end

function BABYLON.Matrix.Zero()
	return BABYLON.Matrix.FromValues(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
end

function BABYLON.Matrix.Copy(source)
	return BABYLON.Matrix.FromValues(source.m[0], source.m[1], source.m[2], source.m[3], source.m[4], source.m[5], source.m[6], source.m[7], source.m[8], source.m[9], source.m[10], source.m[11], source.m[12], source.m[13], source.m[14], source.m[15])
end

function BABYLON.Matrix.RotationX(angle)
	local result = BABYLON.Matrix.Zero()
	local s = math.sin(angle)
	local c = math.cos(angle)
	result.m[0] = 1.0
	result.m[15] = 1.0
	result.m[5] = c
	result.m[10] = c
	result.m[9] = -s
	result.m[6] = s
	return result
end

function BABYLON.Matrix.RotationY(angle)
	local result = BABYLON.Matrix.Zero()
	local s = math.sin(angle)
	local c = math.cos(angle)
	result.m[5] = 1.0
	result.m[15] = 1.0
	result.m[0] = c
	result.m[2] = -s
	result.m[8] = s
	result.m[10] = c
	return result
end

function BABYLON.Matrix.RotationZ(angle)
	local result = BABYLON.Matrix.Zero()
	local s = math.sin(angle)
	local c = math.cos(angle)
	result.m[10] = 1.0
	result.m[15] = 1.0
	result.m[0] = c
	result.m[1] = s
	result.m[4] = -s
	result.m[5] = c
	return result
end

function BABYLON.Matrix.RotationAxis(axis, angle)
	local s = math.sin(-angle)
	local c = math.cos(-angle)
	local c1 = 1 - c
	axis:normalize()
	local result = BABYLON.Matrix.Zero()
	result.m[0] = (axis.x * axis.x) * c1 + c
	result.m[1] = (axis.x * axis.y) * c1 - (axis.z * s)
	result.m[2] = (axis.x * axis.z) * c1 + (axis.y * s)
	result.m[3] = 0.0
	result.m[4] = (axis.y * axis.x) * c1 + (axis.z * s)
	result.m[5] = (axis.y * axis.y) * c1 + c
	result.m[6] = (axis.y * axis.z) * c1 - (axis.x * s)
	result.m[7] = 0.0
	result.m[8] = (axis.z * axis.x) * c1 - (axis.y * s)
	result.m[9] = (axis.z * axis.y) * c1 + (axis.x * s)
	result.m[10] = (axis.z * axis.z) * c1 + c
	result.m[11] = 0.0
	result.m[15] = 1.0
	return result
end

function BABYLON.Matrix.RotationYawPitchRoll(yaw, pitch, roll)
	return BABYLON.Matrix.RotationZ(roll) * BABYLON.Matrix.RotationX(pitch) * BABYLON.Matrix.RotationY(yaw)
end

function BABYLON.Matrix.Scaling(x, y, z)
	local result = BABYLON.Matrix.Zero()
	result.m[0] = x
	result.m[5] = y
	result.m[10] = z
	result.m[15] = 1.0
	return result
end

function BABYLON.Matrix.Translation(x, y, z)
	local result = BABYLON.Matrix.Identity()
	result.m[12] = x
	result.m[13] = y
	result.m[14] = z
	return result
end

function BABYLON.Matrix.LookAtLH(eye, target, up)
	local zAxis = target - eye
	zAxis:normalize()
	local xAxis = BABYLON.Vector3.Cross(up, zAxis)
	xAxis:normalize()
	local yAxis = BABYLON.Vector3.Cross(zAxis, xAxis)
	yAxis:normalize()
	local ex = -BABYLON.Vector3.Dot(xAxis, eye)
	local ey = -BABYLON.Vector3.Dot(yAxis, eye)
	local ez = -BABYLON.Vector3.Dot(zAxis, eye)
	return BABYLON.Matrix.FromValues(xAxis.x, yAxis.x, zAxis.x, 0, xAxis.y, yAxis.y, zAxis.y, 0, xAxis.z, yAxis.z, zAxis.z, 0, ex, ey, ez, 1)
end

function BABYLON.Matrix.PerspectiveLH(width, height, znear, zfar)
	local matrix = BABYLON.Matrix.Zero()
	matrix.m[0] = (2.0 * znear) / width
	matrix.m[1], matrix.m[2], matrix.m[3] = 0.0, 0.0, 0.0
	matrix.m[5] = (2.0 * znear) / height
	matrix.m[4], matrix.m[6], matrix.m[7] = 0.0, 0.0, 0.0
	matrix.m[10] = -zfar / (znear - zfar)
	matrix.m[8], matrix.m[9] = 0.0, 0.0
	matrix.m[11] = 1.0
	matrix.m[12], matrix.m[13], matrix.m[15] = 0.0, 0.0, 0.0
	matrix.m[14] = (znear * zfar) / (znear - zfar)
	return matrix
end

function BABYLON.Matrix.PerspectiveFovLH(fov, aspect, znear, zfar)
	local matrix = BABYLON.Matrix.Zero()
	local tan = 1.0 / (math.tan(fov * 0.5))
	matrix.m[0] = tan / aspect
	matrix.m[1], matrix.m[2], matrix.m[3] = 0.0, 0.0, 0.0
	matrix.m[5] = tan
	matrix.m[4], matrix.m[6], matrix.m[7] = 0.0, 0.0, 0.0
	matrix.m[8], matrix.m[9] = 0.0, 0.0
	matrix.m[10] = -zfar / (znear - zfar)
	matrix.m[11] = 1.0
	matrix.m[12], matrix.m[13], matrix.m[15] = 0.0, 0.0, 0.0
	matrix.m[14] = (znear * zfar) / (znear - zfar)
	return matrix
end

function BABYLON.Matrix.Transpose(matrix)
	local result = BABYLON.Matrix()
	result.m[0] = matrix.m[0]
	result.m[1] = matrix.m[4]
	result.m[2] = matrix.m[8]
	result.m[3] = matrix.m[12]
	result.m[4] = matrix.m[1]
	result.m[5] = matrix.m[5]
	result.m[6] = matrix.m[9]
	result.m[7] = matrix.m[13]
	result.m[8] = matrix.m[2]
	result.m[9] = matrix.m[6]
	result.m[10] = matrix.m[10]
	result.m[11] = matrix.m[14]
	result.m[12] = matrix.m[3]
	result.m[13] = matrix.m[7]
	result.m[14] = matrix.m[11]
	result.m[15] = matrix.m[15]
	return result
end



return BABYLON