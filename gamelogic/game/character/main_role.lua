
local MainRole = Class(require("game/character/role"))

local _game_net = game.GameNet
local _event_mgr = global.EventMgr
local _obj_state = game.ObjState
local _dialog_cfg = config.dialog_frame

function MainRole:_init()
	self.obj_type = game.ObjType.MainRole
    self.update_cd = 0.1

    self.aoi_mask = game.AoiMask.MainRole
	self.aoi_range = 30
	self.next_sound_time = 0
end

function MainRole:_delete()

end

function MainRole:Init(scene, vo)
	MainRole.super.Init(self, scene, vo)

	self.rival_map = {}
	self.static_buff_list = {}
    self.reset_index = vo.reset_index
	self.pk_mode = game.PkMode.Peace
	self.fight_state = 0
	self.next_pk_mode = 0
	self.static_buff_update_time = 0
	self.is_client_obj = true
	-- self:ShowLight(true)

	self:SetLayer(game.LayerName.MainSceneObject)
	self:InitSkillInfo(vo.skill_list, vo.skill_cd)

	self:CheckSkillEnabled()

	-- self.draw_obj:SetMatEffect(game.MaterialEffect.Occlusion, true)
	self:RegisterAoiWatcher(self.aoi_range, self.aoi_range, game.AoiMask.All - game.AoiMask.MainRole)

	self.ev_list = {
		_event_mgr:Bind(game.SkillEvent.SkillNew, handler(self, self.OnSkillChange)),
		_event_mgr:Bind(game.SceneEvent.ClickNpc, handler(self, self.OnClickNpc)),
		_event_mgr:Bind(game.SkillEvent.UpdateSkillInfo, handler(self, self.OnUpdateSkillInfo)),
		_event_mgr:Bind(game.SceneEvent.HangChange, handler(self, self.OnHangChange)),
		-- _event_mgr:Bind(game.SceneEvent.ObjDelete, handler(self, self.OnObjDelete)),
		_event_mgr:Bind(game.SceneEvent.MainRoleCarryChange, handler(self, self.SetCarryObjID)),
		_event_mgr:Bind(game.SkillEvent.SkillBloodSettingChange, handler(self, self.OnSkillBloodSettingChange)),
		_event_mgr:Bind(game.SkillEvent.PetSkillBloodSettingChange, handler(self, self.OnPetSkillBloodSettingChange)),
	}
end

function MainRole:Reset()
	for i,v in ipairs(self.ev_list) do
		_event_mgr:UnBind(v)
	end
	self.ev_list = nil

	self.aoi_enter_listener = nil
	self.aoi_leave_listener = nil

	if self.sound_key then
		global.AudioMgr:StopSound(self.sound_key)
		self.sound_key = nil
	end
	self.next_sound_time = 0

	MainRole.super.Reset(self)
end

function MainRole:IsMainRole()
	return true
end

function MainRole:IsClientObj()
	return self.is_client_obj
end

function MainRole:SetClientObj(val)
	self.is_client_obj = val
end

function MainRole:Update(now_time, elapse_time)
	self:UpdatePkMode(now_time, elapse_time)
	self:UpdateFightState(now_time, elapse_time)
	self:UpdateStaticBuff(now_time, elapse_time)
	self:UpdateDialogState(now_time, elapse_time)
	self:PlayMoveSound(now_time, elapse_time)
	MainRole.super.Update(self, now_time, elapse_time)
end

function MainRole:UpdateModel()
	if self._pos_dirty then
		self._pos_dirty = false
		self.map_height = self:CalcMapHeight()

        --人物进场景后射线计算不出地图高度 就调用初始计算的地图高度
		if self.map_height == -9999 then
			self.map_height = game.Obj.instance:CalcMapHeight()
			self.map_height = self.map_height + 1
		end

		self.main_root_obj.tran:SetPosition(self.unit_pos.x, self.map_height + self.height, self.unit_pos.y)
		-- if game.__DEBUG__ then
		-- 	self:ShowPos()
		-- end
	end

	if self._rot_dirty then
		self._rot_dirty = false
		self.root_obj.tran:SetLookDir(self.dir.x, 0, self.dir.y)
	end
end

function MainRole:SetSpeed(val)
	self.vo.attr.move_speed = val
end

local div = 1/24
function MainRole:GetSpeed()
	return self.vo.attr.move_speed * div
end

-- aoi
function MainRole:SetAoiEnterListener(listener)
    self.aoi_enter_listener = listener
end

function MainRole:SetAoiLeaveListener(listener)
	self.aoi_leave_listener = listener
end

