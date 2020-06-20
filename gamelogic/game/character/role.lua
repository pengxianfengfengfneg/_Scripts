
local Role = Class(require("game/character/character"))

local _game_net = game.GameNet
local _model_type = game.ModelType
local _obj_anim_name = game.ObjAnimName
local _obj_state = game.ObjState
local _exterior_type = game.ExteriorType
local _config_hair_style = config.hair_style
local _config_exterior_mount = config.exterior_mount
local _config_mount_effect = config.mount_effect
local _cfg_honor = config.title_honor
local _config_help_model = config_help.ConfigHelpModel
local _string_format = string.format
local _config_transform = config.transform
local _role_size = game.RoleSizeCfg
local _fight_ctrl = game.FightCtrl

function Role:_init()
	Role.instance = self

	self.obj_type = game.ObjType.Role
    self.update_cd = 0.3 + math.random(10) * 0.03

    self.aoi_mask = game.AoiMask.Role
	self.aoi_range = 30 

	self.mount_type = 0
end

function Role:_delete()
	Role.instance = nil
end

function Role:Init(scene, vo)
	Role.super.Init(self, scene, vo)

	self.vo = vo
	self.uniq_id = vo.role_id
	self:SetLogicPos(vo.x, vo.y)


	self:CreateDrawObj()

	self:ShowShadow(true)

	self:RegisterAoiObj(self.aoi_mask)
	self:InitBuffList()
	self:RefreshMurderous()

	local sk_list = scene:GetSkillList(vo.role_id)
	if sk_list then
		self:InitSkillInfo(sk_list.skill_list, sk_list.skill_cd)
	end
	
	self.is_client_obj = (self.uniq_id <= 10000 and self.vo.owner_id == scene:GetMainRoleID())
	self:SetHonor(vo.title_honor)

	self._team_flag = nil
	local team_flag = game.MakeTeamCtrl.instance:GetTeamMemberFlag(self:GetUniqueId())
	if team_flag then
		self:SetTeamFlag(team_flag)
	end
end

function Role:Reset()
	if self.scene then
		self.scene:FreeRoleShowNum()
	end
	self.mount_state = nil
	self.wing_state = nil

	self:SetCalcMapHeightFunc(nil)

	if self.weapon_soul and self.scene then
		self.scene:ReleaseObj(self.weapon_soul)
		self.weapon_soul = nil
	end

	self:ResetTransform()

	Role.super.Reset(self)
end

function Role:IsClientObj()
	return self.is_client_obj
end

function Role:RefreshName()
	self:SetHudText(game.HudItem.Name, self.vo.name)
end

function Role:RefreshNameColor()
	local main_role = self.scene:GetMainRole()
	if main_role then
		if main_role:IsRivalYunBiao(self) then
			if main_role:IsFightState() then
				self:SetHudTextColor(game.HudItem.Name, 2)
			else
				self:SetHudTextColor(game.HudItem.Name, 8)
			end
		elseif main_role:IsEnemy(self) then
			self:SetHudTextColor(game.HudItem.Name, 2)
		else
			self:SetHudTextColor(game.HudItem.Name, 4)
		end
	else
		self:SetHudTextColor(game.HudItem.Name, 4)
	end
	self:RefreshPetNameColor()
end

local _refresh_pet_name_func = function(obj, role_id)
	if obj.obj_type == game.ObjType.Pet then
		if obj:GetOwnerID() == role_id then
			obj:RefreshNameColor()
		end
	end
end
function Role:RefreshPetNameColor()
	self.scene:ForeachObjs(_refresh_pet_name_func, self.uniq_id)
end

function Role:RefreshGuildName()
	if self.vo.guild_name ~= "" then
		self:SetHudText(game.HudItem.GuildName, self.vo.guild_name, 4)
	else
		self:SetHudItemVisible(game.HudItem.GuildName, false)
	end
end

function Role:SetGuild(id, guild_name)
	self.vo.guild = id
	self.vo.guild_name = guild_name
	self:RefreshGuildName()
	self:RefreshNameColor()
