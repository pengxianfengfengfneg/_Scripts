local Character = Class(require("game/character/obj"))

local _obj_state = game.ObjState
local _obj_type = game.ObjType
local _global_time = global.Time
local _drop_blood_ctrl = game.DropBloodCtrl
local _event_mgr = global.EventMgr
local _effect_mgr = game.EffectMgr
local _config_skill = config.skill
local _combo_time = config.custom.combo_time

local ConfigHelpSkill = config_help.ConfigHelpSkill

local ObjStateAnimMap = {
	[game.ObjState.Idle] = game.ObjAnimName.Idle,
	[game.ObjState.Move] = game.ObjAnimName.Run,
	[game.ObjState.Die] = game.ObjAnimName.Die,
	[game.ObjState.Beattack] = game.ObjAnimName.Beattack,
	[game.ObjState.Gather] = game.ObjAnimName.Gather,
	[game.ObjState.Jump] = game.ObjAnimName.Run,
	[game.ObjState.Practice] = game.ObjAnimName.Practice,
	[game.ObjState.ChangeScene] = game.ObjAnimName.ChangeScene,
	[game.ObjState.CallPet] = game.ObjAnimName.Gather,
	[game.ObjState.SeatMove] = game.ObjAnimName.RideIdle8,
}

function Character:_init()
	self.aoi_range = 15
	self.next_beattack_effect_time = 0
end

function Character:_delete()
	if self.state_machine then
		self.state_machine:DeleteMe()
		self.state_machine = nil
	end
end

function Character:Init(scene)
	self.is_dead = false
	self.real_dead = false
	self.mute_move = 0
	self.mute_attack = 0
	self.mute_skill = 0
	self.buff_blind = 0
	self.hide_buff = 0
	self.immune_harm = 0
	self.mute_beattack = 0
	self.move_attack_end_time = 0
	self.last_skill_time = 0
	self.search_enemy_priority = 0

	self:InitStatMachine()

	Character.super.Init(self, scene)
end

function Character:Reset()
	self.next_skill_id = nil
	self.skill_list = nil 
	self.combo_skill_list = nil
	self.priority_skill_list = nil
	self.search_enemy_priority = 0
	self:ClearAllBuff()

	if self.state_machine then
		self.state_machine:QuitCurState()
	end

	if self.oper_mgr then
		self.oper_mgr:DeleteMe()
		self.oper_mgr = nil
	end

	Character.super.Reset(self)
end

function Character:CheckUpdate(now_time, elapse_time)
	self:UpdateStateMachine(now_time, elapse_time)
	self:UpdateOperate(now_time, elapse_time)
	self:UpdateModel()
	
	self.cur_update_cd = elapse_time + self.cur_update_cd
	if self.cur_update_cd >= self.update_cd then
		self:Update(now_time, self.cur_update_cd)
		self:UpdateMoveAttack(now_time, elapse_time)
		self.cur_update_cd = 0
	end
end

function Character:Update(now_time, elapse_time)
	self:UpdateBuff(now_time, elapse_time)
	Character.super.Update(self, now_time, elapse_time)
end

-- 属性相关
function Character:GetVo()
	return self.vo
end

function Character:SetSpeed(val)
	self.vo.move_speed = val
end

function Character:GetSpeed()
	return self.vo.move_speed / 24
end

function Character:ChangeHp(hp)
	self.vo.hp = hp

    if self.is_selected then
    	_event_mgr:Fire(game.SceneEvent.TargetHpChange, self:GetHpPercent(), self:GetObjType(), self.uniq_id)
    end
end

function Character:GetHp()
	return self.vo.hp
end

function Character:SetMaxHp(hp)
	self.vo.hp_lim = hp
end

function Character:GetMaxHp()
	return self.vo.hp_lim
end

function Character:SetMaxMp(mp)
	self.vo.mp_lim = mp
end

function Character:ChangeMp(mp)
	self.vo.mp = mp

	if self.is_selected then
    	_event_mgr:Fire(game.SceneEvent.TargetMpChange, self:GetMpPercent())
    end
end

function Character:GetMaxMp()
	return self.vo.mp_lim or 100
end

function Character:GetMp()
	return self.vo.mp or 0
end

function Character:GetHpPercent()
	return self:GetHp() / self:GetMaxHp()
end

function Character:GetMpPercent()
	return self:GetMp() / self:GetMaxMp()
end

function Character:IsDead()
    return self.is_dead
end

function Character:GetAttackType()
	return 1
end

function Character:SetMountState(mode, server_change)

end

function Character:SetSpecState(state, state_params)
	self.vo.state = state
	self.vo.state_params = state_params
end

