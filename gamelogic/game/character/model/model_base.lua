local ModelBase = require("game/character/model/model_base_extra")

local _cache_mgr = game.CacheMgr
local _cache_time = 60
local _render_unit = game.RenderUnit

function ModelBase:_init()
	self.change_model_func = function()
		self:OnModelLoaded()
	end
end

function ModelBase:_delete()
	self:Reset()
end

function ModelBase:Init(draw_obj, model_type, body_type)
	self._draw_obj = draw_obj
	self._model_id = nil
	self._model_obj = nil

	self._body_type = body_type or game.ModelBodyMap[model_type]
	self._model_type = model_type

	self.is_enable = true
	self.is_visible = true

	if not self._root_obj then
		self._root_obj = game.GamePool.GameObjectPool:Create()
		_render_unit:AddToObjLayer(self:GetRoot())
	end
end

function ModelBase:Reset()
	if self._model_obj then
		_cache_mgr:FreeObj(self._model_obj)
		self._model_obj = nil
	end

	if self._new_model_obj then
		_cache_mgr:FreeObj(self._new_model_obj)
		self._new_model_obj = nil
	end

	if self._root_obj then
		game.GamePool.GameObjectPool:Free(self._root_obj)
		self._root_obj = nil
	end

	self._draw_obj = nil
	self._model_id = nil

	self._body_type = nil
	self._model_type = nil

	self.layer = nil
	self.always_anim = nil
	self.anim_name = nil
	self.anim_speed = nil
	self.anim_cfg = nil
	self.model_load_callback = nil
end

function ModelBase:GetRoot()
	return self._root_obj.tran
end

function ModelBase:GetModelID()
	return self._model_id
end

function ModelBase:SetParent(parent)
	self._root_obj.tran:SetParent(parent, false)
end

function ModelBase:GetRotation()
	return self._root_obj.tran:GetRotation()
end

function ModelBase:SetRotation(x, y, z)
	return self._root_obj.tran:SetRotation(x, y, z)
end

function ModelBase:ChangeModel(id, func)
	if self._model_id == id then
		return
	end
	self._model_id = id

	if self._new_model_obj then
		_cache_mgr:FreeObj(self._new_model_obj)
		self._new_model_obj = nil
	end

	self.anim_cfg = nil
	self.model_load_callback = func

	local path = self:GetModelPath(id)
	self._new_model_obj = _cache_mgr:CreateModelObj(path, _cache_time, false)
	self._new_model_obj:SetLoadCallBack(self.change_model_func)
end

function ModelBase:OnModelLoaded()
	if self._new_model_obj:GetModelTransform() then
		if self._model_obj then
			_cache_mgr:FreeObj(self._model_obj)
			self._model_obj = nil
		end

		self._model_obj = self._new_model_obj
		self._model_obj:SetParent(self._root_obj.tran)
		self._new_model_obj = nil

		if self.layer then
			self:SetLayer(self.layer)
		end

		if self.always_anim then
			self:SetAlwaysAnim(self.always_anim)
		end

		self:SetShow(self.is_enable and self.is_visible)

		if self.anim_name then
			self:PlayAnim(self.anim_name, self.anim_speed, 0, true)
		end

		if self.model_load_callback then
			self.model_load_callback(self._model_type, self)
		end
	else
		_cache_mgr:FreeObj(self._new_model_obj)
		self._new_model_obj = nil
	end
end

function ModelBase:GetModelTransform()
	if self._model_obj then
		return self._model_obj:GetModelTransform()
	end
end

function ModelBase:GetChild(name)
	if self._model_obj then
		return self._model_obj:GetChild(name)
	end
end

function ModelBase:AddChild(name, node)
	if self._model_obj then
		if name ~= game.ModelNodeName.Root then
			self._model_obj:AddChild(name, node)
		else
			self._model_obj:AddChild(nil, node)
		end
	end
end

function ModelBase:SetEnable(val)
	if self.is_enable == val then
		return
	end
	self.is_enable = val
	self:_ResetShow()
end

function ModelBase:SetVisible(val)
	if self.is_visible == val then
		return
	end
	self.is_visible = val
	self:_ResetShow()
end

function ModelBase:IsShow()
	return self.is_visible and self.is_enable
end

function ModelBase:_ResetShow()
	if self.is_enable and self.is_visible then
		self:SetShow(true)
		self._root_obj.tran:SetPosition(0, 0, 0)
	else
		self:SetShow(false)
		self._root_obj.tran:SetPosition(-10000, -10000, -10000)
	end
end

-- state
function ModelBase:SetLayer(layer_name)
	self.layer = layer_name
	if self._model_obj then
		self._model_obj:SetLayer(layer_name)
	end
end

function ModelBase:SetAlwaysAnim(val)
	self.always_anim = val
	if self._model_obj then
		self._model_obj:SetAlwaysAnim(val)
	end
end

-- anim
function ModelBase:PlayAnim(name, speed, fade_time, is_force)
	if not is_force and self.anim_name == name then
		return
	end

	self.anim_name = name
	self.anim_speed = speed

	if self._model_obj then
		self._model_obj:PlayAnim(name, speed, fade_time)
	end
end

function ModelBase:GetAnimTime(name)
	if not self.anim_cfg then
		self.anim_cfg = game.AnimMgr:GetAnimConfig(self._body_type, self:GetBoneID(self._model_id))
	end
	if self.anim_cfg then
		return self.anim_cfg[name] or 1
	else
		return 1
	end
end

function ModelBase:SetMatEffect(eff_name, enable)
	if self._model_obj then
		self._model_obj:SetMatEffect(eff_name, enable)
	end
end

function ModelBase:SetMatPropertyColor(id, r, g, b, a)
	if self._model_obj then
		self._model_obj:SetMatPropertyColor(id, r, g, b, a)
	end
end

function ModelBase:SetMatPropertyVector(id, x, y, z, w)
	if self._model_obj then
		self._model_obj:SetMatPropertyVector(id, x, y, z, w)
	end
end

function ModelBase:SetMatPropertyFloat(id, val)
	if self._model_obj then
		self._model_obj:SetMatPropertyFloat(id, val)
	end
end

function ModelBase:ExchangeShader()
	if self._model_obj then
		self._model_obj:ExchangeShader()
	end
end

return ModelBase