end

function Role:GetGuildID()
	return self.vo.guild
end

-- state
function Role:DoRevive()
	self:RegisterAoiObj(self.aoi_mask)
	Role.super.DoRevive(self)
end

-- attr
function Role:GetServerType()
    return 2
end

-- anim
function Role:SetMountState(mode, server_change)
	if not self:HasMount() and mode == 1 then
		return
	end

	if mode == self.mount_state then
		return
	end

	self.mount_state = mode
	self.draw_obj:SetModelEnable(_model_type.Mount, self.mount_state == 1)
	self.draw_obj:SetModelEnable(_model_type.Wing, self.mount_state == 1)
	self:PlayStateAnim()
	self:ResetHudPos()

	if not server_change and self:IsMainRole() then
		self:SendMountState(self.mount_state == 0)
	end
	return true
end

function Role:GetMountState()
	return self.mount_state
end

function Role:CanRideMount(mode, notice)
	if mode == 1 then
		if not game.RoleCtrl.instance:CanTransformChangeScene(self, notice) then
			return false
		end

		if not self:HasMount() then
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[505])
			end
			return false
		end

		local state_id = self:GetCurStateID()
		if state_id ~= _obj_state.Idle 
			and state_id ~= _obj_state.Move then
			return false
		end
	end

	return true
end

function Role:HasMount()
	return self.mount_type > 0
end

function Role:GetModelHeight()
	local fashion_id = self:_GetModelID(_model_type.Body)
	if fashion_id and _role_size[fashion_id] then
		self.model_height = _role_size[fashion_id][2] + 0.3
	end
	if self.mount_state == 1 then
		local mount_id = self:GetExteriorID(game.ExteriorType.Mount)
		if mount_id and _config_exterior_mount[mount_id] then
			return self.model_height + _config_exterior_mount[mount_id].height
		else
			return self.model_height
		end
    else
    	return self.model_height
    end
end

local _anim_fade_time = config.custom.default_anim_fade_time
local _anim_default_layer = _model_type.Body + _model_type.Hair
local _anim_layer_map = {
	[_obj_anim_name.RideIdle] = _model_type.Body + _model_type.Hair + _model_type.Wing + _model_type.Mount,
	[_obj_anim_name.RideRun] = _model_type.Body + _model_type.Hair + _model_type.Wing + _model_type.Mount,
}
local _anim_name_map = {
	[_obj_anim_name.RideIdle] = function(id)
		return _config_help_model.GetMountIdleAnimName(id)
	end,
	[_obj_anim_name.RideRun] = function(id)
		return _config_help_model.GetMountRunAnimName(id)
	end,
}
function Role:PlayAnim(name, speed, fade_time)
	local layer = _anim_layer_map[name]
	if _anim_name_map[name] then
		name = _anim_name_map[name](self.mount_anim)
	end
	self.draw_obj:PlayLayerAnim(layer or _anim_default_layer, name, speed or 1.0, fade_time or _anim_fade_time)
end

function Role:PlayStateAnim()
	if self.mount_state == 1 then
		local id = self:GetCurStateID()
		if id == _obj_state.Idle then
			self:PlayAnim(_obj_anim_name.RideIdle)
			return
		elseif id == _obj_state.Move then
			self:PlayAnim(_obj_anim_name.RideRun)
			return
		end
	end
	Role.super.PlayStateAnim(self)
end

-- 外观形象相关
function Role:CreateDrawObj()
	self.mount_type = 0
	self.mount_anim = 0
	self.model_show_mask = 0

	if self.vo.tran_stat == 0 then
		self:CreateRoleDrawObj()
	else
		self:Transform()
	end

	self:RefreshName()
	self:RefreshNameColor()
	self:RefreshGuildName()
	self.draw_obj:SetModelChangeCallBack(function(model_type)
		self:OnModelChangeCallBack(model_type)
	end)

	if self.obj_type == game.ObjType.Role then
	    self:SetClickCallBack(function()
	        local main_role = game.Scene.instance:GetMainRole()
	        if main_role then
	            main_role:SelectTarget(self)
	            main_role:GetOperateMgr():DoAttackTarget(self.obj_id, false)
	        end
	    end, 1)
	end