-- 状态相关
function Character:InitStatMachine()
	if not self.state_machine then
		self.state_machine = global.StateMachine.New()
		self.state_machine:AddState(_obj_state.Idle, require("game/character/states/idle_state").New(self))
		self.state_machine:AddState(_obj_state.Move, require("game/character/states/move_state").New(self))
		self.state_machine:AddState(_obj_state.Die, require("game/character/states/die_state").New(self))
		self.state_machine:AddState(_obj_state.PreAttack, require("game/character/states/pre_attack_state").New(self))
		self.state_machine:AddState(_obj_state.Attack, require("game/character/states/attack_state").New(self))
		self.state_machine:AddState(_obj_state.Beattack, require("game/character/states/beattack_state").New(self))
		self.state_machine:AddState(_obj_state.Gather, require("game/character/states/gather_state").New(self))
		self.state_machine:AddState(_obj_state.Jump, require("game/character/states/jump_state").New(self))
		self.state_machine:AddState(_obj_state.Practice, require("game/character/states/practice_state").New(self))
		self.state_machine:AddState(_obj_state.ChangeScene, require("game/character/states/change_scene_state").New(self))
		self.state_machine:AddState(_obj_state.CallPet, require("game/character/states/call_pet_state").New(self))
		self.state_machine:AddState(_obj_state.PlayAction, require("game/character/states/play_action_state").New(self))
		self.state_machine:AddState(_obj_state.SeatMove, require("game/character/states/seat_move_state").New(self))
		return true
	end
end

function Character:GetCurStateID()
	if self.state_machine then
		return self.state_machine:GetCurStateID()
	end
end

function Character:CanDoIdle()
	if self.is_dead then
		return false
	end

	local state_id = self:GetCurStateID()
	return state_id ~= _obj_state.Practice and state_id ~= _obj_state.Attack
end

function Character:CanDoGather()
	if self:IsMoveAttack() then
		return false
	end

	local state_id = self:GetCurStateID()
	if state_id == _obj_state.Idle 
		or state_id == _obj_state.Move
		or state_id == _obj_state.Beattack then
		return true
	end
	return false
end

function Character:CanDoMove(notice)
	if self.mute_move > 0 then
		if notice then
			game.GameMsgCtrl.instance:PushMsg(config.words[521])
		end
		return false
	end

	if self:IsMoveAttack() then
		return true
	end

	local state_id = self:GetCurStateID()
	if state_id == _obj_state.Idle 
        or state_id == _obj_state.Move 
        or state_id == _obj_state.Beattack 
        or state_id == _obj_state.Gather
        or state_id == _obj_state.CallPet
        or state_id == _obj_state.PlayAction
        or state_id == _obj_state.ChangeScene
        or (state_id == _obj_state.Attack and self.attack_can_break)
        or (state_id == _obj_state.PreAttack and self.attack_can_break) then
        return true
	end
end

function Character:CanDoJump()
	local state_id = self:GetCurStateID()
	if state_id == _obj_state.Idle or
		state_id == _obj_state.Move then
        return true
	end
end

function Character:CanDoAttack(skill_id, notice)
	if self.mute_attack > 0 and not self:IsClientObj() then
		if notice then
			game.GameMsgCtrl.instance:PushMsg(config.words[520])
		end
		return false
	end

	if self:IsMoveAttack() then
		return false
	end

	local state_id = self:GetCurStateID()
	if state_id == _obj_state.Idle 
		or state_id == _obj_state.Move
		or state_id == _obj_state.Beattack
		or state_id == _obj_state.Gather
		or state_id == _obj_state.CallPet
		or state_id == _obj_state.ChangeScene then
		if skill_id and self.skill_list then
			return self:CanPlaySkill(skill_id, notice)
		else
			return true
		end
	end

	return false
end

function Character:CanDoBeattack()
	if self.mute_beattack > 0 then
		return false
	end

	if self:IsMoveAttack() then
		return false
	end

	local state_id = self:GetCurStateID()
	if state_id == _obj_state.Idle then
		return true
	end
	return false
end

function Character:DoIdle(is_empty)
	self.state_machine:ChangeState(_obj_state.Idle, is_empty)
end

function Character:DoMove(x, y, keep_move, dir_x, dir_y)
	self.state_machine:ChangeState(_obj_state.Move, x, y, keep_move, dir_x, dir_y)
end

function Character:DoJump(x, y, fx, fy, mid_list)
	return self.state_machine:ChangeState(_obj_state.Jump, x, y, fx, fy, mid_list)
end

function Character:DoChagneScene(scene_id, change_func, line_id, is_follow)
	return self.state_machine:ChangeState(_obj_state.ChangeScene, scene_id, change_func, line_id, is_follow)
end

function Character:DoDie()
    self.is_dead = true
	self.state_machine:ChangeState(_obj_state.Die)
end

function Character:DoGather(target_id)
	self.state_machine:ChangeState(_obj_state.Gather, target_id)
end

