
local Scene = game.Scene

local _obj_type = game.ObjType

function Scene:RegisterAllProtocal()
	self:RegisterProtocalCallback(90101, "OnRoleEnterSceneInfoResp")
	self:RegisterProtocalCallback(90201, "OnBcastObjWalk")

	self:RegisterProtocalCallback(90232, "OnBcastAddRoleSceneInfo")
	self:RegisterProtocalCallback(90233, "OnBcastDelRole")
	self:RegisterProtocalCallback(90234, "OnBcastAddMonSceneInfo")
	self:RegisterProtocalCallback(90235, "OnBcastDelMon")
	self:RegisterProtocalCallback(90239, "OnBcastAddCollSceneInfo")
	self:RegisterProtocalCallback(90240, "OnBcastDelColl")
	self:RegisterProtocalCallback(90203, "OnResetPoint")

	self:RegisterProtocalCallback(90301, "OnBcastAttack")
	self:RegisterProtocalCallback(90302, "OnBcastBattleHarm")
	self:RegisterProtocalCallback(90304, "OnBcastPreSkill")

	self:RegisterProtocalCallback(90243, "OnBcastObjHpChange")
	self:RegisterProtocalCallback(90244, "OnNotifyMpChange")

	self:RegisterProtocalCallback(90236, "OnBcastAddPetSceneInfo")
	self:RegisterProtocalCallback(90237, "OnBcastDelPet")
	self:RegisterProtocalCallback(90110, "OnNotifyObjBasic")
	self:RegisterProtocalCallback(90111, "OnNotifyObjSkills")
    self:RegisterProtocalCallback(90310, "OnNotifyClearSkillCd")

	self:RegisterProtocalCallback(90308, "OnBcastRevive")
	self:RegisterProtocalCallback(90106, "OnNotifyRoleDie")
	self:RegisterProtocalCallback(90107, "OnNotifyRoleRevive")
	self:RegisterProtocalCallback(90248, "OnBcastObjDie")
	self:RegisterProtocalCallback(90249, "OnBcastMoveSpeedChange")
	self:RegisterProtocalCallback(90230, "OnBcastBuffChange")
	self:RegisterProtocalCallback(90205, "OnGetMonPosResp")
	self:RegisterProtocalCallback(90108, "OnNotifyPetRevive")

	self:RegisterProtocalCallback(90102, "OnBcastRoleSceneAttr")
	self:RegisterProtocalCallback(90129, "OnNotifyPetLeave")
	self:RegisterProtocalCallback(90250, "OnBcastCollectSt")	
	self:RegisterProtocalCallback(90113, "OnChangeSceneModeResp")
	self:RegisterProtocalCallback(90321, "OnBcastCollect")
	self:RegisterProtocalCallback(90251, "OnBcastRoleInfoChange")
	self:RegisterProtocalCallback(90252, "OnBcastObjSpecState")

	self:RegisterProtocalCallback(90253, "OnBcastAddCarrySceneInfo")
	self:RegisterProtocalCallback(90254, "OnBcastDelCarry")
	self:RegisterProtocalCallback(90255, "OnBcastExteriorChange")
	self:RegisterProtocalCallback(90120, "OnNotifyBtAttrChange")

	self:RegisterProtocalCallback(90115, "OnNotifyRivals")
	self:RegisterProtocalCallback(90116, "OnNotifyAddRival")
	self:RegisterProtocalCallback(90117, "OnNotifyDelRival")
	self:RegisterProtocalCallback(90256, "OnBcastMurderousChange")
    self:RegisterProtocalCallback(20505, "OnLevelChange")
    self:RegisterProtocalCallback(90118, "OnNotifyBeDeclearWar")

    self:RegisterProtocalCallback(90257, "OnBcastAddFlyitemSceneInfo")
    self:RegisterProtocalCallback(90258, "OnBcastDelFlyitem")

    self:RegisterProtocalCallback(40610, "OnTitleChange")
    self:RegisterProtocalCallback(40611, "OnTitleHeader")
    self:RegisterProtocalCallback(40713, "OnHairChange")
    self:RegisterProtocalCallback(42060, "OnTeamChange")
    self:RegisterProtocalCallback(40710, "OnFashionChange")
    self:RegisterProtocalCallback(90259, "OnBcastArtifactChangeAvatar")
    self:RegisterProtocalCallback(90246, "OnBcastRoleChangeIcon")
    self:RegisterProtocalCallback(90260, "OnBcastGuildInfoChange")
    self:RegisterProtocalCallback(90128, "OnNotifyAngerChange")
    self:RegisterProtocalCallback(90261, "OnNotifyWarriorSoulChangeAvatar")
	self:RegisterProtocalCallback(10706, "OnNotifyRoleNameChange")
	self:RegisterProtocalCallback(52536, "OnRolePlayAction")
	self:RegisterProtocalCallback(42802, "OnBcastTransformStat")
	self:RegisterProtocalCallback(90247, "OnNotifyKillRole")
	self:RegisterProtocalCallback(90263, "OnBcastMonFirstAtt")
	self:RegisterProtocalCallback(41610, "OnMarryNotify")
