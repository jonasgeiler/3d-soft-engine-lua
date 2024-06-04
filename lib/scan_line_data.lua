local class = require('lib.class')

---Represents scan line data
---@class scan_line_data
---@overload fun(curr_y: integer?, ndotla: number?, ndotlb: number?, ndotlc: number?, ndotld: number?): scan_line_data
---@field curr_y integer
---@field ndotla number
---@field ndotlb number
---@field ndotlc number
---@field ndotld number
local scan_line_data = class()

---Init the scan line data
---@param curr_y integer?
---@param ndotla number?
---@param ndotlb number?
---@param ndotlc number?
---@param ndotld number?
function scan_line_data:new(curr_y, ndotla, ndotlb, ndotlc, ndotld)
	self.curr_y = curr_y or 0
	self.ndotla = ndotla or 0
	self.ndotlb = ndotlb or 0
	self.ndotlc = ndotlc or 0
	self.ndotld = ndotld or 0
end

return scan_line_data
