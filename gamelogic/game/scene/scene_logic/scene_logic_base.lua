
local SceneLogicBase = Class()

local _obj_type = game.ObjType
local _pk_state = game.PkState

local SceneStartFuncList = {}

function SceneLogicBase:_init(scene)
	self.scene = scene
end

function SceneLogicBase:_delete()

end

function SceneLogicBase:StartScene()
	self.main_role = self.scene:GetMainRole()

	self:OnStartScene()
	self:InitSceneLogicExit()
	self:InitSceneLogicDetail()
	self:InitSceneLogicTaskCom()
	self:InitDunAssist()
	self:DoSceneStartFuncs()
end

function SceneLogicBase:StopScene()

end

function SceneLogicBase:Update(now_time, elapse_time)

end

function SceneLogicBase:CreateMainRole(vo)
	local main_role = self.scene:_CreateMainRole(vo)
	main_role:SetAoiEnterListener(function(obj_id)
		
	end)

	main_role:SetAoiLeaveListener(function(obj_id)
		if obj_id == main_role:GetTargetID() then
			main_role:SelectTarget(nil)
		end
	end)

	if self:CanAutoHang() then
		main_role:SetDefaultOper(self:GetHangOperate())
	end

	return main_role
end

function SceneLogicBase:CreateMonster(vo)
	return self.scene:_CreateMonster(vo)
end

function SceneLogicBase:CreateGather(vo)
	return self.scene:_CreateGather(vo)
end

function SceneLogicBase:CreateRole(vo)
	return self.scene:_CreateRole(vo)
end

function SceneLogicBase:CreatePet(vo)
	local pet = self.scene:_CreatePet(vo)
	return pet
end

function SceneLogicBase:CreateNpc(vo)
	local npc = self.scene:_CreateNpc(vo)
	return npc
end

function SceneLogicBase:CreateJumpPoint(vo)
	local jump_point = self.scene:_CreateJumpPoint(vo)
	return jump_point
end

function SceneLogicBase:CreateDoor(vo)
	local door = self.scene:_CreateDoor(vo)
	return door
end

function SceneLogicBase:CreateCarry(vo)
	local carry = self.scene:_CreateCarry(vo)
	return carry
end

function SceneLogicBase:CreateFlyItem(vo)
	local flyitem = self.scene:_CreateFlyItem(vo)
	return flyitem
end

local pk_mode_func_map = {
	[game.PkMode.Peace] = function(attacker, target)
		if target:IsMonster() then
			return true
		else
			return false
		end
	end,
	[game.PkMode.Guild] = function(attacker, target)
		if target:IsMonster() then
			return true
		else
			if attacker:GetTeamID() ~= target:GetTeamID() or attacker:GetTeamID() == 0 then
				return attacker.vo.guild ~= target.vo.guild or attacker.vo.guild == 0
			else
				return false
			end
		end
	end,
	[game.PkMode.Team] = function(attacker, target)
		return attacker:GetTeamID() ~= target:GetTeamID() or attacker:GetTeamID() == 0
	end,
	[game.PkMode.Server] = function(attacker, target)
		if target:IsMonster() then
			return true
		else
			if attacker:GetTeamID() ~= target:GetTeamID() or attacker:GetTeamID() == 0 then
				return target.vo.server_num ~= attacker.vo.server_num
			else
				return false
			end
		end
	end,
	[game.PkMode.Justice] = function(attacker, target)
		if target:IsMonster() then
			return true
		else
			if attacker:GetTeamID() ~= target:GetTeamID() or attacker:GetTeamID() == 0 then
				return target:GetMurderous() > 0
			else
				return false
			end
		end
	end,
}

function SceneLogicBase:IsEnemy(attacker, target)
	if attacker.obj_type == _obj_type.Pet then
		attacker = attacker:GetOwner()
		if not attacker then
			return false
		end
	end
	if target.obj_type == _obj_type.Pet then
		target = target:GetOwner()
		if not target then
			return false
		end
	end

	if attacker.obj_id == target.obj_id then
		return false
	end

	if attacker:GetRealm() ~= target:GetRealm() then
		return true
	else
		if attacker:GetRealm() ~= 0 then
			return false
		end
	end

	if not target:IsMonster() then
		if attacker:IsTmpEnemy(target.uniq_id) then
			if attacker:GetTeamID() ~= target:GetTeamID() then
				return true
			end
		end
	end

	return pk_mode_func_map[attacker:GetPkMode()](attacker, target)
end

function SceneLogicBase:IsFriend(attacker, target)
	if attacker.obj_type == _obj_type.Pet then
		attacker = attacker:GetOwner()
		if not attacker then
			return false
		end
	end
	if target.obj_type == _obj_type.Pet then
		target = target:GetOwner()
		if not target then
			return false
		end
	end

	if attacker.obj_id == target.obj_id then
		return true
	end

	if attacker:IsTmpEnemy(target.uniq_id) then
		return false
	end

	if attacker:GetRealm() ~= target:GetRealm() then
		return false
	else
		if attacker:GetRealm() ~= 0 then
			return true
		end
	end

	if attacker:GetTeamID() ~= target:GetTeamID() then
		return false
	else
		if attacker:GetTeamID() ~= 0 then
			return true
		end
	end

	return false
end

function SceneLogicBase:IsSelfEnemy(target)
	return self:IsEnemy(self.main_role, target)
end

function SceneLogicBase:CanBeAttack(obj)
	return true
end

function SceneLogicBase:GetHangOperate()
    return game.OperateType.HangStay
end

function SceneLogicBase:CanAutoHang()
	return false
end