function Character:DoPractice()
	self.state_machine:ChangeState(_obj_state.Practice)
end

function Character:DoRevive()
	self.is_dead = false
	self:DoIdle()
end

function Character:DoPreAttack(skill_id, skill_lv, target)
	self.state_machine:ChangeState(_obj_state.PreAttack, skill_id, skill_lv, target)
end

function Character:DoAttack(skill_id, skill_lv, target, hero_id, legend, avoid_pre_time, assist_x, assist_y)
	local skill_info
	local cfg = ConfigHelpSkill.GetSkillInfo(skill_id, skill_lv, hero_id, legend)
	self.attack_can_break = (cfg.is_break == 1)
	if self.skill_list then
	    skill_info = self.skill_list[skill_id]
		self.last_skill_id = skill_id
		self.last_skill_time = global.Time.now_time
		-- self.last_skill_enemy = skill_info.is_enemy_skill
	end
	if cfg.pre_time == 0 or avoid_pre_time then
		if skill_info then
	    	skill_info.next_play_time = skill_info.cd + global.Time.now_time + 0.2
	    end
		self.state_machine:ChangeState(_obj_state.Attack, skill_id, skill_lv, target, hero_id, legend, assist_x, assist_y)
	else
		self.state_machine:ChangeState(_obj_state.PreAttack, skill_id, skill_lv, target, hero_id, legend, assist_x, assist_y)
	end
end

function Character:DoBeattack(attacker, skill_id, skill_lv, defer_info, hero_id, legend)
	local cfg = ConfigHelpSkill.GetSkillInfo(skill_id, skill_lv, hero_id, legend)
	if cfg then
		local to_obj = cfg.to_obj
		if self:GetHp() > defer_info.defer_hp then
			if to_obj ~= 1 and to_obj ~= 6 and to_obj ~= 7 then
				if self:CanDoBeattack() then
					self.state_machine:ChangeState(_obj_state.Beattack, attacker, skill_id, skill_lv)
				end
			end
		end

		if self:CanPlayBeattackEffect(attacker) then
			if #cfg.be_attack_effect > 0 then
				local be_att_cfg = cfg.be_attack_effect
				local now_time = global.Time.now_time
				if now_time > self.next_beattack_effect_time and (self.beattack_effect_name ~= be_att_cfg[2] or now_time > self.next_beattack_effect_time + 2) then
					self.next_beattack_effect_time = now_time + 0.2
					self.beattack_effect_name = be_att_cfg[2]
					if be_att_cfg[1] == 1 then
		                local eff_path = string.format("effect/skill/%s.ab", be_att_cfg[2])
		                local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj_id, 2)
		                effect:SetParent(self:GetRoot())
		    			effect:SetPosition(0, self:GetModelHeight() * 0.5, 0)
		            elseif be_att_cfg[1] == 2 then
		                local eff_path = string.format("effect/skill/%s.ab", be_att_cfg[2])
		                local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj_id, 2)
		                game.RenderUnit:AddToObjLayer(effect:GetRoot())
		    			effect:SetPosition(self.unit_pos.x, self:GetMapHeight(), self.unit_pos.y)
		            elseif be_att_cfg[1] == 3 then
		                local eff_path = string.format("effect/skill/%s.ab", be_att_cfg[2])
		                local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj_id, 2)
		                effect:SetParent(self:GetRoot())
		    		end
				end
			end
		end
	end
end

function Character:CanPlayBlood()
	return self.hide_buff == 0
end

function Character:PlayStateAnim()
	local id = self:GetCurStateID()
	local anim = ObjStateAnimMap[id]
	if anim then
		self:PlayAnim(anim)
	end
end

function Character:SetMoveAttack(val)
	self.move_attack_end_time = val
end

function Character:IsMoveAttack()
	return self.move_attack_end_time ~= 0
end

function Character:UpdateMoveAttack(now_time, elapse_time)
	if self.move_attack_end_time > 0 and now_time > self.move_attack_end_time then
		self.move_attack_end_time = 0
		_effect_mgr.instance:ClearEffectByTag(self.obj_id)
	end
end

function Character:IsInAttackState()
	return (_global_time.now_time < self.last_skill_time + 2) or self:IsMoveAttack()
end

-- operate
function Character:GetOperateMgr()
	if not self.oper_mgr then
		self.oper_mgr = require("game/operate/operate_mgr").New(self)
	end
	return self.oper_mgr
end

function Character:UpdateOperate(now_time, elapse_time)
	if self.oper_mgr then
		self.oper_mgr:Update(now_time, elapse_time)
	end
end

function Character:ClearOperate()
	if self.oper_mgr then
		self.oper_mgr:ClearOperate()
	end
end

function Character:SetPauseOperate(val)
	if self.oper_mgr then
		self.oper_mgr:SetPause(val)
	end
end