end

function Scene:RegisterErrorCode()

end

function Scene:RegisterAllEvent()
	self.ev_list = {

	}
end

function Scene:SendRoleEnterSceneInfoReq()
	self:SendProtocal(90100)
end

function Scene:SendRoleInitInfoReq()
	--self:SendProtocal(90109)
end

function Scene:SendSceneInfoReq()
	self:SendProtocal(90207)
end

local ChangeSceneFunc = {
	[config.sys_config.guild_seat_scene.value] = {
		enter_func = function()
			game.GuildCtrl.instance:SendGuildEnterSeat()
		end,
	},
}
function Scene:SendChangeSceneReq(scene_id, line_id)
	if self:GetSceneID()==scene_id and self:GetServerLine()==line_id then
		return
	end

	if self.scene_logic:CanChangeScene(scene_id, false) then
		local scene_cfg = ChangeSceneFunc[scene_id]
		if scene_cfg and scene_cfg.enter_func then
			scene_cfg.enter_func()
		else
			self:SendProtocal(90208, {scene_id = scene_id, line_id = line_id or 0})
		end
	end
end

function Scene:OnRoleEnterSceneInfoResp(data_list)
	global.Time:Reset()
	global.Time:SetServerTime(data_list.server_time)
	self.main_role_vo = data_list

	self:FireEvent(game.SceneEvent.UpdateEnterSceneInfo, data_list)

	if game.GameLoop.instance:GetCurState() == game.GameLoop.State.Reconnect then
		global.EventMgr:Fire(game.LoginEvent.LoginReconnectRet, data_list)
	else
		self:ChangeToLoading(data_list)
	end

	self:SendInfoToPhp()
	game.SDKMgr:SendSDKData(2)
    game.SDKMgr:SendSDKData(3)
end

function Scene:ChangeToLoading(data_list)
	local param = {}
	param.scene_id = data_list.scene_id
	param.unit_pos = cc.vec2(data_list.x, data_list.y)
	game.GameLoop:ChangeState(game.GameLoop.State.Loading, param)
end

function Scene:SendInfoToPhp()
	local server_id = game.LoginCtrl.instance:GetLoginServerID()
	if server_id ~= 0 then
		local accname = game.LoginCtrl.instance:GetLoginAccount()
		local nickname = self.main_role_vo.name
		local role_id = self.main_role_vo.role_id

		if not game.LoginCtrl.instance:GetPerson(game.AccountInfo.account, role_id) then
			game.ServiceMgr:SendCreateRole(accname, server_id, role_id, nickname)
		else
			game.ServiceMgr:UpdateRoleInfo(accname, server_id, self.main_role_vo.server_num, role_id, nickname, self.main_role_vo.level)
		end
	end
end

function Scene:OnResetPoint(data_list)
	local obj = self:GetObjByUniqID(data_list.obj_id)
	if obj then
		obj.reset_index = data_list.reset_index
		if data_list.reset_type ~= 7 then
			obj:DoIdle()
			obj:SetLogicPos(data_list.x, data_list.y)
		end
	end
end

