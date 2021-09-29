class = function(prototype)
	local derived={}
 	if prototype then
 		function derived.__index(t,key)
 			return rawget(derived,key) or prototype[key]
 		end
 	else
 		function derived.__index(t,key)
 			return rawget(derived,key)
 		end
 	end
 	function derived.__call(proto,...)
 		local instance={}
 		setmetatable(instance,proto)
 		local init=instance.init
 		if init then
 			init(instance,...)
 		end
 		return instance
 	end
 	setmetatable(derived,derived)
 	return derived
 end