-- attack
function Character:CanBeAttack()
	return self.scene.scene_logic:CanBeAttack(self)
end

function Character:IsEnemy(obj)
	return self.scene.scene_logic:IsEnemy(self, obj)
end

function Character:IsFriend(obj)
	return self.scene.scene_logic:IsFriend(self, obj)
end

function Character:CanAttackObj(obj)
	return obj and obj:CanBeAttack() and not obj:IsDead() and self:IsEnemy(obj) and obj.hide_buff == 0
end

local _pGetManhattanDistance = cc.pGetManhattanDistance
local SearchEnemyResult = {}
local SearchEnemyFunc = function(obj, me, fliter_func)
	if me:CanAttackObj(obj) then
		if not fliter_func or fliter_func(obj) then
			local tmp_dist = _pGetManhattanDistance(obj.logic_pos, me.logic_pos)
			if tmp_dist < me.aoi_range then
				if obj:IsBoss() then
					if tmp_dist < SearchEnemyResult.target_boss_dist then
						SearchEnemyResult.target_boss = obj
						SearchEnemyResult.target_boss_dist = tmp_dist
					end
				else
					if obj:IsMonster() then
						if tmp_dist < SearchEnemyResult.target_monster_dist then
							SearchEnemyResult.target_monster = obj
							SearchEnemyResult.target_monster_dist = tmp_dist
						end
					end
				end

				if obj:IsRole() then
					if tmp_dist < SearchEnemyResult.target_role_dist then
						SearchEnemyResult.target_role = obj
						SearchEnemyResult.target_role_dist = tmp_dist
					end
				end

				if tmp_dist < SearchEnemyResult.dist then
					SearchEnemyResult.target = obj
					SearchEnemyResult.dist = tmp_dist
				end
			end
		end
	end
end

function Character:SearchEnemy()
	SearchEnemyResult.target = nil
	SearchEnemyResult.target_boss = nil
	SearchEnemyResult.target_monster = nil
	SearchEnemyResult.target_role = nil
	SearchEnemyResult.dist = 10000000
	SearchEnemyResult.target_boss_dist = SearchEnemyResult.dist
	SearchEnemyResult.target_monster_dist = SearchEnemyResult.dist
	SearchEnemyResult.target_role_dist = SearchEnemyResult.dist
	self.scene:ForeachObjs(SearchEnemyFunc, self, self.search_fliter_func)

	local target = SearchEnemyResult.target
	local search_enemy_priority = self:GetSearchEnemyPriority()
	if search_enemy_priority == 1 then
		-- 小怪优先
		target = SearchEnemyResult.target_monster or target
	elseif search_enemy_priority == 2 then
		-- boss优先
		target = SearchEnemyResult.target_boss or target
	elseif search_enemy_priority == 3 then
		-- 敌对玩家优先
		target = SearchEnemyResult.target_role or target
	end

	return target
end

local CheckEnemyFunc = function(obj, me)
	local tmp_dist = _pGetManhattanDistance(obj.logic_pos, me.logic_pos)
	if tmp_dist < me.aoi_range then
		if me:CanAttackObj(obj) then
			return true
		end
	end
end
function Character:HasEnemy()
	return self.scene:FindObjs(CheckEnemyFunc, self)
end

function Character:SetSearchFliterFunc(fliter_func)
	self.search_fliter_func = fliter_func
end

function Character:SetSearchEnemyPriority(val)
	self.search_enemy_priority = val or 0
end

function Character:GetSearchEnemyPriority()
	return self.search_enemy_priority or 0
end

function Character:SelectTarget(obj)
	if obj then
		self.target_obj_id = obj.obj_id
	else
		self.target_obj_id = nil
	end
end

function Character:GetTargetID()
	return self.target_obj_id
end

function Character:GetTarget()
	if self.target_obj_id then
		return self.scene:GetObj(self.target_obj_id)
	end
end

function Character:GetAttackDist()
	return 4
end

function Character:GetOwnerID()
	return 0
end

