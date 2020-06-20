
local Pet = Class(require("game/character/character"))
local _obj_anim_name = game.ObjAnimName
local _model_type = game.ModelType
local _game_net = game.GameNet
local _event_mgr = global.EventMgr
local _obj_state = game.ObjState
local _fight_ctrl = game.FightCtrl
local _monster_size = game.MonsterSizeCfg

function Pet:_init()
    self.obj_type = game.ObjType.Pet
    self.update_cd = 0.5 + math.random(10) * 0.03

	self.aoi_range = 30
end

function Pet:_delete()

end

function Pet:Init(scene, vo)
    Pet.super.Init(self, scene, vo)

    self.vo = vo
    self.uniq_id = vo.id
    self.reset_index = 0
	self.pet_cfg = config.pet[self.vo.pet_cid]

    self:SetLogicPos(vo.x, vo.y)
    self:CreateDrawObj()
    self:ShowShadow(true)
	self:InitBuffList()

	local sk_list = scene:GetSkillList(vo.id)
	if sk_list then
		self:InitSkillInfo(sk_list.skill_list, sk_list.skill_cd)
	end
	
	self:ShowPetName(true)
	self:ShowPetTitle(true)

	self.is_main_role_pet = self:GetOwnerID() == self.scene:GetMainRoleID()
	if self.is_main_role_pet then
		self:CheckSkillEnabled()
	end
	if self:IsClientObj() then
		self:GetOperateMgr():SetDefaultOper(game.OperateType.HangPet)
	end
end

function Pet:Reset()
	if self.is_main_role_pet and self.scene then
		local main_role = self.scene:GetMainRole()
		if main_role then
			main_role:SetPetObjID()
		end
		_event_mgr:Fire(game.SceneEvent.MainRolePetChange, nil)
	end

	self.model_height = nil

	Pet.super.Reset(self)
end

-- attr
function Pet:GetServerType()
    return 3
end

function Pet:IsMainRolePet()
	return self.is_main_role_pet
end

function Pet:GetName()
    return self.vo.name
end

function Pet:GetLevel()
    return self.vo.level
end

function Pet:GetOwnerID()
	return self.vo.owner_id
end

function Pet:GetOwner()
	return self.scene:GetObjByUniqID(self.vo.owner_id)
end

function Pet:GetIconID()
	return game.PetCtrl.instance:GetPetMainIcon(self.vo)
end

function Pet:GetAttackDist()
	return 8
end

function Pet:GetAttackType()
	return self.attack_type
end

function Pet:IsClientObj()
	return self.is_main_role_pet or (self.uniq_id and self.vo.owner_id <= 10000)
end

function Pet:IsPet()
	return true
end

function Pet:GetTargetID()
	local owner = self:GetOwner()
	if owner then
		return owner:GetTargetID()
	end
end

function Pet:GetTarget()
	local owner = self:GetOwner()
	if owner then
		return owner:GetTarget()
	end
end

function Pet:ChangeHp(hp)
	Pet.super.ChangeHp(self, hp)
	if self.is_main_role_pet then
		_event_mgr:Fire(game.SceneEvent.MainRolePetHpChange, self:GetHpPercent(), hp)
	end
end

-- 外观形象相关
function Pet:CreateDrawObj()
	local cfg = config.pet[self.vo.pet_cid]
    self.pet_cfg = cfg
    self.attack_type = 1

    self.draw_obj = game.GamePool.DrawObjPool:Create()
    self.draw_obj:Init(game.BodyType.Monster)
    self.draw_obj:SetParent(self.root_obj.tran)
    self.draw_obj:SetModelID(_model_type.Body, game.PetCtrl.instance:GetPetModel(self.vo))

    self:RefreshShow()

    self:SetClickCallBack(function()
        local main_role = game.Scene.instance:GetMainRole()
        if main_role then
            main_role:SelectTarget(self)
            main_role:GetOperateMgr():DoAttackTarget(self.obj_id, false)
        end
    end, 1)
end

function Pet:SetModelID(id)
	if self.draw_obj then
    	self.draw_obj:SetModelID(_model_type.Body, id)
	end
end

-- proto
local attack_proto = {}
function Pet:SendAttackReq(skill_id, obj, assist_x, assist_y)
	attack_proto.id = self.uniq_id
	attack_proto.owner_id = self.vo.owner_id
	attack_proto.skill_id = skill_id
	
	local sk_info = self:GetSkillInfo(skill_id)
	if sk_info then
		attack_proto.skill_lv = sk_info.lv
	else
		attack_proto.skill_lv = 1
	end

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
	_game_net:SendProtocal(90305, attack_proto)
end

