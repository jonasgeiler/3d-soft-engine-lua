local setmetatable = setmetatable

---Creates a class
---@param base table?
---@return table
---@nodiscard
local function class(base)
	local cls = {}
	cls.__index = cls

	setmetatable(cls, {
		__index = base,
		__call = function(c, ...)
			local instance = setmetatable({}, c)
			local new = instance.new ---@type fun(instance: table, ...)
			if new then new(instance, ...) end
			return instance
		end,
	})

	return cls
end

return class