function MainRole:OnAoiObjEnter(obj_id)
	if self.aoi_enter_listener then
	    if obj_id ~= self.obj_id then
	        self.aoi_enter_listener(obj_id)
	    end
	end
end

function MainRole:OnAoiObjLeave(obj_id)
	if self.aoi_leave_listener then
		if obj_id ~= self.obj_id then
			self.aoi_leave_listener(obj_id)
		end
	end
end

function MainRole:SendMountState()
	game.ExteriorCtrl.instance:SendExteriorMountOpe()
end

local wing_hide_proto = {id = 2}
function MainRole:SendWingState(is_hide)
	wing_hide_proto.hide = (is_hide and 1 or 0)
	_game_net:SendProtocal(40923, wing_hide_proto)
end

local collect_proto = {}
function MainRole:SendCollectReq(id, gather_id)
	collect_proto.coll_id = id
	collect_proto.coll_type_id = gather_id
	_game_net:SendProtocal(90320, collect_proto)
end

-- attr
function MainRole:SetMaxHp(hp)
	self.vo.attr.hp_lim = hp
end

function MainRole:GetMaxHp()
	return self.vo.attr.hp_lim
end

function MainRole:ChangeHp(hp)
    MainRole.super.ChangeHp(self, hp)
	_event_mgr:Fire(game.SceneEvent.MainRoleHpChange)
end

function MainRole:GetMp()
	return self.vo.mp
end

function MainRole:SetMaxMp(mp)
	self.vo.attr.mp_lim = mp
end

function MainRole:GetMaxMp()
	return self.vo.attr.mp_lim
end

function MainRole:ChangeMp(mp)
	local delta = mp - self.vo.mp
	if delta > 0 then
		self:PlayMp(delta)
    end
    MainRole.super.ChangeMp(self, mp)
	_event_mgr:Fire(game.SceneEvent.MainRoleMpChange) 
end

function MainRole:GetMpPercent()
	return self.vo.mp / self.vo.attr.mp_lim
end

function MainRole:DoDie(killer_id, killer_name, die_time)
	MainRole.super.DoDie(self)
    _event_mgr:Fire(game.SceneEvent.MainRoleDie, killer_id, killer_name, die_time)
end

function MainRole:DoRevive()
    self:SelectTarget(nil)
	self:RegisterAoiWatcher(self.aoi_range, self.aoi_range, game.AoiMask.All - game.AoiMask.MainRole)
    MainRole.super.DoRevive(self)
    _event_mgr:Fire(game.SceneEvent.MainRoleRevive)
end

function MainRole:DoBeattack(attacker, skill_id, skill_lv, defer_info, hero_id, legend)
	if self:GetHp() > defer_info.defer_hp then
		if not attacker or attacker:IsMonster() then
	        self:EnterFightState(1)
	    else
	        self:EnterFightState(2)
	    end
	end

	MainRole.super.DoBeattack(self, attacker, skill_id, skill_lv, defer_info, hero_id, legend)
end


-- attack
function MainRole:SelectTarget(obj)
	local last_target = self:GetTarget()
	if obj and last_target then
		if obj.obj_id == last_target.obj_id then
			return
		end
	end

	if last_target then
		last_target:SetSelected(false)
	end

	if obj then
		obj:SetSelected(true)
	end

	MainRole.super.SelectTarget(self, obj)
	self:FireSelectTarget(obj)
end

function MainRole:FireSelectTarget(obj)	
	_event_mgr:Fire(game.SceneEvent.TargetChange, obj)
end

function MainRole:_CanPlaySkill(skill_info, now_time, notice)
	if MainRole.super._CanPlaySkill(self, skill_info, now_time, notice) then
		if self.vo.mp >= skill_info.mp then
			return true
		else
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[523])
			end
		end
	end
end

function MainRole:ShowLvupEffect()
	local lvup_effect = game.EffectMgr.instance:CreateObjEffect("effect/scene/lvup.ab", self.obj_id)
	self:GetRoot():AddChild(lvup_effect:GetRoot())
end

function MainRole:SetDefaultOper(oper_type)
	self:GetOperateMgr():SetDefaultOper(oper_type)
end

-- skill
function MainRole:OnSkillChange(sk_list)
	local new_skill = false
	for i,v in ipairs(sk_list) do
		new_skill = new_skill or (self.skill_list[v.id] == nil)
		self:InitSkill(v.id, v.lv)
	end
	if new_skill then
		_event_mgr:Fire(game.SceneEvent.MainRoleSkillChange)
	end
end

function MainRole:OnUpdateSkillInfo(data)
	self:InitSkill(data.id, data.lv, data.hero, data.legend)

	_event_mgr:Fire(game.SceneEvent.MainRoleSkillChange)