-- buff相关
local _effect_func_map = {
	[5] = {
		-- 眩晕
		add_func = function(obj)
			obj.mute_attack = obj.mute_attack + 1
			obj.mute_move = obj.mute_move + 1
			if obj:GetCurStateID() == _obj_state.Move then
				local x, y = obj:GetLogicPosXY()
				obj:DoIdle()
				obj:SetLogicPos(x, y)
			elseif obj:GetCurStateID() == _obj_state.Attack or obj:GetCurStateID() == _obj_state.PreAttack then
				local x, y = obj:GetLogicPosXY()
				obj:DoIdle()
				obj:SetLogicPos(x, y)
			end
		end, 
		del_func = function(obj)
			obj.mute_attack = obj.mute_attack - 1
			obj.mute_move = obj.mute_move - 1
		end,
	},
	[6] = {
		-- 散攻
		add_func = function(obj)
			obj.mute_skill = obj.mute_skill + 1
			if obj:GetCurStateID() == _obj_state.Attack or obj:GetCurStateID() == _obj_state.PreAttack then
				local x, y = obj:GetLogicPosXY()
				obj:DoIdle()
				obj:SetLogicPos(x, y)
			end
		end, 
		del_func = function(obj)
			obj.mute_skill = obj.mute_skill - 1
		end,
	},
	[7] = {
		-- 定身
		add_func = function(obj)
			obj.mute_move = obj.mute_move + 1
			if obj:GetCurStateID() == _obj_state.Move then
				local x, y = obj:GetLogicPosXY()
				obj:DoIdle()
				obj:SetLogicPos(x, y)
			end
		end, 
		del_func = function(obj)
			obj.mute_move = obj.mute_move - 1
		end,
	},
	[8] = {
		-- 冰冻
		add_func = function(obj)
			obj.mute_attack = obj.mute_attack + 1
			obj.mute_move = obj.mute_move + 1
			if obj:GetCurStateID() == _obj_state.Move then
				local x, y = obj:GetLogicPosXY()
				obj:DoIdle()
				obj:SetLogicPos(x, y)
			elseif obj:GetCurStateID() == _obj_state.Attack or obj:GetCurStateID() == _obj_state.PreAttack then
				local x, y = obj:GetLogicPosXY()
				obj:DoIdle()
				obj:SetLogicPos(x, y)
			end
		end, 
		del_func = function(obj)
			obj.mute_attack = obj.mute_attack - 1
			obj.mute_move = obj.mute_move - 1
		end,
	},
	[9] = {
		-- 失明
		add_func = function(obj)
			obj.mute_attack = obj.mute_attack + 1
			obj.mute_move = obj.mute_move + 1
			obj.buff_blind = obj.buff_blind + 1
		end, 
		del_func = function(obj)
			obj.mute_attack = obj.mute_attack - 1
			obj.mute_move = obj.mute_move - 1
			obj.buff_blind = obj.buff_blind - 1
			if obj.buff_blind <= 0 and obj:IsClientObj() then
				obj:DoIdle()
			end
		end,
	},
	[15] = {
		-- 神佑
		add_func = function(obj)
			obj.mute_attack = obj.mute_attack + 1
			obj.mute_beattack = obj.mute_beattack + 1
		end, 
		del_func = function(obj)
			obj.mute_attack = obj.mute_attack - 1
			obj.mute_beattack = obj.mute_beattack - 1
		end,
	},
	[16] = {
		-- 隐身
		add_func = function(obj)
			obj.hide_buff = obj.hide_buff + 1
			if obj.hide_buff == 1 then
				local main_role = obj.scene:GetMainRole()
				if obj.uniq_id == obj.scene:GetMainRoleID() or (main_role and main_role:GetTeamID() == obj:GetTeamID() and obj:GetTeamID() ~= 0) then
					obj.hide_status = 1
					obj.draw_obj:SetMatEffect(game.MaterialEffect.Transparent, true)
				else
					obj.hide_status = 2
					obj:ShowHud(false)
					obj:SetVisible(false)

					local main_role = obj.scene:GetMainRole()
					if main_role and main_role:GetTargetID() == obj.obj_id then
						main_role:SelectTarget()
					end
				end
			end
		end, 
		del_func = function(obj)
			obj.hide_buff = obj.hide_buff - 1
			if obj.hide_buff == 0 then
				if obj.hide_status == 1 then
					obj.draw_obj:SetMatEffect(game.MaterialEffect.Transparent, false)
				else
					obj:ShowHud(true)
					obj:SetVisible(true)
				end
			end
		end,
	},
	[25] = {
		-- 不屈
		add_func = function(obj)
			obj.immune_harm = obj.immune_harm + 1
		end, 
		del_func = function(obj)
			obj.immune_harm = obj.immune_harm - 1
		end,
	},
}

local config_effect = config.effect
function Character:InitBuffList()
	if self.vo.buffs then
		for i,v in ipairs(self.vo.buffs) do
			self:AddBuff(v.aid, v.id, v.lv, v.expire)
		end
	end
end

function Character:GetBuffList()
	return self.buff_list
end