end

function Role:CreateRoleDrawObj()
	if self.draw_obj then
		game.GamePool.DrawObjPool:Free(self.draw_obj)
		self.draw_obj = nil
	end
	self.mount_state = nil
	self.wing_state = nil

	self.draw_obj = game.GamePool.DrawObjPool:Create()
	self.draw_obj:Init(game.BodyType.Role)
	self.draw_obj:SetParent(self.root_obj.tran)

	for k, v in pairs(game.ModelType) do
		self.model_show_mask = self.model_show_mask | v
	end
	self:RefreshShow()
	self.draw_obj:SetModelChangeCallBack(function(model_type)
		self:OnModelChangeCallBack(model_type)
	end)
end

function Role:OnModelChangeCallBack(model_type)
	if model_type == _model_type.Hair then
		self:RefreshHairColor()
	end
end

local _model_id_config = {
	[_model_type.Mount] = function(vo)
		for i, v in ipairs(vo.exteriors) do
			if v.type == _exterior_type.Mount then
				local model_id, param = _config_help_model.GetMountID(v.id)
				return model_id, param, v.stat == 1
			end
		end
		return 0
	end,
	[_model_type.Wing] = function(vo)
		for i, v in ipairs(vo.exteriors) do
			if v.type == _exterior_type.Mount then
				local model_id, param = _config_help_model.GetWingID(v.id)
				return model_id, param, v.stat == 1
			end
		end
		return 0
	end,
	[_model_type.Body] = function(vo)
		return _config_help_model.GetBodyID(vo.career, vo.fashion, vo.gender), nil, true
	end,
	[_model_type.Hair] = function(vo)
		return _config_help_model.GetHairID(vo.career, vo.hair), nil, true
	end,
	[_model_type.Weapon] = function(vo)
		local model_id, param = _config_help_model.GetWeaponID(vo.career, vo.artifact)
		return model_id, param, true
	end,
	[_model_type.Weapon2] = function(vo)
		local model_id, is_two = _config_help_model.GetWeaponID(vo.career, vo.artifact)
		if is_two and model_id < 4008 then
			return model_id, is_two, true
		else
			return 0
		end
	end,
	[_model_type.WeaponSoul] = function(vo)
		return vo.warrior_soul
	end,
}

local _exterior_type_config = {
	[_exterior_type.Mount] = function(role)
		role:RefreshMount()
	end,
}

function Role:_GetModelID(model_type)
	if _model_id_config[model_type] then
		local id, param, visible = _model_id_config[model_type](self.vo)
		if id then
			visible = visible and (self.model_show_mask & model_type) ~= 0
			return id, param, visible
		end
	end
	return 0, nil, false
end

function Role:GetModelID(model_type)
	return self:_GetModelID(model_type)
end

function Role:SetExteriorType(type, id, stat)

	local has_found = false
	for i, v in ipairs(self.vo.exteriors) do
		if v.type == type then
			v.id = id
			v.stat = stat
			has_found = true
			break
		end
	end
	if not has_found then
		table.insert(self.vo.exteriors, {type = type, id = id, stat = stat})
	end
	local func = _exterior_type_config[type]
	if func then
		func(self)
	end
end

function Role:GetExteriorID(type)
	local ext = self.vo.exteriors[type]
	if ext then
		return ext.id
	end
end

function Role:GetFashion()
	return self.vo.fashion
end

function Role:SetFashionID(id)
	self.vo.fashion = id
	self:RefreshFashion()
end

function Role:SetWeaponID(id)
	self.vo.artifact = id
	self:RefreshWeapon()
end

function Role:RefreshShow()
	self:RefreshMount()
	self:RefreshWeapon()
	self:RefreshHair()
	self:RefreshFashion()
	self:RefreshWeaponSoul()
	self:RefreshTitle()

	self:SetModelVisible(self:IsSettingVisible())