function Scene:OnBcastObjWalk(data_list)
	local obj = self:GetObjByUniqID(data_list.id)
	if obj then
		if obj:IsClientObj() then
			return
		end
		if data_list.move == 5 then
			obj:DoIdle()
			obj:SetLogicPos(data_list.x, data_list.y)
		else
			if data_list.x ~= obj.logic_pos.x or data_list.x ~= obj.logic_pos.y then
				if (obj.obj_type == game.ObjType.Role or obj.obj_type == game.ObjType.MainRole) and obj.vo.state & 8 ~= 0 then
					obj:DoCruisMove(data_list.x, data_list.y)
				else
					local ux, uy = game.LogicToUnitPos(data_list.x, data_list.y)
					obj:DoMove(ux, uy)
				end
			end
		end
	else
		if data_list.type == 1 then
			local vo = self:GetNewMonsterVo(data_list.id)
			if vo then
				vo.x = data_list.x
				vo.y = data_list.y
			end
		elseif data_list.type == 3 then
			local vo = self:GetNewPetVo(data_list.id)
			if vo then
				vo.x = data_list.x
				vo.y = data_list.y
			end
		else
			local vo = self:GetNewRoleVo(data_list.id)
			if vo then
				vo.x = data_list.x
				vo.y = data_list.y
			end
		end
	end
end

function Scene:OnBcastAddRoleSceneInfo(data_list)
	for i,v in ipairs(data_list.role_list) do
		local vo = v.role
		if not self.main_role_vo or self.main_role_vo.role_id ~= vo.role_id then
			if not self:GetObjID(vo.role_id) then
				self:AddNewRoleVo(vo)
			end
		end
	end
end

function Scene:OnBcastAddMonSceneInfo(data_list)
	for i,v in ipairs(data_list.mon_list) do
		local vo = v.mon
		local obj_id = self:GetObjID(vo.id)
		if obj_id then
			self:DeleteObj(obj_id)
		end
		self:AddNewMonsterVo(vo)
	end
end

function Scene:OnBcastAddFlyitemSceneInfo(data_list)
	for i,v in ipairs(data_list.flyitem_list) do
		local vo = v.flyitem
		local obj_id = self:GetObjID(vo.id)
		if obj_id then
			self:DeleteObj(obj_id)
		end
		self:AddNewFlyItemVo(vo)
	end
end

function Scene:OnBcastDelFlyitem(data_list)
	for i,v in ipairs(data_list.flyitem_ids) do
		local obj_id = self:GetObjID(v.flyitem_id)
		if obj_id then
			self:DeleteObj(obj_id)
		end
		self:DelNewFlyItemVo(v.flyitem_id)
	end
end

function Scene:OnBcastDelRole(data_list)
	for i,v in ipairs(data_list.role_ids) do
		if not self.main_role_vo or self.main_role_vo.role_id ~= v.role_id then
			local obj_id = self:GetObjID(v.role_id)
			if obj_id then
				self:DeleteObj(obj_id)
			end
			self:DelNewRoleVo(v.role_id)
		end
	end
end

function Scene:OnBcastDelMon(data_list)
	for i,v in ipairs(data_list.mon_ids) do
		local obj_id = self:GetObjID(v.mon_id)
		if obj_id then
			self:DeleteObj(obj_id)
		end
		self:DelNewMonsterVo(v.mon_id)
	end
end

function Scene:OnBcastAddCarrySceneInfo(data_list)
	for i,v in ipairs(data_list.carry_list) do
		local vo = v.carry
		local obj_id = self:GetObjID(vo.id)
		if obj_id then
			self:DeleteObj(obj_id)
		end

		if vo.type == 1 then
			self:AddNewCarryVo(vo)
		elseif vo.type == 2 then
			self:CreateCarry(vo)
		end
	end
end

function Scene:OnBcastDelCarry(data_list)
	for i,v in ipairs(data_list.carry_ids) do
		local obj_id = self:GetObjID(v.carry_id)
		if obj_id then
			self:DeleteObj(obj_id)
		end
		self:DelNewCarryVo(v.carry_id)
	end
end

function Scene:OnBcastAddCollSceneInfo(data_list)
	for _, v in ipairs(data_list.coll_list) do
		local vo = v.coll
		local obj_id = self:GetObjID(vo.id)
		if obj_id then
			self:DeleteObj(obj_id)
		end
		self:AddNewGatherVo(vo)
	end
end

function Scene:OnBcastDelColl(data_list)
	for i,v in ipairs(data_list.coll_ids) do
		local obj_id = self:GetObjID(v.coll_id)
		if obj_id then
			self:DeleteObj(obj_id)
		end
		self:DelNewGatherVo(v.coll_id)
	end
end

function Scene:OnBcastAddPetSceneInfo(data_list)
	for i,v in ipairs(data_list.pet_list) do
		if not self:GetObjByUniqID(v.pet.id) then
			self:AddNewPetVo(v.pet)
		end
	end
end

