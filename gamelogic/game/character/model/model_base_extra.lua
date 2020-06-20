-- 模型挂件基类
-- 需要重写id定位资源路径函数

local ModelBase = Class()

local _model_node_name = game.ModelNodeName
local _model_type = game.ModelType
local _body_type = game.BodyType

local _body_res_path = {
	[game.BodyType.Role] = "model/role/%d.ab",
	[game.BodyType.Monster] = "model/monster/%d.ab",
	[game.BodyType.Mount] = "model/mount/%d.ab",
	[game.BodyType.Wing] = "model/chibang/%d.ab",
	[game.BodyType.Npc] = "model/monster/%d.ab",
	[game.BodyType.Gather] = "model/monster/%d.ab",
	[game.BodyType.RoleCreate] = "model/role_create/%d.ab",
	[game.BodyType.Carry] = "model/monster/%d.ab",
	[game.BodyType.ModelSp] = "model/model_sp/%d.ab",
	[game.BodyType.Camera] = "model/camera/%d.ab",
	[game.BodyType.WingUI] = "model/zuoqi/%d.ab",
}

local _anim_path_map = {
	[game.BodyType.Role] = "anim/role/%d.ab",
	[game.BodyType.Monster] = "model/monster/%d.ab",
	[game.BodyType.Hair] = "model/hair/%d.ab",
	[game.BodyType.Wing] = "model/chibang/%d.ab",
	[game.BodyType.Mount] = "model/zuoqi/%d.ab",
	[game.BodyType.Npc] = "model/monster/%d.ab",
	[game.BodyType.WeaponUI] = "model/weapon_ui/%d.ab",
	[game.BodyType.Gather] = "model/monster/%d.ab",
	[game.BodyType.Camera] = "model/camera/%d.ab",
	[game.BodyType.RoleCreate] = "model/role_create/%d.ab",
	[game.BodyType.WingUI] = "model/zuoqi/%d.ab",
}

local _model_res_config = {
	[_model_type.Body] = {
		GetResPath = function(body_type, id)
			return string.format(_body_res_path[body_type], id)
		end,
		GetHangNode = function(body_type)
			return nil
		end},
	[_model_type.Mount] = {
		GetResPath = function(body_type, id)
			return string.format("model/zuoqi/%d.ab", id)
		end,
		GetHangNode = function(body_type)
			return nil
		end,
		ShowFunc = function(draw_obj, model, enable)
			local body_model = draw_obj.model_list[_model_type.Body]
			if body_model then
				if enable then
					model:AddChild(_model_node_name.Mount, body_model._root_obj.tran)
				else
					body_model:SetParent(draw_obj.root_obj.tran)
				end
			end
		end
	},
	[_model_type.Wing] = {
		GetResPath = function(body_type, id)
			return string.format("model/zuoqi/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return _model_node_name.Back
		end,
	},
	[_model_type.WingUI] = {
		GetResPath = function(body_type, id)
			return string.format("model/zuoqi/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
    },
	[_model_type.Hair] = {
		GetResPath = function(body_type, id)
			return string.format("model/hair/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return _model_node_name.Head
		end,
    },
	[_model_type.HairCreate] = {
		GetResPath = function(body_type, id)
			return string.format("model/hair/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
	},
	[_model_type.Weapon] = {
		GetResPath = function(body_type, id)
			return string.format("model/weapon/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return _model_node_name.RightHand
		end,
    },
	[_model_type.Weapon2] = {
		GetResPath = function(body_type, id)
			return string.format("model/weapon/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return _model_node_name.LeftHand
		end,
    },
	[_model_type.WeaponUI] = {
		GetResPath = function(body_type, id)
			return string.format("model/weapon_ui/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
	},
	[_model_type.WeaponCreate] = {
		GetResPath = function(body_type, id)
			return string.format("model/weapon_create/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return _model_node_name.RightHand
		end,
	},
	[_model_type.WeaponCreate2] = {
		GetResPath = function(body_type, id)
			return string.format("model/weapon_create/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return _model_node_name.LeftHand
		end,
	},
	[_model_type.Camera] = {
		GetResPath = function(body_type, id)
			return string.format("model/camera/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
	},
	[_model_type.AnQi] = {
		GetResPath = function(body_type, id)
			return string.format("model/anqi/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
	},
	[_model_type.WuHunUI] = {
		GetResPath = function(body_type, id)
			return string.format("model/wuhun/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
	},
	[_model_type.WeaponSoul] = {
		GetResPath = function(body_type, id)
			return string.format("model/wuhun/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
		GetNewPos = function()
			return {x=-0.67, y=1.43, z =0.19}
		end,
	},
	[_model_type.DragonDesign] = {
		GetResPath = function(body_type, id)
			return string.format("model/longwen/%d.ab", id)
		end,
		GetHangNode = function(body_type, career)
			return nil
		end,
	},
}

function ModelBase:GetModelPath(id)
	return _model_res_config[self._model_type].GetResPath(self._body_type, id)
end

function ModelBase:GetHangNode()
	if not _model_res_config[self._model_type] then
		print("_model_res_config[self._model_type] XXXX", self._model_type)
	end
	return _model_res_config[self._model_type].GetHangNode(self._body_type)
end

function ModelBase:GetNewPos()
	return _model_res_config[self._model_type].GetNewPos
end

function ModelBase:GetBoneID(id)
	if self._body_type == _body_type.Role then
		return string.sub(id, 1, 4)
	else
		return id
	end
end

function ModelBase:SetShow(enable)
	if _model_res_config[self._model_type].ShowFunc then
		_model_res_config[self._model_type].ShowFunc(self._draw_obj, self, enable)
	end
end

return ModelBase