end

function Role:IsSettingVisible()
	local mask_value = game.SysSettingKey.MaskPlayer

	local main_role = self.scene:GetMainRole()
	if main_role then
		if not main_role:IsEnemy(self) then
			mask_value = mask_value + game.SysSettingKey.MaskFriend
		end
	end

	return (not game.SysSettingCtrl.instance:IsSettingActived(mask_value))
end

function Role:RefreshMount()

	self.mount_type = 0
	self.mount_anim = 0
	local mount_model_id, mount_anim, mount_visible = self:_GetModelID(_model_type.Mount)

	if self.marry_cruise_mount then
		mount_model_id = self.marry_cruise_mount
		mount_anim = 0
		mount_visible = mount_visible
	end

	local wing_model_id, wing_anim, wing_visible = self:_GetModelID(_model_type.Wing)
	if mount_model_id == 0 then
		self.draw_obj:DelModel(_model_type.Mount)
	else
		self.mount_type = 1
		self.mount_anim = mount_anim
		self.draw_obj:SetModelID(_model_type.Mount, mount_model_id)
	end

	if wing_model_id == 0 then
		self.draw_obj:DelModel(_model_type.Wing)
	else
		self.mount_type = 2
		self.mount_anim = wing_anim
		self.draw_obj:SetModelID(_model_type.Wing, wing_model_id)
	end

	local is_ride = self.mount_type > 0 and (mount_visible or wing_visible)
	if is_ride then
		self:SetMountState(1, true)
	else
		self:SetMountState(0, true)
	end

	self.draw_obj:FreeEffect(game.ModelType.Mount)
	self.draw_obj:FreeEffect(game.ModelType.Wing)
	if is_ride then
		local mount_id = self:GetExteriorID(game.ExteriorType.Mount)
		local model_type = _config_exterior_mount[mount_id].is_wing == 0 and game.ModelType.Mount or game.ModelType.Wing

		local effect_cfg = _config_mount_effect[mount_id]	
		local effect_list = effect_cfg and effect_cfg[1]
		
		for k, v in pairs(effect_list or game.EmptyTable) do
			self.draw_obj:SetEffectID(v.hang_node, v.effect, model_type, false)
		end
	end

	if self:IsMainRole() then
		global.EventMgr:Fire(game.RoleEvent.RefreshMount)	
	end
end

function Role:RefreshWeapon()
	local model_id, double, visible = self:_GetModelID(_model_type.Weapon)
	if model_id == 0 or not visible then
		self.draw_obj:DelModel(_model_type.Weapon)
		self.draw_obj:DelModel(_model_type.Weapon2)
	else
		self.draw_obj:SetModelID(_model_type.Weapon, model_id)
		if double and model_id < 4008 then
			self.draw_obj:SetModelID(_model_type.Weapon2, model_id)
		else
			self.draw_obj:DelModel(_model_type.Weapon2)
		end
	end
end

function Role:RefreshHair()
	local model_id, _, visible = self:_GetModelID(_model_type.Hair)
	if model_id == 0 or not visible then
		self.draw_obj:DelModel(_model_type.Hair)
	else
		self.draw_obj:SetModelID(_model_type.Hair, model_id)
	end
end

function Role:RefreshFashion()
	local model_id = self:_GetModelID(_model_type.Body)
	if self.draw_obj:GetBodyType() == game.BodyType.Role then
		self.draw_obj:SetModelID(_model_type.Body, model_id)
	end
end

function Role:RefreshWeaponSoul()
	if self.vo.warrior_soul > 0 then
		self.weapon_soul = game.Scene.instance:CreateWeaponSoul({model_id=self.vo.warrior_soul, owner=self})
		if self.weapon_soul and self.scene then
			self.scene:ReleaseObj(self.weapon_soul)
			self.weapon_soul = nil
			self.weapon_soul = game.WeaponSoulCtrl.instance:CsWarriorSoulChangeAvatar(0)
		end
		self.weapon_soul = game.WeaponSoulCtrl.instance:CsWarriorSoulChangeAvatar(self.vo.warrior_soul)
		self:RefreshWeaponSoul2()
	else
		if self.weapon_soul and self.scene then
			self.scene:ReleaseObj(self.weapon_soul)
			self.weapon_soul = nil
		end
	end
