
local CacheObj = Class()

function CacheObj:_init()
	self.state = {}
end

function CacheObj:_delete()

end

function CacheObj:Init(obj_id, path)
	self._obj_id = obj_id
	self._path = path
end

function CacheObj:Reset()
	self._cahce_item = nil
	self._model_tran = nil
	self._model_desc = nil
	self._load_callback = nil
end

function CacheObj:ResetObj()

end

function CacheObj:SetLoadCallBack(callback)
	self._load_callback = callback
end

function CacheObj:OnLoadFinish(item, desc)
	if item then
		self._cahce_item = item
		self._model_tran = item.obj
		self._model_desc = desc
	end
end

function CacheObj:SetParent(parent)
	if self._model_tran then
		self._model_tran:SetParent(parent, false)
	end
end

function CacheObj:GetModelTransform()
	return self._model_tran
end

function CacheObj:IsOverTime()
	return false
end

return CacheObj