function Character:AddBuff(uid, id, lv, time)
	if not self.buff_list then
		self.buff_list = {}
	end

	local info = self.buff_list[uid]
	if not info then
		info = {
			uid = uid,
			id = id,
			lv = lv,
			end_time = 0,
			is_new = true
		}
		self.buff_list[uid] = info

		local cfg = config_effect[id]
		if cfg and cfg[lv] then
			cfg = cfg[lv]
			info.func_cfg = _effect_func_map[cfg.kind]
			if info.func_cfg then
				info.func_cfg.add_func(self)
			end

			if self:CanPlayBuffEffect() then
				if cfg.sp_effect ~= "" then
					local effect_path = string.format("effect/skill/%s.ab", cfg.sp_effect)
					local effect = game.EffectMgr.instance:CreateObjEffect(effect_path, self.obj_id, 3)
					effect:SetLoop(true)
					effect:SetParent(self:GetRoot())
					if cfg.sp_effect_type == 2 then
	                	effect:SetPosition(0, self:GetModelHeight() * 0.5, 0)
					elseif cfg.sp_effect_type == 3 then
	                	effect:SetPosition(0, self:GetModelHeight() + 0.2, 0)
					end
					info.effect_id = effect:GetID()
				end
			end
		end
	else
		info.is_new = false
	end

	info.end_time = time

	if self.is_selected then
		_event_mgr:Fire(game.SceneEvent.MainRoleTargetAddBuff, info)
	end

	return info
end

function Character:DelBuff(uid)
	if self.buff_list then
		local info = self.buff_list[uid]
		if info then
			self:_DelBuff(info)
			self.buff_list[uid] = nil

			if self.is_selected then
				_event_mgr:Fire(game.SceneEvent.MainRoleTargetDelBuff, uid)
			end
		end
	end
end

function Character:_DelBuff(info)
	if info.effect_id then
		game.EffectMgr.instance:StopEffectByID(info.effect_id)
		info.effect_id = nil
	end

	if info.func_cfg then
		info.func_cfg.del_func(self)
		info.func_cfg = nil
	end
end

function Character:ClearAllBuff()
	if self.buff_list then
		for i,v in pairs(self.buff_list) do
			self:_DelBuff(v)
		end
		self.buff_list = nil
	end
end

-- skill
function Character:InitSkillInfo(sk_list, cd_list)
	if not sk_list then
		return
	end

    self.skill_list = {}
	self.combo_skill_list = {}
    self.priority_skill_list = {}

    for i,v in ipairs(sk_list) do
    	self:InitSkill(v.id, v.lv, v.hero, v.legend, true)
    end

	if cd_list then
		local info
	    local server_time = global.Time:GetServerTime()
	    local now_time = global.Time.now_time
	    for i,v in ipairs(cd_list) do
	    	info = self.skill_list[v.id]
	    	if info then
	    		info.next_play_time = math.ceil(v.cd * 0.001) - server_time + now_time 
	    	end
	    end
	end

    table.sort(self.combo_skill_list, function(a, b)
    	return a < b
    end)

    table.sort(self.priority_skill_list, function(a, b)
    	return a.priority > b.priority
    end)
end

function Character:InitSkill(id, lv, hero_id, legend, is_init)
	local is_new = false
	local cfg = _config_skill[id]
	if lv > 0 and cfg and cfg[lv] then
    	local skill_cfg = ConfigHelpSkill.GetSkillInfo(id, lv, hero_id, legend)
		local skill_type = skill_cfg.type
		if skill_type == game.SkillType.Normal 
			or skill_type == game.SkillType.Active
			or skill_type == game.SkillType.PetPassive then
			local info = self.skill_list[id]
			if not info then
				info = {}
    			info.next_play_time = 0
				self.skill_list[id] = info
				is_new = true
			end

			local cd = skill_cfg.cd
			local mp = skill_cfg.mp
			local dist = skill_cfg.dist
			local condition = skill_cfg.condition
			local to_obj = skill_cfg.to_obj
			local to_obj_client = skill_cfg.to_obj_client

    		info.id = id
    		info.lv = lv
    		info.cd = cd * 0.001 + 0.2
    		info.mp = mp
    		info.anger = skill_cfg.anger or 0
    		info.dist = dist
    		info.is_normal = skill_type == game.SkillType.Normal
    		info.type = skill_type
    		info.condition = condition
    		info.to_obj = to_obj
    		info.is_enemy_skill = to_obj ~= 1 and to_obj ~= 6 and to_obj ~= 7
    		info.enabled = true
    		info.hero_id = hero_id
    		info.legend = legend
    		info.to_obj_client = to_obj_client
    		info.ignore_mute = skill_cfg.category == 10
    		info.auto_release = skill_cfg.auto_release == 1
    		info.fly_icon = skill_cfg.fly_icon
    		info.is_manual_skill = skill_cfg.child_category == 1

    		if is_new then
	    		if info.is_normal then
		    		table.insert(self.combo_skill_list, id)
	    		else
	    			table.insert(self.priority_skill_list, {id = id, priority = skill_cfg.priority})
	    		end
	    	end
		end
	end

	if is_new and not is_init then
	    table.sort(self.priority_skill_list, function(a, b)
	    	return a.priority > b.priority
	    end)
	end
end

function Character:GetSkillInfo(id)
	return self.skill_list[id]
end