function Scene:OnBcastDelPet(data_list)
	for i,v in ipairs(data_list.pet_ids) do
		local obj = self:GetObjByUniqID(v.pet_id)
		if obj then
			if obj.vo.owner_id ~= self:GetMainRoleID() then
				self:DeleteObj(obj.obj_id)
			end
		end
		self:DelNewPetVo(v.pet_id)
	end
end

function Scene:OnBcastAttack(data_list)
	local attacker = self:GetObjByUniqID(data_list.atter_id)
	local defender = self:GetObjByUniqID(data_list.defer_id)
	if attacker then
		if data_list.is_trig == 0 then
			if not attacker:IsClientObj() then
				if not defender then
					attacker:SetDir(data_list.assist_x - attacker.logic_pos.x, data_list.assist_y - attacker.logic_pos.y)
				end
				attacker:DoAttack(data_list.skill_id, data_list.skill_lv, defender, data_list.hero, data_list.legend, true, data_list.assist_x, data_list.assist_y)
			end
		else
			attacker:PlayOtherSkillEffect(data_list.skill_id, data_list.skill_lv, data_list.hero, data_list.legend, data_list.assist_x, data_list.assist_y)
		end
	end
end

function Scene:OnBcastBattleHarm(data_list)
	local obj
	local attacker = self:GetObjByUniqID(data_list.atter_id)
	local show_blood = attacker ~= nil and attacker:IsClientObj()
	for i,v in ipairs(data_list.defer_list) do
		obj = self:GetObjByUniqID(v.defer.defer_id)
		if obj then
			if data_list.skill_id ~= 0 then
				obj:DoBeattack(attacker, data_list.skill_id, data_list.skill_lv, v.defer, v.hero, v.legend)
			end
			obj:ChangeHp(v.defer.defer_hp)
			if show_blood or obj:IsClientObj() then
				for i1,v1 in ipairs(v.defer.hurt_seq) do
					obj:PlayBlood(v1.injury, v1.harm_type)
				end
			end
			if v.defer.defer_x ~= 0 and v.defer.defer_y ~= 0 then
				obj:DoIdle()
				obj:SetLogicPos(v.defer.defer_x, v.defer.defer_y)
			end
		end
	end
end

function Scene:OnBcastPreSkill(data_list)
	local attacker = self:GetObjByUniqID(data_list.atter_id)
	local defender = self:GetObjByUniqID(data_list.defer_id)
	if attacker then
		if not attacker:IsClientObj() then
			if not defender then
				attacker:SetDir(data_list.assist_x - attacker.logic_pos.x, data_list.assist_y - attacker.logic_pos.y)
			end
			if data_list.op == 1 then
				attacker:DoAttack(data_list.skill_id, data_list.skill_lv, defender, data_list.hero, data_list.legend, nil, data_list.assist_x, data_list.assist_y)
			else
				if attacker:GetCurStateID() == game.ObjState.PreAttack then
					attacker:DoIdle()
				end
			end
		end
	end
end

function Scene:OnBcastObjHpChange(data_list)
	local obj = self:GetObjByUniqID(data_list.id)
	if obj then
		if obj:IsClientObj() then
			local delta_hp = data_list.hp - obj:GetHp()
			obj:PlayBlood(delta_hp, delta_hp > 0 and 9 or 0)
		end
		obj:SetMaxHp(data_list.hp_lim)
		obj:ChangeHp(data_list.hp)
	end
end

function Scene:OnNotifyMpChange(data_list)
	local role = self:GetObjByUniqID(data_list.role_id)
	if role then
		role:SetMaxMp(data_list.mp_lim)
		role:ChangeMp(data_list.mp)
	end
end

function Scene:OnNotifyObjSkills(data_list)
	for i,v in ipairs(data_list.obj_skills) do
		self.scene_skill_list[v.obj_skill.id] = v.obj_skill
	end
end

function Scene:OnBcastObjDie(data_list)
	local obj = self:GetObjByUniqID(data_list.id)
	if obj and data_list.id ~= self:GetMainRoleID() then
		obj:DoDie()
		local marry_info = game.MarryCtrl.instance:GetMarryInfo()
		if marry_info and marry_info.mate_id == data_list.id then
			self:FireEvent(game.MarryEvent.MateDie, data_list.id)
		end
	end
end