end

function MainRole:OnClickNpc(npc_id)
	self:GetOperateMgr():DoClickNpc(npc_id)
end

function MainRole:CheckSkillEnabled()
	local skill_ctrl = game.SkillCtrl.instance
	local skill_list = self:GetSkillList()
	for _,v in pairs(skill_list or {}) do
		self:SetSkillEnabled(v.id, skill_ctrl:IsSkillSettingActivedForId(v.id))

		if #v.condition > 0 and v.condition[1] == 2 then
			local val = game.SysSettingCtrl.instance:GetLocal(v.id)
            if val ~= -1 then
				v.condition = {2, val * 0.01}
            end
		end
	end
end

function MainRole:OnHangChange(is_hang)
	self.is_hang = is_hang
end

function MainRole:IsHanging()
	return self.is_hang
end

local _refresh_name_func = function(obj)
	if obj.obj_type == game.ObjType.Role or obj:IsMonster() or obj:IsPet() then
		obj:RefreshNameColor()
	end
end
function MainRole:ChangePkMode(mode, next_mode, next_mode_cd)
	if self.pk_mode ~= mode then
		self.pk_mode = mode
		self.scene:ForeachObjs(_refresh_name_func)
	end
	
	if next_mode then
		self.next_pk_mode = next_mode
		self.next_pk_mode_time = next_mode_cd + global.Time.now_time
	end
	_event_mgr:Fire(game.SceneEvent.PkModeChange, mode)
end

function MainRole:_OnRefreshPkMode(obj)
	if obj.obj_type == game.ObjType.Role or obj:IsMonster() or obj:IsPet() then
		obj:RefreshNameColor()
	end
end

function MainRole:SetTeam(id)
	if self.vo.team ~= id then
		self.vo.team = id
		self.scene:ForeachObjs(_refresh_name_func)
	end
end

function MainRole:GetPkMode()
	return self.pk_mode
end

function MainRole:UpdatePkMode(now_time, elapse_time)
	if self.next_pk_mode > 0 and now_time > self.next_pk_mode_time  then
		self.scene:SendChangeSceneModeReq(self.next_pk_mode)
		self.next_pk_mode = 0
	end
end

function MainRole:SetRealm(realm)
	if self.vo.realm ~= realm then
		self.vo.realm = realm
		self.scene:ForeachObjs(_refresh_name_func)
	end
end

function MainRole:GetRealm()
	return self.vo.realm
end

function MainRole:SetIconID(id)
	MainRole.super.SetIconID(self, id)
	_event_mgr:Fire(game.SceneEvent.MainRoleIconChange)
end

function MainRole:AddBuff(uid, id, lv, time)
	local buff_info = MainRole.super.AddBuff(self, uid, id, lv, time)
	_event_mgr:Fire(game.SceneEvent.MainRoleAddBuff, buff_info)
end

function MainRole:DelBuff(uid, id)
	MainRole.super.DelBuff(self, uid, id)
	_event_mgr:Fire(game.SceneEvent.MainRoleDelBuff, uid)
end

function MainRole:IsSettingVisible()
	return true
end

function MainRole:SetPetObjID(obj_id)
	self.pet_obj_id = obj_id
end

function MainRole:SetCarryObjID(obj_id)
	self.carry_obj_id = obj_id
end

function MainRole:GetPet()
	return self.scene:GetObj(self.pet_obj_id)
end

function MainRole:GetCarry()
	return self.scene:GetObj(self.carry_obj_id)
end

function MainRole:AddRival(id)
	if not self.rival_map[id] then
		self.rival_map[id] = true
		local obj = self.scene:GetObjByUniqID(id)
		if obj then
			obj:RefreshNameColor()
		end
	end
end

function MainRole:DelRival(id)
	if self.rival_map[id] then
		self.rival_map[id] = nil
		local obj = self.scene:GetObjByUniqID(id)
		if obj then
			obj:RefreshNameColor()
		end
	end
end

function MainRole:SetRivals(ls)
	for k,v in pairs(self.rival_map) do
		self:DelRival(k)
	end
	for i,v in ipairs(ls) do
		self:AddRival(v.rival_id)
	end
end

function MainRole:IsRival(id)
	return self.rival_map[id]
end

function MainRole:IsRivalGuildMember(obj)
	if obj and obj.obj_type == game.ObjType.Role then
		if game.Scene.instance:GetSceneType() == game.SceneType.OutSideScene and game.GuildCtrl.instance:IsRivalGuild(obj:GetGuildID()) then
			return true
		end
	end
	return false