function Character:SetSkillEnabled(id, enabled)
	local info = self.skill_list[id]
	if info then
		info.enabled = enabled
	end
end

function Character:GetSkillList()
	return self.skill_list
end

function Character:SetNextSkill(id)
	self.next_skill_id = id
end

function Character:ClearSkillCD(id)
	local skill_info = self:GetSkillInfo(id)
	if skill_info then
		skill_info.next_play_time = 0
	end
end

function Character:GetNextSkill(with_active)
	if not self.skill_list then
		return
	end

    local now_time = global.Time.now_time
	if self.next_skill_id then
		local skill_info = self.skill_list[self.next_skill_id]
		if skill_info and self.mute_skill == 0 then
			self.next_skill_id = nil
			if self:_CanPlaySkill(skill_info, now_time) then
				return skill_info.id, skill_info.lv, skill_info.is_enemy_skill, nil, skill_info.hero_id, skill_info.legend
			end
		end
	end

	if with_active and self.mute_skill == 0 then
		local ret, target, info
		for k,j in ipairs(self.priority_skill_list) do
			info = self.skill_list[j.id]
			if info and info.enabled and info.auto_release and self:_CanPlaySkill(info, now_time) then
				ret, target = self:_CheckSkillCondition(info)
				if ret then
					return info.id, info.lv, info.is_enemy_skill, target, info.hero_id, info.legend
				end
			end
		end
	end

	local skill_id = self.combo_skill_list[1]
	if self.last_skill_id and now_time < self.last_skill_time + _combo_time then
		if self.skill_list[self.last_skill_id] then
			for i,v in ipairs(self.combo_skill_list) do
				if v == self.last_skill_id then
					skill_id = self.combo_skill_list[i % #self.combo_skill_list + 1]
					break
				end
			end
		end
	end

	local info = self.skill_list[skill_id]
	if info and info.enabled then
		return info.id, info.lv, info.is_enemy_skill, nil, info.hero_id, info.legend
	end
end

local _math_random = math.random
local _check_condition = {
	[1] = function(obj, condition)
		return _math_random(10000) < condition[2]
	end,
	[2] = function(obj, condition)
		if obj:GetTeamID() == 0 or not obj:IsMainRole() then
			if not obj:IsDead() and obj:GetHpPercent() < condition[2] then
				return true, obj
			end
		else
			local team_mems = game.MakeTeamCtrl.instance:GetTeamMembers()
			local mem, min_hp, min_obj
			for k,v in pairs(team_mems) do
				mem = obj.scene:GetObjByUniqID(v.member.id)
				if mem and not mem:IsDead() and mem:GetHpPercent() < condition[2] and not obj:IsEnemy(mem) then
					if not min_hp or mem:GetHpPercent() < min_hp then
						min_hp = mem:GetHpPercent()
						min_obj = mem
					end
				end
			end

			if min_obj then
				return true, min_obj
			else
				return false
			end
		end
	end,
	[3] = function(obj, condition)
		local owner = obj:GetOwner()
		if owner then
			if not owner:IsDead() and owner:GetHpPercent() < condition[2] then
				return true, owner
			end
		end
		return false
	end,
	[4] = function(obj, condition)
		local owner = obj:GetOwner()
		if owner then
			if not owner:IsDead() and owner:GetMpPercent() < condition[2] then
				return true, owner
			end
		end
		return false
	end,
}

function Character:_CanPlaySkill(skill_info, now_time, notice)
	if skill_info then
		if (self.mute_attack > 0 or (self.mute_skill > 0 and not skill_info.is_normal)) and not skill_info.ignore_mute then
			if notice then
				game.GameMsgCtrl.instance:PushMsg(config.words[520])
			end
			return false
		end 
		if now_time > skill_info.next_play_time then
			return true
		end
	end
end

function Character:_CheckSkillCondition(skill_info)
	if not skill_info.condition or #skill_info.condition == 0 then
		return true
	end
	return _check_condition[skill_info.condition[1]](self, skill_info.condition)
end

local _tmp_friend_info = {}
local _get_friend_func = function(target, obj)
	if target:CanBeAttack() and not target:IsDead() and not target:IsMonster() and not obj:IsEnemy(target) then
		if _tmp_friend_info.hp < target:GetHpPercent() then
			_tmp_friend_info.hp = target:GetHpPercent()
			_tmp_friend_info.obj = target
		end
	end
end
function Character:_GetSkillTarget(skill_info)
	if skill_info then
		if skill_info.to_obj == 1 then
			return self
		elseif skill_info.to_obj == 6 then
			local target_obj = self:GetTarget()
			if target_obj and target_obj:CanBeAttack() and not target_obj:IsDead() and not self:IsEnemy(target_obj) and not target_obj:IsMonster() then
				return target_obj
			else
				_tmp_friend_info.obj = nil
				_tmp_friend_info.hp = 100
				self:ForeachAoiObj(_get_friend_func)

				local obj = _tmp_friend_info.obj
				_tmp_friend_info.obj = nil
				if not obj then
					obj = self
				end
	            self:SelectTarget(obj)
	            return obj
			end
		elseif skill_info.to_obj == 7 then
			return self:GetOwner()
		else
			local target_obj = self:GetTarget()
	        if not self:CanAttackObj(target_obj) then
	            target_obj = self:SearchEnemy()
	            self:SelectTarget(target_obj)
	        end
			return target_obj
		end
	end
end

function Character:GetSkillAssistPos(skill_id, target)
	local skill_info = self.skill_list[skill_id]
	if not skill_info then
		return
	end

	if skill_info.to_obj == 1 then
		return self:GetLogicPosXY()
	elseif skill_info.to_obj == 7 then
		local obj = self:GetOwner()
		if obj then
			return obj:GetLogicPosXY()
		end
	else
		if target then
			return target:GetLogicPosXY()
		end
	end
end

function Character:CanPlaySkill(skill_id, notice)
	local skill_info = self.skill_list[skill_id]
	return self:_CanPlaySkill(skill_info, global.Time.now_time, notice)
end

function Character:GetSkillTarget(skill_id)
	return self:_GetSkillTarget(self.skill_list[skill_id])
end

function Character:GetSkillToObjClient(skill_id)
	local skill_info = self.skill_list[skill_id]
	if skill_info then
		return skill_info.to_obj_client
	end
end

function Character:IsTmpEnemy(uniq_id)
	return false
end

function Character:GetRealm()
	return self.vo.realm
end

function Character:SetRealm(camp)
	self.vo.realm = camp
end

function Character:GetTeamID()
	return 0
end

function Character:CanDoCallPet()
	if self.is_dead then
		return false
	end

	local state_id = self:GetCurStateID()
	if state_id == _obj_state.Jump or
	   state_id == _obj_state.Practice or
	   state_id == _obj_state.Gather or
	   state_id == _obj_state.ChangeScene or
	   state_id == _obj_state.SeatMove then
		return false
	end
	return true
end

function Character:DoCallPet(grid)
	self.state_machine:ChangeState(_obj_state.CallPet, grid)
end

function Character:PlayOtherSkillEffect(skill_id, skill_lv, hero_id, legend, assist_x, assist_y)
	if self:CanPlaySkillEffect(skill_id) then
		local skill_cfg = ConfigHelpSkill.GetSkillInfo(skill_id, skill_lv, hero_id, legend)

		local effect = skill_cfg.effect
		if #effect > 0 then
			local unit_x, unit_y = game.LogicToUnitPos(assist_x, assist_y)
			local height = self.scene:GetHeightForLogicPos(assist_x, assist_y)
	        for i,v in ipairs(effect) do
	            if v[1] == 2 then
	                local eff_path = string.format("effect/skill/%s.ab", v[2])
	                local effect = _effect_mgr.instance:CreateObjEffect(eff_path, self.obj_id, 1)
	                game.RenderUnit:AddToObjLayer(effect:GetRoot())
	                effect:SetPosition(unit_x, height, unit_y)
	                if v[3] ~= 1 then
	                    effect:SetScale(v[3], v[3], v[3])
	                end
	            end
	        end
	    end
	end
end

function Character:DoAction(anim, type, partner_id)
	self.state_machine:ChangeState(_obj_state.PlayAction, anim, type, partner_id)
end

local _tmp_dir = {}
function Character:UpdateBuff(now_time, elapse_time)
	if self:IsClientObj() and not self:IsDead() then
		if self.buff_blind > 0 and self.buff_blind == self.mute_move then
			if not self.blind_move_time or now_time > self.blind_move_time then
				self.blind_move_time = now_time + 2.5
				_tmp_dir.x, _tmp_dir.y = cc.pNormalizeV(math.random(-100, 100) * 0.01, math.random(-100, 100) * 0.01)
			    local dist, target_x, target_y = self.scene:FindPathByUnit(self.unit_pos, _tmp_dir, math.random(5, 10))
			    if dist > 1 then
					self:DoMove(target_x, target_y)
				end
			end
		end
	end
end

function Character:DoSeatMove(x, y, keep_move)
	self.state_machine:ChangeState(_obj_state.SeatMove, x, y, keep_move)
end

function Character:CanPlayBuffEffect()
	return self.scene:CanPlayBuffEffect()
end

function Character:CanPlaySkillEffect(skill_id)
	return self.scene:CanPlaySkillEffect(skill_id)
end

function Character:CanPlayBeattackEffect(attacker)
	if attacker then
		if attacker:IsMainRole() or attacker:IsMainRolePet() then
			return true
		end
		return self.scene:CanPlayBeattackEffect()
	end
end

return Character
