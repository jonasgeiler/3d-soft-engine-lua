local math = math

---@class Matrix
---@field m number[]
---@operator mul(Matrix): Matrix
local Matrix = {}
Matrix.__index = Matrix

---Creates a new matrix instance
---@param m11 number?
---@param m12 number?
---@param m13 number?
---@param m14 number?
---@param m21 number?
---@param m22 number?
---@param m23 number?
---@param m24 number?
---@param m31 number?
---@param m32 number?
---@param m33 number?
---@param m34 number?
---@param m41 number?
---@param m42 number?
---@param m43 number?
---@param m44 number?
---@return Matrix
---@nodiscard
function Matrix.new(
	m11, m12, m13, m14,
	m21, m22, m23, m24,
	m31, m32, m33, m34,
	m41, m42, m43, m44
)
	local self = setmetatable({}, Matrix)

	self.m = {
		m11 or 0, m12 or 0, m13 or 0, m14 or 0,
		m21 or 0, m22 or 0, m23 or 0, m24 or 0,
		m31 or 0, m32 or 0, m33 or 0, m34 or 0,
		m41 or 0, m42 or 0, m43 or 0, m44 or 0,
	}

	return self
end

---Multiply two matrices
---@param a Matrix
---@param b Matrix
---@return Matrix
---@nodiscard
function Matrix.__mul(a, b)
	return Matrix.new(
		a.m[1] * b.m[1] + a.m[2] * b.m[5] + a.m[3] * b.m[9] + a.m[4] * b.m[13],
		a.m[1] * b.m[2] + a.m[2] * b.m[6] + a.m[3] * b.m[10] + a.m[4] * b.m[14],
		a.m[1] * b.m[3] + a.m[2] * b.m[7] + a.m[3] * b.m[11] + a.m[4] * b.m[15],
		a.m[1] * b.m[4] + a.m[2] * b.m[8] + a.m[3] * b.m[12] + a.m[4] * b.m[16],
		a.m[5] * b.m[1] + a.m[6] * b.m[5] + a.m[7] * b.m[9] + a.m[8] * b.m[13],
		a.m[5] * b.m[2] + a.m[6] * b.m[6] + a.m[7] * b.m[10] + a.m[8] * b.m[14],
		a.m[5] * b.m[3] + a.m[6] * b.m[7] + a.m[7] * b.m[11] + a.m[8] * b.m[15],
		a.m[5] * b.m[4] + a.m[6] * b.m[8] + a.m[7] * b.m[12] + a.m[8] * b.m[16],
		a.m[9] * b.m[1] + a.m[10] * b.m[5] + a.m[11] * b.m[9] + a.m[12] * b.m
		[13],
		a.m[9] * b.m[2] + a.m[10] * b.m[6] + a.m[11] * b.m[10] +
		a.m[12] * b.m[14],
		a.m[9] * b.m[3] + a.m[10] * b.m[7] + a.m[11] * b.m[11] +
		a.m[12] * b.m[15],
		a.m[9] * b.m[4] + a.m[10] * b.m[8] + a.m[11] * b.m[12] +
		a.m[12] * b.m[16],
		a.m[13] * b.m[1] + a.m[14] * b.m[5] + a.m[15] * b.m[9] +
		a.m[16] * b.m[13],
		a.m[13] * b.m[2] + a.m[14] * b.m[6] + a.m[15] * b.m[10] +
		a.m[16] * b.m[14],
		a.m[13] * b.m[3] + a.m[14] * b.m[7] + a.m[15] * b.m[11] +
		a.m[16] * b.m[15],
		a.m[13] * b.m[4] + a.m[14] * b.m[8] + a.m[15] * b.m[12] +
		a.m[16] * b.m[16]
	)
end

---Create a x-rotation matrix
---@param angle number
---@return Matrix
---@nodiscard
function Matrix.rotation_x(angle)
	local s = math.sin(angle)
	local c = math.cos(angle)
	return Matrix.new(
		1, 0, 0, 0,
		0, c, s, 0,
		0, -s, c, 0,
		0, 0, 0, 1
	)
end

---Create a y-rotation matrix
---@param angle number
---@return Matrix
---@nodiscard
function Matrix.rotation_y(angle)
	local s = math.sin(angle)
	local c = math.cos(angle)
	return Matrix.new(
		c, 0, -s, 0,
		0, 1, 0, 0,
		s, 0, c, 0,
		0, 0, 0, 1
	)
end

---Create a z-rotation matrix
---@param angle number
---@return Matrix
---@nodiscard
function Matrix.rotation_z(angle)
	local s = math.sin(angle)
	local c = math.cos(angle)
	return Matrix.new(
		c, s, 0, 0,
		-s, c, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1
	)
end

---Create a yaw-pitch-roll rotation matrix
---@param yaw number
---@param pitch number
---@param roll number
---@return Matrix
---@nodiscard
function Matrix.rotation_yaw_pitch_roll(yaw, pitch, roll)
	return Matrix.rotation_z(roll) *
		Matrix.rotation_x(pitch) *
		Matrix.rotation_y(yaw)
end

---Create a translation matrix
---@param x number
---@param y number
---@param z number
---@return Matrix
---@nodiscard
function Matrix.translation(x, y, z)
	return Matrix.new(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		x, y, z, 1
	)
end

---Create a look-at matrix for a left-handed coordinate system
---@param eye Vector3
---@param target Vector3
---@param up Vector3
---@return Matrix
---@nodiscard
function Matrix.look_at_lh(eye, target, up)
	local z_axis = (target - eye)
	z_axis:normalize()
	local x_axis = up:cross(z_axis)
	x_axis:normalize()
	local y_axis = z_axis:cross(x_axis)
	y_axis:normalize()

	return Matrix.new(
		x_axis.x, y_axis.x, z_axis.x, 0,
		x_axis.y, y_axis.y, z_axis.y, 0,
		x_axis.z, y_axis.z, z_axis.z, 0,
		-x_axis:dot(eye), -y_axis:dot(eye), -z_axis:dot(eye), 1
	)
end

---Create a perspective projection matrix for a left-handed coordinate system
---@param fov number
---@param aspect number
---@param z_near number
---@param z_far number
---@return Matrix
---@nodiscard
function Matrix.perspective_fov_lh(fov, aspect, z_near, z_far)
	local tan = 1 / math.tan(fov / 2)
	return Matrix.new(
		tan / aspect, 0, 0, 0,
		0, tan, 0, 0,
		0, 0, -z_far / (z_near - z_far), 1,
		0, 0, (z_near * z_far) / (z_near - z_far), 0
	)
end

return Matrix