end

function Role:RefreshWeaponSoul2()
	if self.vo.warrior_soul > 0 then
		if self.weapon_soul and self.scene then
			self.scene:ReleaseObj(self.weapon_soul)
			self.weapon_soul = nil
		end
		self.weapon_soul = game.Scene.instance:CreateWeaponSoul({model_id=self.vo.warrior_soul, owner=self})
	else
		if self.weapon_soul and self.scene then
			self.scene:ReleaseObj(self.weapon_soul)
			self.weapon_soul = nil
		end
	end
end

function Role:SetWeaponSoulID(id)
	self.vo.warrior_soul = id
	self:RefreshWeaponSoul2()
end

-- proto
local attack_proto = {}
function Role:SendAttackReq(skill_id, obj, assist_x, assist_y)
	attack_proto.role_id = self.uniq_id
	attack_proto.skill_id = skill_id
	if obj and obj.uniq_id then
		attack_proto.defer_type = obj:GetServerType()
        attack_proto.defer_id = obj.uniq_id

		attack_proto.assist_x = obj.logic_pos.x
		attack_proto.assist_y = obj.logic_pos.y
	else
		attack_proto.defer_type = 0
        attack_proto.defer_id = 0

		local dir_x, dir_y = cc.pNormalizeV(self.dir.x, self.dir.y)
		attack_proto.assist_x = self.logic_pos.x + dir_x * 10
		attack_proto.assist_y = self.logic_pos.y + dir_y * 10
	end
    if assist_x then
        attack_proto.assist_x = assist_x
        attack_proto.assist_y = assist_y
    end

	attack_proto.assist_x = math.floor(attack_proto.assist_x)
	attack_proto.assist_y = math.floor(attack_proto.assist_y)
	_game_net:SendProtocal(90300, attack_proto)
end

local walk_proto = {}
function Role:SendWalkReq(x, y, move)
	walk_proto.role_id = self.uniq_id
	walk_proto.scene_id = self.scene:GetSceneID()
	walk_proto.cx, walk_proto.cy = self:GetLogicPosXY()
	walk_proto.x, walk_proto.y = x, y
	walk_proto.move = move
	walk_proto.reset_index = self.reset_index
	_game_net:SendProtocal(90200, walk_proto)
end

local jump_proto = {}
function Role:SendJumpReq(x, y, fx, fy)
	local fx = fx
	if not fx then
		fx,fy = self:GetLogicPosXY()
	end
	jump_proto.role_id = self.uniq_id
	jump_proto.scene_id = self.scene:GetSceneID()
	jump_proto.cx, jump_proto.cy = fx, fy
	jump_proto.x, jump_proto.y = x, y
	jump_proto.move = 1
	jump_proto.reset_index = self.reset_index
	_game_net:SendProtocal(90200, jump_proto)
end

-- proto
local pre_skill_proto = {
	skill_id = 1,
	op = 1,
}
function Role:SendPreSkillReq(skill_id, obj, assist_x, assist_y, op)
	pre_skill_proto.role_id = self.uniq_id
	pre_skill_proto.skill_id = skill_id
	if obj and obj.uniq_id then
		pre_skill_proto.defer_type = obj:GetServerType()
        pre_skill_proto.defer_id = obj.uniq_id

		pre_skill_proto.assist_x = obj.logic_pos.x
		pre_skill_proto.assist_y = obj.logic_pos.y
	else
		pre_skill_proto.defer_type = 0
        pre_skill_proto.defer_id = 0

		local dir_x, dir_y = cc.pNormalizeV(self.dir.x, self.dir.y)
		pre_skill_proto.assist_x = self.logic_pos.x + dir_x * 10
		pre_skill_proto.assist_y = self.logic_pos.y + dir_y * 10
	end
    if assist_x then
        pre_skill_proto.assist_x = assist_x
        pre_skill_proto.assist_y = assist_y
    end

	pre_skill_proto.assist_x = math.floor(pre_skill_proto.assist_x)
	pre_skill_proto.assist_y = math.floor(pre_skill_proto.assist_y)
	pre_skill_proto.op = op
	_game_net:SendProtocal(90303, pre_skill_proto)
