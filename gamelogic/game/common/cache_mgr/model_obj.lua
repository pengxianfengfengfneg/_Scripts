
local ModelObj = Class(require("game/common/cache_mgr/cache_obj"))

local _anim_hash_map = game.ObjAnimHash

function ModelObj:_init()
	self.state = {}
end

function ModelObj:_delete()

end

function ModelObj:Reset()
	ModelObj.super.Reset(self)

	self._model_ctrl = nil
	self._mat_ctrl = nil
	self.state.layer = nil
	self.state.always_anim = nil
end

function ModelObj:ResetObj()
	ModelObj.super.ResetObj(self)

	if self._model_tran then
		if self.state.layer then
			self._model_tran:SetLayer(self.state.layer, true)
		end
		if self.state.always_anim then
			self._model_tran:SetAlwaysAnim(self.state.always_anim)
		end

		if self._mat_ctrl then
			self._mat_ctrl:ClearAllMaterials()
		end

		if self._model_ctrl then
			self._model_ctrl:SetEnable(false)
		end
	end
end

function ModelObj:OnLoadFinish(item, desc)
	ModelObj.super.OnLoadFinish(self, item, desc)

	if self._model_tran then
		if not item.model_ctrl then
			item.model_ctrl = self._model_tran:GetComponent(ModelController)
		end
		if not item.mat_ctrl then
			item.mat_ctrl = self._model_tran:GetComponent(MaterialController)
		end
		self._model_ctrl = item.model_ctrl
		self._mat_ctrl = item.mat_ctrl

		if self._model_ctrl then
			self._model_ctrl:SetEnable(true)
		end
	end

	if self._load_callback then
		self._load_callback()
	end
end

function ModelObj:GetChild(path)
	if not path or not self._model_tran then
		return
	end

	return self._model_tran:Find(path)
end

function ModelObj:AddChild(name, node)
	if not self._model_tran then
		return
	end

	if not name then
		self._model_tran:AddChild(node)
	else
		self._model_tran:AddChild(node, name)
	end
end

function ModelObj:PlayAnim(name, speed, fade_time)
	local hash_name = _anim_hash_map[name]
	if hash_name and self._model_ctrl then
		self._model_ctrl:PlayAnim(name, hash_name, speed or 1, fade_time or 0)
	end
end

function ModelObj:SetLayer(layer)
	if self._model_tran then
		local old_layer = self._model_tran:SetLayer(layer, true)
		if not self.state.layer then
			self.state.layer = old_layer
		end
	end
end

function ModelObj:SetAlwaysAnim(val)
	if self._model_tran then
		self._model_tran:SetAlwaysAnimate(val)
		if not self.state.always_anim then
			self.state.always_anim = false
		end
	end
end

function ModelObj:SetMatEffect(eff_name, enable)
	if self._mat_ctrl then
		if enable then
			self._mat_ctrl:AddMaterial(eff_name)
		else
			self._mat_ctrl:RemoveMaterial(eff_name)
		end
	end
end

function ModelObj:SetMatPropertyColor(id, r, g, b, a)
	if self._mat_ctrl then
		self._mat_ctrl:SetPropertyColor(id, r, g, b, a)
	end
end

function ModelObj:SetMatPropertyVector(id, x, y, z, w)
	if self._mat_ctrl then
		self._mat_ctrl:SetPropertyVector(id, x, y, z, w)
	end
end

function ModelObj:SetMatPropertyFloat(id, val)
	if self._mat_ctrl then
		self._mat_ctrl:SetPropertyFloat(id, val)
	end
end

function ModelObj:ExchangeShader()
	if self._mat_ctrl then
		self._mat_ctrl:ExchangeShader()
	end
end

return ModelObj
