local assert = assert
local io = io
local string = string
local table = table
local math = math

local fenster = require('fenster')

---@class Texture
---@field buffer integer[]
---@field width integer
---@field height integer
local Texture = {}
Texture.__index = Texture

---Creates a new texture instance and loads the texture from a PPM file
---@param filename string
---@return Texture
---@nodiscard
function Texture.new(filename)
	local self = setmetatable({}, Texture)

	local image = assert(io.open(filename, 'rb'))

	local image_type = image:read(2)
	assert(image_type == 'P6', 'Invalid image type: ' .. tostring(image_type))
	assert(image:read(1), 'Invalid image header') -- Whitespace
	self.width = image:read('*number')
	assert(self.width, 'Invalid image width: ' .. tostring(self.width))
	assert(image:read(1), 'Invalid image header') -- Whitespace
	self.height = image:read('*number')
	assert(self.height, 'Invalid image height: ' .. tostring(self.height))
	assert(image:read(1), 'Invalid image header') -- Whitespace
	local image_max_color = image:read('*number')
	assert(
		image_max_color == 255,
		'Invalid image maximum color: ' .. tostring(image_max_color)
	)
	assert(image:read(1), 'Invalid image header') -- Whitespace

	self.buffer = {}
	while true do
		local r_raw = image:read(1)
		local g_raw = image:read(1)
		local b_raw = image:read(1)
		if not r_raw or not g_raw or not b_raw then
			break
		end

		local r = string.byte(r_raw)
		local g = string.byte(g_raw)
		local b = string.byte(b_raw)
		table.insert(self.buffer, fenster.rgb(r, g, b))
	end

	image:close()

	return self
end

---Takes the U & V coordinates exported by Blender
---and return the corresponding pixel color in the texture
---@param tu number
---@param tv number
---@return integer
---@nodiscard
function Texture:map(tu, tv)
	-- Using a % operator to cycle/repeat the texture if needed
	local u = math.abs(math.floor(tu * self.width) % self.width)
	local v = math.abs(math.floor(tv * self.height) % self.height)

	return self.buffer[(u + v * self.width) + 1]
end

return Texture