end

function Role:GetCareer()
	return self.vo.career
end

function Role:GetHair()
	return self.vo.hair
end

function Role:SetHair(hair)
	self.vo.hair = hair

	self:RefreshHair()
	self:RefreshHairColor()
end

function Role:GetIconID()
    return self.vo.icon
end

function Role:SetIconID(id)
	self.vo.icon = id
end

local TitleChangeConfig = {
	ToTitleFunc = {
		[3001] = function(role_id, pre_title, title)
			self:RefreshNameColor()
		end
	},
	FromTitleFunc = {	
		[3001] = function(role_id, pre_title, title)
			self:RefreshNameColor()
		end
	}
}
function Role:SetTitle(title_id)
	local pre_title = self.vo.title

	self.vo.title = title_id
	self:RefreshTitle()

	local to_func = TitleChangeConfig.ToTitleFunc[title_id]
	if to_func then
		to_func(self, pre_title, title_id)
	end

	local from_func = TitleChangeConfig.FromTitleFunc[title_id]
	if from_func then
		from_func(self, pre_title, title_id)
	end
end

function Role:GetTitleID()
	return self.vo.title
end

function Role:SetTmpTitle(header)
	self.vo.header = header
	self:RefreshTitle()
end

function Role:RefreshHairColor()
	local r,g,b = _config_help_model.GetHairColor(self.vo.hair)
	self:UpdateHairColor(r, g, b)
end

local property = game.MaterialProperty.Color
function Role:UpdateHairColor(r, g, b)
    self.draw_obj:SetMatPropertyColor(property, r/255, g/255, b/255, 1, game.ModelType.Hair)
end

function Role:GetPkMode()
	return game.PkMode.Peace
end

function Role:SetTeam(id)
	self.vo.team = id
	self:RefreshNameColor()
end

function Role:GetTeamID()
	return self.vo.team
end

function Role:GetMateName()
	return self.vo.mate_name
end

function Role:SetMateInfo(mate_id, mate_name)
	self.vo.mate_id = mate_id
	self.vo.mate_name = mate_name
end

local _title_show_func_config = {
	[1] = {
		title_func = function(role, param, header)
			return param[2]
		end,
	},
	[2] = {
		title_func = function(role, param, header)
			return _string_format(param[2], header & 0xffff)
		end,
	},
	[3] = {
		title_func = function(role, param, header)
			local title_extra = role:GetTitleExtra()
			return param[2] and _string_format(param[2], title_extra) or title_extra
		end,
		quality_func = function(role, param, header)
			local quality = role:GetTitleQuality()
		end,
	},
	[4] = {
		title_func = function(role, param, header)
			local gender = role:GetGender()
			local format_list = {config.words[2627], config.words[2628]}
			return _string_format(format_list[gender], role:GetMateName())
		end,
	},
}