local pre_skill_proto = {}
function Pet:SendPreSkillReq(skill_id, obj, assist_pos, op)
	pre_skill_proto.id = self.uniq_id
	pre_skill_proto.owner_id = self.vo.owner_id
	pre_skill_proto.skill_id = skill_id

	local sk_info = self:GetSkillInfo(skill_id)
	if sk_info then
		pre_skill_proto.skill_lv = sk_info.lv
	else
		pre_skill_proto.skill_lv = 1
	end
	
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
    if assist_pos then
        pre_skill_proto.assist_x = assist_pos.x
        pre_skill_proto.assist_y = assist_pos.y
    end

	pre_skill_proto.assist_x = math.floor(pre_skill_proto.assist_x)
	pre_skill_proto.assist_y = math.floor(pre_skill_proto.assist_y)
	pre_skill_proto.op = op
	_game_net:SendProtocal(90306, pre_skill_proto)
end

local walk_proto = {}
function Pet:SendWalkReq(x, y, move)
	walk_proto.pet_id = self.uniq_id
	walk_proto.scene_id = self.scene:GetSceneID()
	walk_proto.cx, walk_proto.cy = self:GetLogicPosXY()
	walk_proto.x, walk_proto.y = x, y
	walk_proto.move = move
	walk_proto.reset_index = self.reset_index
	_game_net:SendProtocal(90202, walk_proto)
end

function Pet:RefreshNameColor()
	local main_role = self.scene:GetMainRole()
	if main_role and main_role:IsEnemy(self) then
		self:SetHudTextColor(game.HudItem.Name, 2)
	else
		self:SetHudTextColor(game.HudItem.Name, 1)
	end
end

function Pet:RefreshShow()
	self:SetModelVisible(self:IsSettingVisible())
end

function Pet:IsSettingVisible()
	return (not game.SysSettingCtrl.instance:IsSettingActived(game.SysSettingKey.MaskPet))
end

function Pet:ShowPetTitle(enable)
	if enable and self.vo.title_s ~= "" then
		self:SetHudText(game.HudItem.Tips, self.vo.title_s, self.vo.title_c + 1)
	else
		self:SetHudItemVisible(game.HudItem.Tips, false)
	end
end

function Pet:ShowPetName(enable)
	if enable then
		self:SetHudText(game.HudItem.Name, self.vo.name)
		self:RefreshNameColor()
	else
		self:SetHudItemVisible(game.HudItem.Name, false)
	end
end

function Pet:DoDie()
	Pet.super.DoDie(self)
	if self:IsMainRolePet() then
		self:SetVisible(false)
		self:ShowHud(false)
		_event_mgr:Fire(game.SceneEvent.MainRolePetDie, self.obj_id, true)
	end
	if self.is_selected then
		local main_role = self.scene:GetMainRole()
		if main_role then
			main_role:SelectTarget(nil)
		end
	end
end

function Pet:DoRevive()
	Pet.super.DoRevive(self)
	if self:IsMainRolePet() then
		self:SetVisible(true)
		self:ShowHud(true)
		_event_mgr:Fire(game.SceneEvent.MainRolePetDie, self.obj_id, false)
	end
end

function Pet:PlaySkill(id, lv)
	local skill_info = self:GetSkillInfo(id)
	if skill_info then
		_fight_ctrl.instance:PlayPetSkill(self, id, lv, skill_info.fly_icon)
	end
end

function Pet:CheckSkillEnabled()
	for _,v in pairs(self.skill_list or {}) do
		if #v.condition > 0 and (v.condition[1] == 3 or v.condition[1] == 4) then
			local val = game.SysSettingCtrl.instance:GetLocal(v.id)
			self:_CheckSkillEnabled(v.id, val)
		end
	end
end

function Pet:_CheckSkillEnabled(id, val)
	local skill_info = self:GetSkillInfo(id)
	if skill_info then
	    if val == -1 then
	    	skill_info.enabled = false
	    else
	    	skill_info.enabled = val < 1000
			skill_info.condition[2] = (val % 1000) * 0.01
		end
	end
end

function Pet:ShowLvupEffect()
	local lvup_effect = game.EffectMgr.instance:CreateObjEffect("effect/scene/pet_lvup.ab", self.obj_id)
	self:GetRoot():AddChild(lvup_effect:GetRoot())
end

function Pet:GetModelHeight()
	if self.model_height == nil then
		local cfg = config.pet[self.vo.pet_cid]
		local model_id = game.PetCtrl.instance:GetPetModel(self.vo)
		if cfg.model_height == 0 then
			if _monster_size[model_id] then
				self.model_height = _monster_size[model_id][2] + 0.3
			else
				self.model_height = 2
			end
		else
			self.model_height = cfg.model_height
		end
	end

	return self.model_height
end

function Pet:CanPlayBuffEffect()
	if self:IsMainRolePet() then
		return true
	end
	return Pet.super.CanPlayBuffEffect(self)
end

function Pet:CanPlaySkillEffect(skill_id)
	if self:IsMainRolePet() then
		return true
	end
	return Pet.super.CanPlaySkillEffect(self, skill_id)
end

function Pet:CanPlayBeattackEffect()
	if self:IsMainRolePet() then
		return true
	end
	return Pet.super.CanPlayBeattackEffect(self)
end

return Pet