function Scene:OnNotifyRoleDie(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		main_role:DoDie(data_list.killer_id, data_list.killer_name, data_list.die_time)
		if self.scene_logic then
			self.scene_logic:OnMainRoleDie(data_list)
		end

		local killer = self:GetObjByUniqID(data_list.killer_id)
		if killer and killer.obj_type == _obj_type.Role then
			self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, 1002, self:GetSceneName(), data_list.killer_name, data_list.killer_id)
		end
	end
end

function Scene:OnBcastRevive(data_list)
	local obj = self:GetObjByUniqID(data_list.obj_id)
	if obj then
		obj:DoRevive()
		obj:ChangeHp(data_list.hp)
		obj:SetMaxHp(data_list.hp_lim)
		obj:SetLogicPos(data_list.x, data_list.y)
	end
end

function Scene:OnNotifyRoleRevive(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		main_role:DoRevive()
		main_role.vo.attr = data_list.bt_attr
		main_role:ChangeHp(data_list.hp)
		main_role:ChangeMp(data_list.mp)
		main_role:SetLogicPos(data_list.x, data_list.y)
	end
end

function Scene:OnNotifyPetRevive(data_list)
	local obj = self:GetObjByUniqID(data_list.id)
	if obj then
		obj:SetMaxHp(data_list.hp_lim)
		obj:ChangeHp(data_list.hp)
		obj:DoRevive()
		obj:SetLogicPos(data_list.x, data_list.y)
	end
end

function Scene:OnBcastMoveSpeedChange(data_list)
	local obj = self:GetObjByUniqID(data_list.obj_id)
	if obj then
		obj:SetSpeed(data_list.move_speed)
	end
end

function Scene:OnBcastBuffChange(data_list)
	local obj = self:GetObjByUniqID(data_list.to_id)
	if obj then
		if data_list.change_type == 1 then
			obj:AddBuff(data_list.buff_aid, data_list.buff_id, data_list.buff_lv, data_list.buff_expire)
		else
			obj:DelBuff(data_list.buff_aid)
		end
	end
end

local get_mon_pos_proto = {
	mids = {}
}
function Scene:SendGetMonPosReq(mon_ids)
	for k,v in ipairs(mon_ids) do
		if not get_mon_pos_proto.mids[k] then
			get_mon_pos_proto.mids[k] = {}
		end
		get_mon_pos_proto.mids[k].mid = v
	end
	get_mon_pos_proto.mids[#mon_ids + 1] = nil

	self:SendProtocal(90204, get_mon_pos_proto)
end

function Scene:OnGetMonPosResp(data_list)
	local pos_list = data_list.pos_list
	local pos = pos_list[1]

	self.next_mon_pos_x = pos.x
	self.next_mon_pos_y = pos.y

	self:FireEvent(game.SceneEvent.OnGetMonPos, pos_list)
end

function Scene:GetNextMonPos()
	local x = self.next_mon_pos_x
	self.next_mon_pos_x = nil
	return x, self.next_mon_pos_y
end

function Scene:OnBcastRoleSceneAttr(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		main_role:SetMaxHp(data_list.hp_lim)
		main_role:SetMaxMp(data_list.mp_lim)
		main_role:ChangeHp(data_list.hp)
		main_role:ChangeMp(data_list.mp)
		main_role:SetSpeed(data_list.move_speed)
		main_role:ChangePkMode(data_list.mode)
		main_role:SetRealm(data_list.realm)
		main_role:SetTmpTitle(data_list.header)
	end
	self:FireEvent(game.SceneEvent.FixRoleAttr, data_list)
end

function Scene:OnNotifyPetLeave(data_list)
	local obj = self:GetObjByUniqID(data_list.pet_id)
	if obj then
		self:DeleteObj(obj.obj_id)
	end

	self:DelNewPetVo(data_list.pet_id)
end

function Scene:OnNotifyObjBasic(data_list)
	local role = self:GetObjByUniqID(data_list.obj_id)
	if role then
		role:SetMaxMp(data_list.mp_lim)
		role:ChangeMp(data_list.mp)
	end
end

function Scene:OnBcastCollectSt(data_list)
	local obj = self:GetObjByUniqID(data_list.coll_id)
	if obj then
		obj:SetState(data_list.stat)
		obj:SetRealm(data_list.realm)
	end
end

function Scene:OnBcastCollect(data_list)
	local role = self:GetObjByUniqID(data_list.role_id)
	if data_list.op == 1 then
		if role and not role:IsMainRole() then
			local obj_id = self:GetObjID(data_list.coll_id)
			if obj_id then
				role:GetOperateMgr():DoGoToGather(obj_id)
			end
		end
		if role and role:IsMainRole() then
			global.AudioMgr:PlaySound("qt002")
		end
	elseif data_list.op == 2 then
		if role and role:GetCurStateID() == game.ObjState.Gather then
			role:DoIdle()
			if role:IsMainRole() then
				global.AudioMgr:PlaySound("qt003")
			end
		end
	end
end

function Scene:OnBcastRoleInfoChange(data)
	local role = self:GetObjByUniqID(data.role_id)
	if role then
		role.vo.level = data.level
		role:ChangeHp(data.hp)
		role:SetMaxHp(data.hp_lim)
		role:SetSpeed(data.move_speed)

		if role:IsMainRole() then
			role.vo.combat_power = data.combat_power
			self:FireEvent(game.RoleEvent.UpdateRoleInfo, data)
		end
	end
end

local _del_role_pet_func = function(obj, role_id)
	if obj.obj_type == game.ObjType.Pet then
		if obj:GetOwnerID() == role_id then
			obj.scene:DeleteObj(obj.obj_id, true)
		end
	end
end

function Scene:OnBcastObjSpecState(data)
	local role = self:GetObjByUniqID(data.id)
	if role then
		role:SetSpecState(data.state, data.state_params)
		if data.state & 1 ~= 0 then
			role:GetOperateMgr():DoPractice()
		elseif data.state & 4 ~= 0 then
			self:ForeachObjs(_del_role_pet_func, role.uniq_id)
			self:DeleteObj(role.obj_id)
		elseif data.state & 8 ~= 0 then
			if role:IsMainRole() then
				role:SetClientObj(false)
			end
		else
			role:DoIdle()
			role:SetMountState(0, true)
		end
	end
end

function Scene:SendChangeSceneModeReq(mode)
	self:SendProtocal(90112, {scene_mode = mode})
end

function Scene:OnChangeSceneModeResp(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		main_role:ChangePkMode(data_list.scene_mode, data_list.next_mode, data_list.next_mode_cd)
	end
end

function Scene:SendSceneTransferReq(id)
	self:SendProtocal(90209, {door = id})
end

function Scene:OnBcastExteriorChange(data)
	local obj = self:GetObjByUniqID(data.role_id)
	if obj then
		obj:SetExteriorType(data.type, data.id, data.stat)
	end
end

function Scene:OnNotifyBtAttrChange(data_list)
	local vo = self:GetMainRoleVo()
	if vo then
		vo.attr = data_list.scene_bt_attr
		self:FireEvent(game.RoleEvent.UpdateRoleAttr)
	end
end

function Scene:OnNotifyBaseAttrChange(data_list)
	local vo = self:GetMainRoleVo()
	if vo then
		vo.base_attr = data_list.base_attr
		self:FireEvent(game.RoleEvent.UpdateRoleBaseAttr)
	end
end

function Scene:OnNotifyRivals(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		main_role:SetRivals(data_list.rival_ids)
	end
end

function Scene:OnNotifyAddRival(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		main_role:AddRival(data_list.rival_id)
	end
end

function Scene:OnNotifyDelRival(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		main_role:DelRival(data_list.rival_id)
	end
end

function Scene:OnBcastMurderousChange(data_list)
	local role = self:GetObjByUniqID(data_list.role_id)
	if role then
		role:ChangeMurderous(data_list.murderous)
	end
end

function Scene:OnLevelChange(data_list)
	local vo = self:GetMainRoleVo()
	if vo then		
		vo.exp = data_list.exp
		if data_list.level ~= vo.level then
			self:FireEvent(game.RoleEvent.LevelUpgrade, data_list)
			global.AudioMgr:PlaySound("qt004")
			vo.level = data_list.level
			local main_role = self:GetMainRole()
	        if main_role then
	            main_role:ShowLvupEffect()
	        end
	        game.SDKMgr:SendSDKData(4)
		end

		self:FireEvent(game.RoleEvent.LevelChange, data_list)
	end
end

function Scene:SendDeclearWarReq(id)
	self:SendProtocal(90114, {rival_id = id})
end

function Scene:OnNotifyBeDeclearWar(data_list)
	self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, 1008, data_list.name)
end

function Scene:OnTitleChange(data_list)
	local obj = self:GetObjByUniqID(data_list.role_id)
	if obj and (obj.obj_type == game.ObjType.Role or obj.obj_type == game.ObjType.MainRole) then
		obj:SetTitleInfo(data_list.title_extra, data_list.title_quality)
		obj:SetTitle(data_list.title)
	end
end

function Scene:OnTitleHeader(data_list)
	local obj = self:GetObjByUniqID(data_list.role_id)
	if obj and (obj.obj_type == game.ObjType.Role or obj.obj_type == game.ObjType.MainRole) then
		obj:SetTmpTitle(data_list.header)
	end
end

function Scene:OnHairChange(data_list)
	local obj = self:GetObjByUniqID(data_list.role_id)
	if obj and (obj.obj_type == game.ObjType.Role or obj.obj_type == game.ObjType.MainRole) then
		obj:SetHair(data_list.id)
	end
end

function Scene:OnTeamChange(data_list)
	local obj = self:GetObjByUniqID(data_list.role_id)
	if obj and (obj.obj_type == game.ObjType.Role or obj.obj_type == game.ObjType.MainRole) then
		obj:SetTeam(data_list.team_id)
	end
end

function Scene:OnNotifyClearSkillCd(data_list)
	local main_role = self:GetMainRole()
	if main_role then
		for i,v in ipairs(data_list.skill_ids) do
			main_role:ClearSkillCD(v.skill_id)
		end
	end
end

function Scene:OnFashionChange(data_list)
	local obj = self:GetObjByUniqID(data_list.role_id)
	if obj then
		obj:SetFashionID(data_list.id)
	end
end

function Scene:OnBcastArtifactChangeAvatar(data_list)
	local obj = self:GetObjByUniqID(data_list.role_id)
	if obj then
		obj:SetWeaponID(data_list.artifact)
	end
end

function Scene:OnBcastRoleChangeIcon(data_list)
	local obj = self:GetObjByUniqID(data_list.role_id)
	if obj then
		obj:SetIcon(data_list.icon)
	end
end

function Scene:OnBcastGuildInfoChange(data)
    local role = game.Scene.instance:GetObjByUniqID(data.role_id)
    if role then
        role:SetGuild(data.guild, data.guild_name)
    end
end

function Scene:OnNotifyAngerChange(data)
	self.scene_logic:OnNotifyAngerChange(data)
end

function Scene:OnNotifyWarriorSoulChangeAvatar(data)
	local role = game.Scene.instance:GetObjByUniqID(data.role_id)
    if role then
        role:SetWeaponSoulID(data.warrior_soul)
    end
end

function Scene:OnNotifyRoleNameChange(data)
	local role = game.Scene.instance:GetObjByUniqID(data.role_id)
	if role and (role.obj_type == game.ObjType.Role or role.obj_type == game.ObjType.MainRole) then
		role:SetName(data.name)
		role:RefreshName()
	end
end

function Scene:OnRolePlayAction(data)
	local role = game.Scene.instance:GetObjByUniqID(data.invited_id)
	local act_cfg = config.exterior_action[data.id]
	local x, y
	local dir
	if role then
		x, y = role:GetLogicPosXY()
		dir = role:GetDir()
		role:DoAction(act_cfg.anim, act_cfg.type, data.be_invited_id)
	end

	local partner = game.Scene.instance:GetObjByUniqID(data.be_invited_id)
	if partner then
		partner:SetLogicPos(x, y)
		partner:SetDirForce(dir.x, dir.y)
		partner:DoAction(act_cfg.invitee_anim, act_cfg.type, data.invited_id)
	end
end

function Scene:OnBcastTransformStat(data_list)
	local role = game.Scene.instance:GetObjByUniqID(data_list.role_id)
	if role then
		role:SetTranStat(data_list.tran_stat)
	end
end

function Scene:OnNotifyKillRole(data_list)
	self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, 1003, self:GetSceneName(), data_list.dead_name)
end

function Scene:OnBcastMonFirstAtt(data)
	local monster = game.Scene.instance:GetObjByUniqID(data.id)
	if monster then
		monster:SetFirstAtt(data.first_att)
	end
end

function Scene:OnMarryNotify(data_list)
	local role = game.Scene.instance:GetObjByUniqID(data_list.role_id)
	if role and (role.obj_type == game.ObjType.Role or role.obj_type == game.ObjType.MainRole) then
		role:SetMateInfo(data_list.mate_id, data_list.mate_name)
		if role:GetTitleID() == 8001 then
			role:RefreshTitle()
		end
	end
end