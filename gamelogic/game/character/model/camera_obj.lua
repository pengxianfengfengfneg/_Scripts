local CameraObj = Class(require("game/character/model/draw_obj"))

local model_type_camera = game.ModelType.Camera

local _model_type = game.ModelType
local _game_pool = game.GamePool

function CameraObj:Init()
	CameraObj.super.Init(self, game.BodyType.Camera)
end

function CameraObj:CreateModel(model_type)
	local model = self.model_list[model_type]
	if model then
		return model
	end

	model = _game_pool.ModelBasePool:Create()
	model:Init(self, model_type, self.body_type)
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

function CameraObj:DelModel()
	CameraObj.super.DelModel(self, model_type_camera)
end

function CameraObj:GetModel()
	return self.model_list[model_type_camera]
end

function CameraObj:GetModelTransform()
	local model = self:GetModel()
	if model then
		return model:GetModelTransform()
	end
end

function CameraObj:SetModelID(id)
	CameraObj.super.SetModelID(self, model_type_camera, id)
end

function CameraObj:PlayAnim(name, speed, fade_time, is_force)
	local model = self:GetModel()
	if model then
		model:PlayAnim(name, speed, fade_time, is_force)
	end
end

function CameraObj:PlayLayerAnim(name, speed, fade_time, is_force)
	local model = self:GetModel()
	if model then
		model:PlayAnim(name, speed, fade_time, is_force)
	end
end

function CameraObj:SetAnimSpeed(anim_speed)
	local model = self:GetModel()
	if model then
		model:SetAnimSpeed(anim_speed)
	end
end

function CameraObj:GetAnimTime(name)
	local model = self:GetModel()
	if model then
		return model:GetAnimTime(name)
	end
	return 0
end

function CameraObj:AddToModel(model_node, node)
	local model = self:GetModel()
	if model then
		return model:AddChild(model_node, node)
	end
end

function CameraObj:GetModelNode(name)
	local model = self:GetModel()
	if model then
		return model:GetChild(name)
	end
end

function CameraObj:SetModelEnable(model_type, val)
	local model = self:GetModel()
	if model then
		model:SetEnable(val)
	end
end

function CameraObj:SetModelVisible(model_type, val)
	local model = self:GetModel()
	if model then
		model:SetVisible(val)
	end
end

function CameraObj:SetLayer(layer_name)
	local model = self:GetModel()
	if model then
		model:SetLayer(layer_name)
	end
end

function CameraObj:SetAlwaysAnim(val)
	local model = self:GetModel()
	if model then
		model:SetAlwaysAnim(val)
	end
end

function CameraObj:SetMatEffect(eff_name, enable)
	local model = self:GetModel()
	if model then
		model:SetMatEffect(eff_name, enable)
	end
end

return CameraObj
