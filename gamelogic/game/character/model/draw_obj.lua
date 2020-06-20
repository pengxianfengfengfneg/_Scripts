local DrawObj = Class()

local _model_type = game.ModelType
local _game_pool = game.GamePool

function DrawObj:_init()
	self.change_model_func = function(t)
		if t == _model_type.Body then
			local body_model = self.model_list[_model_type.Body]
			for k,v in pairs(self.model_list) do
				if k ~= t and v:GetHangNode() then
					body_model:AddChild(v:GetHangNode(), v._root_obj.tran)
				end
			end
		end

		if self.mat_eff_list then
			for k,v in pairs(self.mat_eff_list) do
				if v then
					self:SetMatEffect(k, v, t)
				end
			end
		end

		if self.model_change_callback then
			self.model_change_callback(t)
		end
	end
end

function DrawObj:_delete()
	self:Reset()
end

function DrawObj:Init(body_type)
	self.root_obj = _game_pool.GameObjectPool:Create()

	self.is_enable = true
	self.is_visible = true

	self.body_type = body_type
	self.model_list = {}
	self.model_enable = {}
	self.model_visible = {}
	self.effect_list = {}
end

function DrawObj:Reset()
	self.model_layer = nil
	self.always_anim = nil
	self.mat_eff_list = nil
	self.model_change_callback = nil

	if self.model_list then
		local last_free_model = _model_type.Body
		local mount_model = self.model_list[_model_type.Mount]
		if mount_model then
			last_free_model = _model_type.Mount
		end
		for k,v in pairs(self.model_list) do
			if k ~= last_free_model then
				_game_pool.ModelBasePool:Free(v)
			end
		end
		if self.model_list[last_free_model] then
			_game_pool.ModelBasePool:Free(self.model_list[last_free_model])
		end
		self.model_list = nil
	end
	self.model_enable = nil
	self.model_visible = nil

	if self.root_obj then
		_game_pool.GameObjectPool:Free(self.root_obj)
		self.root_obj = nil
	end
	self:FreeAllEffect()
end

function DrawObj:GetRoot()
	return self.root_obj.tran
end

function DrawObj:SetParent(t)
	self.root_obj.tran:SetParent(t, false)
end

function DrawObj:SetPosition(x, y, z)
	self.root_obj.tran:SetPosition(x, y, z)
end

function DrawObj:SetScale(val)
	self.root_obj.tran:SetScale(val, val, val)
end

function DrawObj:SetRotation(x, y, z)
	self.root_obj.tran:SetRotation(x, y, z)
end

function DrawObj:GetRotation()
	return self.root_obj.tran:GetRotation()
end

-- model change
function DrawObj:CreateModel(model_type)
	local model = self.model_list[model_type]
	if model then
		return model
	end

	model = _game_pool.ModelBasePool:Create()
	model:Init(self, model_type, model_type == game.ModelType.Body and self.body_type or nil)
	self.model_list[model_type] = model

	if self.model_layer then
		model:SetLayer(self.model_layer)
	end

	if self.always_anim then
		model:SetAlwaysAnim(self.always_anim)
	end

	local is_visible = true
	if self.model_visible[model_type] ~= nil then
		is_visible = self.model_visible[model_type]
	end
	model:SetVisible(is_visible)

	local is_enable = true
	if self.model_enable[model_type] ~= nil then
		is_enable = self.model_enable[model_type]
	end
	model:SetEnable(is_enable)

	return model
end

function DrawObj:DelModel(model_type)
	local model = self.model_list[model_type]
	if model then
		model:SetShow(false)
		_game_pool.ModelBasePool:Free(model)
		self.model_list[model_type] = nil
	end
	self:FreeEffect(model_type)
end

function DrawObj:GetModel(model_type)
	return self.model_list[model_type]
end

function DrawObj:GetModelTransform(model_type)
	if self.model_list[model_type or _model_type.Body] then
		return self.model_list[model_type or _model_type.Body]:GetModelTransform()
	end
end

function DrawObj:SetModelChangeCallBack(callback)
	self.model_change_callback = callback
end

--ÉèÖÃÄ£ÐÍ
function DrawObj:SetModelID(model_type, id, career)
	self:FreeEffect(model_type)
	local model = self.model_list[model_type]
	if not model then
		model = self:CreateModel(model_type)

		if model:GetNewPos() then
			local func = model:GetNewPos()
			local new_pos = func()
			model._root_obj.tran:SetPosition(new_pos.x, new_pos.y, new_pos.z)
		end

		local hang_node = model:GetHangNode()
		if not hang_node then
			model:SetParent(self.root_obj.tran)
		else
			local body_model = self.model_list[_model_type.Body]
			if body_model then
				body_model:AddChild(hang_node, model._root_obj.tran)
			end
		end
	end
	if model_type == 16 then
		if career == nil then
			local role_info = game.SelectRoleView.instance:GetRoleInfo()
			if role_info == nil then
				role_info = game.LoginCtrl.instance:GetLastLoginRoleInfo()
			end
			if role_info.career == 2 and id > 4008 then
				model:SetRotation(30,20,30)
			elseif role_info.career == 3 and id > 4008 then
				model:SetRotation(90,0,0)
			elseif role_info.career == 4 and id > 4008 then
				model:SetRotation(0,-90,10)
			end
		else
			if career == 2 and id > 4008 then
				model:SetRotation(30,20,30)
			elseif career == 3 and id > 4008 then
				model:SetRotation(90,0,0)
			elseif career == 4 and id > 4008 then
				model:SetRotation(0,-90,10)
			end
		end

	end
	model:ChangeModel(id, self.change_model_func)
