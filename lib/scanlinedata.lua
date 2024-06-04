local class = require('lib.class')

---@class ScanLineData
---@overload fun(curr_y: integer?, ndotla: number?, ndotlb: number?, ndotlc: number?, ndotld: number?, ua: number?, ub: number?, uc: number?, ud: number?, va: number?, vb: number?, vc: number?, vd: number?): ScanLineData
---@field curr_y integer
---@field ndotla number
---@field ndotlb number
---@field ndotlc number
---@field ndotld number
---@field ua number
---@field ub number
---@field uc number
---@field ud number
---@field va number
---@field vb number
---@field vc number
---@field vd number
local ScanLineData = class()

---Creates a new scan line data instance
---@param curr_y integer?
---@param ndotla number?
---@param ndotlb number?
---@param ndotlc number?
---@param ndotld number?
---@param ua number?
---@param ub number?
---@param uc number?
---@param ud number?
---@param va number?
---@param vb number?
---@param vc number?
---@param vd number?
function ScanLineData:new(
	curr_y,
	ndotla, ndotlb, ndotlc, ndotld,
	ua, ub, uc, ud,
	va, vb, vc, vd
)
	self.curr_y = curr_y or 0
	self.ndotla = ndotla or 0
	self.ndotlb = ndotlb or 0
	self.ndotlc = ndotlc or 0
	self.ndotld = ndotld or 0
	self.ua = ua or 0
	self.ub = ub or 0
	self.uc = uc or 0
	self.ud = ud or 0
	self.va = va or 0
	self.vb = vb or 0
	self.vc = vc or 0
	self.vd = vd or 0
end

return ScanLineData