function Role:RefreshTitle()
	local title_id = self.vo.title
	local has_tmp_title = false
	if self.vo.header > 0 then
		title_id = self.vo.header >> 32
		has_tmp_title = true
	end

	local item_list = {game.HudItem.TitleTxt, game.HudItem.Title2}

	local is_visible = title_id > 0 and (has_tmp_title or self:IsSettingTitleVisible())
	if not is_visible then
		for _, v in ipairs(item_list) do
			self:SetHudItemVisible(v, is_visible)
		end
	else
		local item_type = nil
		local cfg = config.title[title_id]

		if not cfg then
			return
		end

		local title = nil
		local quality = nil
		if #cfg.show_param > 0 then
			local show_type = cfg.show_param[1]
			local show_cfg = _title_show_func_config[show_type]
			if show_cfg.title_func then
				title = show_cfg.title_func(self, cfg.show_param, self.vo.header)
			end
			if show_cfg.quality_func then
				quality = show_cfg.quality_func(self, cfg.show_param, self.vo.header)
			end
		end
		title = title or cfg.name
		if not quality or quality == 0 then
			quality = cfg.quality
		end

		if (cfg.source_id ~= "") or (cfg.source_id2 ~= "") then
			self:SetHudText(game.HudItem.Title2Txt, title, game.ItemColorToHudIndex[quality])
			self:SetHudImg(game.HudItem.Title2PrefixImg, cfg.source_id, 1, cfg.is_flip_x[1] == 1)
			self:SetHudImg(game.HudItem.Title2SuffixImg, cfg.source_id2, 1, cfg.is_flip_x[2] == 1)
			self:SetHudItemVisible(game.HudItem.Title2, true)
			item_type = game.HudItem.Title2
		else
			self:SetHudText(game.HudItem.TitleTxt, title, game.ItemColorToHudIndex[quality])
			item_type = game.HudItem.TitleTxt
		end

		for _, v in ipairs(item_list) do
			if item_type ~= v then
				self:SetHudItemVisible(v, false)
			end
		end
	end
end

function Role:IsSettingTitleVisible()
	return not game.SysSettingCtrl.instance:IsSettingActived(game.SysSettingKey.MaskPlayerTitle)
end

function Role:IsSettingEffectVisible()
	return not game.SysSettingCtrl.instance:IsSettingActived(game.SysSettingKey.MaskPlayerEffect)
end

function Role:GetMurderous()
	return self.vo.murderous
end

function Role:ChangeMurderous(val)
	self.vo.murderous = val
	self:RefreshMurderous()
end

function Role:RefreshMurderous()
	local val = self.vo.murderous
	if val > 0 then
		if val > 3 then
			val = 7
		end
		self:SetHudImg(game.HudItem.Murder, tostring(val))
	elseif val < 0 then
		if val < -3 then
			val = -3
		end
		self:SetHudImg(game.HudItem.Murder, tostring(3 - val))
	else
		self:SetHudItemVisible(game.HudItem.Murder, false)
	end
end

function Role:SetHonor(honor_id)
	if _cfg_honor[honor_id] then
		self:SetHudImg(game.HudItem.TouXian, _cfg_honor[honor_id].icon, _cfg_honor[honor_id].scale)
	end
end

function Role:CalcMapHeight()
	if self.calc_map_height_func then
		return self.calc_map_height_func()
	end
	return Role.super.CalcMapHeight(self)
end

function Role:SetCalcMapHeightFunc(func)
	self.calc_map_height_func = func
end

function Role:IsYunBiao()
	local title_id = 0
	if self.vo.header > 0 then
		title_id = self.vo.header >> 32
	end
	return title_id == 3001
end

function Role:GetTitleExtra()
	return self.vo.title_extra
end

function Role:GetTitleQuality()
	return self.vo.title_quality
end

function Role:SetTitleInfo(title, quality)
	self.vo.title_extra = title
	self.vo.title_quality = quality
end

local _tran_config = {
	[2] = {
		start_func = function(self, tran_cfg)
			self.alchemy_gharry = game.Scene.instance:CreateFollowObj({model_id = tran_cfg.params[1], offset = 5, owner = self})
		end,
		stop_func = function(self, tran_cfg)
			if self.alchemy_gharry and self.scene then
				self.scene:DeleteObj(self.alchemy_gharry.obj_id)
				self.alchemy_gharry = nil
			end
		end,
	}
}
function Role:SetTranStat(stat)
	if self:GetTranStat() == stat then
		return
	end

	self:ResetTransform()
	self.vo.tran_stat = stat

	if stat > 0 then
		self:Transform()
	else
		self:CreateRoleDrawObj()
	end
end

function Role:GetTranStat()
	if self.vo then
		return self.vo.tran_stat
	end
	return 0
end