end

function MainRole:IsRivalYunBiao(obj)
	if obj and obj.obj_type == game.ObjType.Role then
		local guild_id = obj:GetGuildID()
		if game.Scene.instance:GetSceneType() == game.SceneType.OutSideScene and game.GuildCtrl.instance:IsHostileGuild(guild_id) and (self:IsYunBiao() or obj:IsYunBiao()) then
			return true
		end
	end
	return false
end

function MainRole:IsEnemy(obj)
	if obj.uniq_id then
		if self:IsRival(obj.uniq_id) then
			return true
		elseif self:IsRivalYunBiao(obj) then
			return true
		elseif self:IsRivalGuildMember(obj) then
			return true
		end
	end

	local owner_id = obj:GetOwnerID()
	if owner_id ~= 0 then
		if self:IsRival(owner_id) then
			return true
		end
	end
	return MainRole.super.IsEnemy(self, obj)
end

function MainRole:ChangeMurderous(val)
	MainRole.super.ChangeMurderous(self, val)
	_event_mgr:Fire(game.SceneEvent.MainRoleMurderousChange)
end

function MainRole:RefreshNameColor()
	self:SetHudTextColor(game.HudItem.Name, 1)
end

-- 静态buff
local _static_buff_map = {
	[20100] = {
		-- 天灵丹
		uid = -1,
		check_visible_func = function(obj)
			return game.LakeExpCtrl.instance:GetKeepExp() > 0
		end,
		add_func = function(obj)
			obj:AddBuff(-1, 20100, 1)
		end,
	},
	[22001] = {
		-- 世界等级
		uid = -2,
		check_visible_func = function(obj)
			local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
			local ratio = config_help.ConfigHelpLevel.GetPioneerLvRatio(obj.vo.level, pioneer_lv)
			return config_help.ConfigHelpLevel.HasPioneerLvAdd(obj.vo.level, pioneer_lv) and ratio ~= 0
		end,
		add_func = function(obj)
			obj:AddBuff(-2, 22001, 1)
		end,
	},
	[22002] = {
		-- 世界等级
		uid = -3,
		check_visible_func = function(obj)
			local world_lv = game.MainUICtrl.instance:GetWorldLv()
			return obj.vo.level > world_lv
		end,
		add_func = function(obj)
			obj:AddBuff(-3, 22002, 1)
		end,
	},
	[20101] = {
		-- 地灵丹
		uid = -4,
		check_visible_func = function(obj)
			return game.LakeExpCtrl.instance:GetPetExp() > 0
		end,
		add_func = function(obj)
			obj:AddBuff(-4, 20101, 1)
		end,
	},
}

local _static_buff_update_delta = 10
function MainRole:UpdateStaticBuff(now_time, elapse_time)
	if now_time < self.static_buff_update_time then
		return
	end

	for i, v in pairs(_static_buff_map) do
		if v.check_visible_func(self) then
			if not self.static_buff_list[i] then
				self:AddStaticBuff(i)
			end
		else
			if self.static_buff_list[i] then
				self:DelBuff(v.uid)
				self.static_buff_list[i] = nil
			end
		end
	end

	self.static_buff_update_time = now_time + _static_buff_update_delta
end

function MainRole:AddStaticBuff(id)
	local buff_cfg = _static_buff_map[id]
	if buff_cfg then
		buff_cfg.add_func(self)
		self.static_buff_list[id] = true
	end
end

function MainRole:CalcMapHeight()
	if self.calc_map_height_func then
		return self.calc_map_height_func()
	end
	return self.scene:GetHeightByRaycast(self.root_obj.tran, self.unit_pos.x, self.unit_pos.y)
end

-- 战斗状态
function MainRole:IsFightState()
	return self.fight_state > 0
end

function MainRole:IsRoleFightState()
	return self.fight_state == 2
end

function MainRole:EnterFightState(state)
	local pre_fight_state = self.fight_state
	if self.fight_state == 0 then
		local id = self:GetCurStateID()
		if id == _obj_state.ChangeScene then
			self:DoIdle()
		end
		game.GameMsgCtrl.instance:PushMsg(config.words[526])
	end
	
	self.fight_state = state
	self.common_fight_end_time = global.Time.now_time + 10
	if state == 2 then
		self.role_fight_end_time = global.Time.now_time + 10
	end
	if pre_fight_state ~= self.fight_state then
		global.EventMgr:Fire(game.SceneEvent.MainRoleFightStateChange, self.fight_state)
	end
end