end

function DrawObj:GetModelID(model_type)
	local model = self.model_list[model_type]
	if model then
		return model:GetModelID()
	end
end

function DrawObj:AddToModel(model_node, node, model_type)
	local model = self.model_list[model_type or _model_type.Body]
	if model then
		return model:AddChild(model_node, node)
	end
end

function DrawObj:GetModelNode(name, model_type)
	local model = self.model_list[model_type or _model_type.Body]
	if model then
		return model:GetChild(name)
	end
end

-- anim
function DrawObj:PlayLayerAnim(model_type, name, speed, fade_time, is_force)
	for k,v in pairs(self.model_list) do
		if model_type & k > 0 then
			v:PlayAnim(name, speed, fade_time, is_force)
		end
	end
end

function DrawObj:GetAnimTime(name)
	local model = self.model_list[_model_type.Body]
	if model then
		return model:GetAnimTime(name)
	end
	return 0
end

-- model state
function DrawObj:SetEnable(val)
	if self.is_enable == val then
		return
	end
	self.is_enable = val
	self:_ResetShow(self.is_enable and self.is_visible)
end

function DrawObj:SetVisible(val)
	if self.is_visible == val then
		return
	end
	self.is_visible = val
	self:_ResetShow(self.is_enable and self.is_visible)
end

function DrawObj:_ResetShow(val)
	if val then
		self.root_obj.tran:SetPosition(0, 0, 0)
	else
		self.root_obj.tran:SetPosition(-10000, -10000, -10000)
	end
end

function DrawObj:SetModelEnable(model_type, val)
	local model = self.model_list[model_type]
	if model then
		model:SetEnable(val)
	end
	self.model_enable[model_type] = val
end

function DrawObj:SetModelVisible(model_type, val)
	local model = self.model_list[model_type]
	if model then
		model:SetVisible(val)
	end
	self.model_visible[model_type] = val
end

function DrawObj:SetLayer(layer_name)
	self.model_layer = layer_name
	for k,v in pairs(self.model_list) do
		v:SetLayer(layer_name)
	end
end

function DrawObj:SetAlwaysAnim(val)
	self.always_anim = val
	for k,v in pairs(self.model_list) do
		v:SetAlwaysAnim(val)
	end
end

-- material
function DrawObj:SetMatEffect(eff_name, enable, model_type)
	if model_type then
		local model = self.model_list[model_type]
		if model then
			model:SetMatEffect(eff_name, enable)
		end
	else
		if not self.mat_eff_list then
			self.mat_eff_list = {}
		end
		self.mat_eff_list[eff_name] = enable
		for k,v in pairs(self.model_list) do
			v:SetMatEffect(eff_name, enable)
		end
	end
end

function DrawObj:SetMatPropertyColor(id, r, g, b, a, model_type)
	if model_type then
		local model = self.model_list[model_type]
		if model then
			model:SetMatPropertyColor(id, r, g, b, a)
		end
	else
		for k,v in pairs(self.model_list) do
			v:SetMatPropertyColor(id, r, g, b, a)
		end
	end
end

function DrawObj:SetMatPropertyFloat(id,val, model_type)
	if model_type then
		local model = self.model_list[model_type]
		if model then
			model:SetMatPropertyFloat(id, val)
		end
	else
		for k,v in pairs(self.model_list) do
			v:SetMatPropertyFloat(id, val)
		end
	end
end

function DrawObj:SetMatPropertyVector(id, r, g, b, a, model_type)
	if model_type then
		local model = self.model_list[model_type]
		if model then
			model:SetMatPropertyVector(id, r, g, b, a)
		end
	else
		for k,v in pairs(self.model_list) do
			v:SetMatPropertyVector(id, r, g, b, a)
		end
	end
end

function DrawObj:ExchangeShader(model_type)
	local model = self.model_list[model_type]
	if model then
		model:ExchangeShader()
	end
end

function DrawObj:SetEffectID(hang_node, id, hang_model_type, is_ui)
	local effect = game.EffectMgr.instance:CreateEffect(string.format("effect/model/%s.ab", id), 10)
	if self.effect_list[hang_model_type] == nil then
		self.effect_list[hang_model_type] = {}
	end
	table.insert(self.effect_list[hang_model_type], effect:GetID())
	effect:SetLoop(true)
	if is_ui then
		effect:SetLoadCallBack(function()
			effect:SetLayer(game.LayerName.UI)
		end)
	end

	local body_model = self.model_list[hang_model_type]
	if body_model then
		body_model:AddChild(hang_node, effect:GetRoot())
	end
end

function DrawObj:FreeEffect(model_type)
	if self.effect_list then
		if self.effect_list[model_type] then
			for i, v in pairs(self.effect_list[model_type]) do
				game.EffectMgr.instance:StopEffectByID(v)
			end
			self.effect_list[model_type] = nil
		end
	end
end

function DrawObj:FreeAllEffect()
	if self.effect_list then
		for i, v in pairs(self.effect_list) do
			for k, val in pairs(v) do
				game.EffectMgr.instance:StopEffectByID(val)
			end
		end
		self.effect_list = nil
	end
end

function DrawObj:GetBodyType()
	return self.body_type
end

return DrawObj