function Role:Transform()
	local id = self.vo.tran_stat
	if not _config_transform[id] then
		return
	end

	local model_id = _config_transform[id].model_id

	self.model_show_mask = game.ModelType.Body

	if _config_transform[id].can_ride == 0 and self:GetMountState() == 1 then
		self:SetMountState(0)
	end

	if self.draw_obj then
		game.GamePool.DrawObjPool:Free(self.draw_obj)
		self.draw_obj = nil
	end
	self.mount_state = nil
	self.wing_state = nil

	if _config_transform[id].body_type == 1 then
		self.draw_obj = game.GamePool.DrawObjPool:Create()
		self.draw_obj:Init(game.BodyType.Monster)
		self.draw_obj:SetParent(self.root_obj.tran)
		
		self.draw_obj:SetModelID(_model_type.Body, model_id)
		self:RefreshShow()
	end

	if _tran_config[id] then
		_tran_config[id].start_func(self, _config_transform[id])
	end
end

function Role:ResetTransform()
	local id = self:GetTranStat()
	if id and _tran_config[id] then
		_tran_config[id].stop_func(self, _config_transform[id])
	end
end

function Role:CanDoAttack(skill_id, notice)
	local tran_stat = self:GetTranStat()
	if tran_stat > 0 then
		if _config_transform[tran_stat].can_attack == 0 then
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[5526])
				return false
			end
		end
	end
	return Role.super.CanDoAttack(self, skill_id, notice)
end

function Role:CanPlayAction(notice)
	local tran_stat = self:GetTranStat()
	if tran_stat > 0 then
		if _config_transform[tran_stat].can_play_action == 0 then
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[5526])
				return false
			end
		end
	end
	return true
end

function Role:GetGender()
	return self.vo.gender
end

function Role:GetStateParams()
	return self.vo.state_params
end

function Role:GetLevel()
	return self.vo.level
end

function Role:PlayBlood(num, harm_type)
	if self:CanPlayBlood() then
		if self.immune_harm > 0 then
			if harm_type == 0 or harm_type == 3 then
				if self:GetHp() < self:GetMaxHp() * 0.1 then
					_fight_ctrl.instance:PlayBlood(self, num, 7)
					return
				end
			end
		end
		_fight_ctrl.instance:PlayBlood(self, num, harm_type)
	end
end

--夫妻巡游移动
function Role:DoCruisMove(x,y)

	self:GetOperateMgr():SetPause(true)

	--新郎
	if self:GetGender() == game.Gender.Male then
		local ux, uy = game.LogicToUnitPos(x+5, y+5)
		self:DoMove(ux, uy)
	--新娘
	else
		self:DoSeatMove(x,y)
		self:SetHeight(1.2)
	end
end

function Role:SetCruiseMount(val)
	self.marry_cruise_mount = val
end

function Role:SetTeamFlag(flag)
	if self._team_flag == flag then
		return
	end
	self._team_flag = flag

	if self._team_flag == 1 then
		self:SetHudImg(game.HudItem.TeamImg, "zd_15", 0.8)
		self:SetHudItemVisible(game.HudItem.TeamFollowImg, false)
		return
	end

	if self._team_flag == 2 then
		self:SetHudImg(game.HudItem.TeamImg, "zd_19")
		self:SetHudItemVisible(game.HudItem.TeamFollowImg, false)
		return
	end

	if self._team_flag == 3 then
		self:SetHudImg(game.HudItem.TeamImg, "zd_19")
		self:SetHudImg(game.HudItem.TeamFollowImg, "zd_18")
		return
	end

	self:SetHudItemVisible(game.HudItem.TeamImg, false)
	self:SetHudItemVisible(game.HudItem.TeamFollowImg, false)
end

function Role:IsRole()
	return true
end

function Role:GetMoveState()
	if self.mount_state == 1 then
		local mount_id = self:GetExteriorID(game.ExteriorType.Mount)
		if mount_id and _config_exterior_mount[mount_id] then
			return _config_exterior_mount[mount_id].is_wing
		else
			return 2
		end
	else
		return 2
	end
end

game.Role = Role
return Role