function MainRole:UpdateFightState(now_time, elapse_time)
	if self.fight_state > 0 then
		local pre_fight_state = self.fight_state
		if self.fight_state == 2 and now_time > self.role_fight_end_time then
			self.fight_state = 1
		end
		if self.fight_state == 1 and now_time > self.common_fight_end_time then
			self.fight_state = 0
			game.GameMsgCtrl.instance:PushMsg(config.words[527])
		end
		if pre_fight_state ~= self.fight_state then
			global.EventMgr:Fire(game.SceneEvent.MainRoleFightStateChange, self.fight_state)
		end
	end
end

function MainRole:CanRideMount(mode, notice)
	if mode == 1 then
		if self:IsRoleFightState() then
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[530])
			end
			return false
		end
		local mount_id = self:GetExteriorID(game.ExteriorType.Mount)
		if game.ExteriorCtrl.instance:IsExpireMount(mount_id) then
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[5524])
			end
			return false
		end
	end
	return MainRole.super.CanRideMount(self, mode, notice)
end

local next_dialog_time = 0
function MainRole:UpdateDialogState(now_time, elapse_time)
	for _, v in ipairs(_dialog_cfg) do
		if self.scene:GetSceneID() == v.scene and self:GetLogicDistSq(v.range[1], v.range[2]) <= v.range[3] * v.range[3] and game.TaskCtrl.instance:CheckDialogFrame(v) then
			self.dialog_list = {}
			for _, val in ipairs(v.content) do
				table.insert(self.dialog_list, val)
			end
		end
	end
	if self.dialog_list and #self.dialog_list > 0 and now_time > next_dialog_time then
		next_dialog_time = now_time + 3.25
		local cfg = self.dialog_list[1]
		global.EventMgr:Fire(game.SceneEvent.OnSkillSpeak, cfg[2], cfg[3], cfg[1])
		table.remove(self.dialog_list, 1)
	end
end

function MainRole:SetMountState(mode, server_change)
	local old_state = self.mount_state
	local ret = MainRole.super.SetMountState(self, mode, server_change)
	if old_state == 1 and mode ~= old_state and ret then
		local eff = game.EffectMgr.instance:CreateObjEffect("effect/scene/zq_xia.ab", self.obj_id)
		self:GetRoot():AddChild(eff:GetRoot())
	end
end

function MainRole:OnNotifyAngerChange(data)
	self.vo.anger = data.anger

	global.EventMgr:Fire(game.SkillEvent.UpdateSkillAnger, data.anger)
end

function MainRole:GetSkillAnger()
	return self.vo.anger
end

function MainRole:OnSkillBloodSettingChange(skill_id, val)
	local skill_info = self:GetSkillInfo(skill_id)
	if skill_info then
		skill_info.condition = {2, val * 0.01}
	end
end

function MainRole:OnPetSkillBloodSettingChange(skill_id, val)
	local pet = self:GetPet()
	if pet then
		pet:_CheckSkillEnabled(skill_id, val)
	end
end

function MainRole:GetCameraLerpDistSq()
	return 64
end

function MainRole:GetCameraLerpCos()
	return 0.65
end

function MainRole:CanPlayBuffEffect()
	return true
end

function MainRole:CanPlaySkillEffect(skill_id)
	return true
end

function MainRole:CanPlayBeattackEffect()
	return true
end

function MainRole:GetServerLine()
	return self.vo.line_id
end

local _move_sound = {
	[0] = "",    --坐骑脚步声
	[1] = "qt007_1",    --轻功
	[2] = "qt005_1",    --人物脚步声
}

function MainRole:PlayMoveSound(now_time, elapse_time)
	if now_time > self.next_sound_time then
		self.next_sound_time = now_time + 0.2
		if self:GetCurStateID() == _obj_state.Move then
			if not self.sound_key then
				self.cur_move_state = self:GetMoveState()
				self.sound_key = global.AudioMgr:PlaySound(_move_sound[self.cur_move_state], nil, nil, true)
			else
				if self.cur_move_state ~= self:GetMoveState() then
					self.cur_move_state = self:GetMoveState()
					global.AudioMgr:StopSound(self.sound_key)
					self.sound_key = global.AudioMgr:PlaySound(_move_sound[self.cur_move_state], nil, nil, true)
				end
			end
		else
			if self.sound_key then
				global.AudioMgr:StopAllSound()
				self.sound_key = nil
			end
		end
	end
end

function MainRole:SetPauseHangTask(val)
	local oper_mgr = self:GetOperateMgr()
	local cur_oper = oper_mgr:GetCurOperate()
	if cur_oper and cur_oper:GetOperateType()==game.OperateType.HangTask then
		cur_oper:SetPause(val)
	end
end

return MainRole
