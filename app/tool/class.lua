local _class = {}

function Class(super)
	local class_type = {}
	class_type._init = false
	class_type._delete = false
	class_type.super = super

	local vtbl = {}
	_class[class_type] = vtbl

	class_type.New = function(...) 
		local obj = {}
		obj._class_type = class_type

		setmetatable(obj, { __index = vtbl})

		do
			local create
			create = function(c, ...)
				if c.super then
					create(c.super, ...)
				end
				if c._init then
					c._init(obj, ...)
				end
			end
			create(class_type, ...)
		end

		obj.DeleteMe = function(self)
			local now_super = self._class_type
			while now_super ~= nil do
				if now_super._delete then
					now_super._delete(self)
				end
				now_super = now_super.super
			end
		end

		return obj
	end

	setmetatable(class_type, {
		__newindex = function(t,k,v)
			vtbl[k] = v
		end,
		__index = vtbl
	})
 
	if super then
		local super_class = _class[super]
		setmetatable(vtbl, { 
			__index = function(t,k)
				local ret = super_class[k]
				-- t[k] = ret
				return ret
			end
		})
	end
 
	return class_type
end