function SceneLogicBase:AddSceneStartFunc(func)
	if func then
		table.insert(SceneStartFuncList, func)
	end
end

function SceneLogicBase:DoSceneStartFuncs()
	
	for key, func in pairs(SceneStartFuncList) do
		func()
	end

	SceneStartFuncList = {}
end

local NormalSceneTypes = {
	[game.SceneType.NormalScene] = 1,
	[game.SceneType.OutSideScene] = 1,
	[game.SceneType.Hanging] = 1,
	[game.SceneType.Hanging_Tomb] = 1,
}

local ToNormalSceneTypes = {
	[game.SceneType.NormalScene] = 1,
	[game.SceneType.OutSideScene] = 1,
	[game.SceneType.Hanging] = 1,
	[game.SceneType.Hanging_Tomb] = 1,
	[game.SceneType.GuildScene] = 1,
	[game.SceneType.Special] = 1,
}

local GuildSceneTypes = {
	[game.SceneType.GuildScene] = 1,
}
function SceneLogicBase:CanChangeScene(scene_id, notice)
	local cur_scene_id = self.scene:GetSceneID()
	if cur_scene_id == scene_id then
		return true
	end

	local scene_cfg = config.scene[scene_id]
	if scene_cfg then
		local enter_lmt = scene_cfg.enter_lmt
		if enter_lmt[1][2] > self.main_role.vo.level then
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[2425])
			end
			return false
		end

		if NormalSceneTypes[scene_cfg.type] then
			local cur_scene_type = self.scene:GetSceneType()
			if not ToNormalSceneTypes[cur_scene_type] then
				if notice then
					game.GameMsgCtrl.instance:PushMsg(config.words[532])
				end
				return false
			end
		else
			if GuildSceneTypes[scene_cfg.type] then
				local cur_scene_type = self.scene:GetSceneType()
				if not NormalSceneTypes[cur_scene_type] then
					if notice then
						game.GameMsgCtrl.instance:PushMsg(config.words[6009])
					end
					return false
				end
				return true
			end
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[6009])
			end
			return false
		end
		
		if GuildSceneTypes[scene_cfg.type] then
			local guild_id = game.GuildCtrl.instance:GetGuildId() or 0
			if guild_id <= 0 then
				if notice then
					game.GameMsgCtrl.instance:PushMsg(config.words[533])
				end
				return false
			end
		end
	else
		return false
	end

	if self.main_role:IsRoleFightState() then
		if notice then
			game.GameMsgCtrl.instance:PushMsg(config.words[531])
		end
		return false
	end
	if self.main_role:GetCurStateID() == game.ObjState.Practice then
		if notice then
			game.GameMsgCtrl.instance:PushMsg(config.words[4769])
		end
		return false
	end
	if not game.RoleCtrl.instance:CanTransformChangeScene(self.main_role, true) then
		return false
	end
	return true
end

function SceneLogicBase:OnMainRoleDie(data_list)
	game.FightCtrl.instance:OpenReviveView(self.scene:GetSceneID(), data_list)
end

function SceneLogicBase:ReleaseObj(obj)
	
end

function SceneLogicBase:PlayMusic()
	self.scene:_PlayMusic()
end

function SceneLogicBase:CanDoGather(gather_obj)
	if gather_obj then
		local gather_id = gather_obj:GetGatherId()
		return game.TaskCtrl.instance:CanDoTaskGather(gather_id)
	end

	return true
end

function SceneLogicBase:OnStartScene()
	
end

function SceneLogicBase:InitSceneLogicExit()
	game.MainUICtrl.instance:SetShowBtnExit(self:IsShowLogicExit())
end

function SceneLogicBase:IsShowLogicExit()
	return false
end

function SceneLogicBase:DoSceneLogicExit()
	
end

function SceneLogicBase:InitSceneLogicDetail()
	game.MainUICtrl.instance:SetShowBtnDetail(self:IsShowLogicDetail())
end

function SceneLogicBase:IsShowLogicDetail()
	return false
end

function SceneLogicBase:DoSceneLogicDetail()
	
end

function SceneLogicBase:InitSceneLogicTaskCom()
	game.MainUICtrl.instance:SetShowTaskCom(self:IsShowLogicTaskCom())
end

function SceneLogicBase:IsShowLogicTaskCom()
	return false
end

function SceneLogicBase:CanDoCrossOperate()
	local cross_oper_info = self.scene:GetCrossOperInfo()
	if cross_oper_info and cross_oper_info.oper_type==game.OperateType.MakeTeamFollow then
		return false
	end
	return true
end

function SceneLogicBase:CreateWeaponSoul(vo)
	local weapon_soul = self.scene:_CreateWeaponSoul(vo)
	return weapon_soul
end

function SceneLogicBase:OnNotifyAngerChange(data)
	self.main_role:OnNotifyAngerChange(data)
end

function SceneLogicBase:InitDunAssist()
	game.MainUICtrl.instance:SetDunAssistEnable(self:IsDunAssistEnable())
end

function SceneLogicBase:IsDunAssistEnable()
	local scene_type = self.scene:GetSceneType()
	return (game.NoDunAssistSceneType[scene_type]==nil)
end

function SceneLogicBase:SetFirstAtt(obj, first_att)
	if obj:IsMonster() then
		if first_att == 0 then
			obj:SetOwnerType(game.OwnerType.None)
		elseif first_att == game.Scene.instance:GetMainRoleID() or game.MakeTeamCtrl.instance:IsTeamMember(first_att) then
			obj:SetOwnerType(game.OwnerType.Self)
		else
			obj:SetOwnerType(game.OwnerType.Others)
		end
	end
end

return SceneLogicBase
