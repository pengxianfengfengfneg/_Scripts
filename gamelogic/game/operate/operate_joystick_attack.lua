
local OperateJoystickAttack = Class(require("game/operate/operate_base"))

function OperateJoystickAttack:_init()
	self.oper_type = game.OperateType.JoystickAttack
end

function OperateJoystickAttack:Init(obj, skill_id)
	OperateJoystickAttack.super.Init(self, obj)
	self.skill_id = skill_id
end

function OperateJoystickAttack:Start()
	if not self.obj:CanDoAttack(self.skill_id) then
		return false
	end

	local skill_info = self.obj:GetSkillInfo(self.skill_id)
	if not skill_info then
		return false
	end

	self.cur_oper = nil
    local target = self.obj:GetSkillTarget(self.skill_id)
    if not target or skill_info.to_obj_client == 3 then
        if skill_info.to_obj_client == 2 or skill_info.to_obj_client == 3 then
            self.cur_oper = self:CreateOperate(game.OperateType.Attack, self.obj, skill_info.id, skill_info.lv, nil, skill_info.hero_id, skill_info.legend)
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[507])
        end
    else
        if self.obj:IsMainRole() and self.obj:CanAttackObj(target) then
            self.obj:SetNextSkill(self.skill_id)
            self.cur_oper = self:CreateOperate(game.OperateType.AttackTarget, self.obj, target.obj_id, false)
        else
            self.cur_oper = self:CreateOperate(game.OperateType.Attack, self.obj, skill_info.id, skill_info.lv, target.obj_id, skill_info.hero_id, skill_info.legend)
        end
    end

    if not self.cur_oper then
    	return false
    else
    	return self.cur_oper:Start()
    end
end

function OperateJoystickAttack:Reset()
    self:ClearCurOperate()
    OperateJoystickAttack.super.Reset(self)
end

function OperateJoystickAttack:Update(now_time, elapse_time)
	return self:UpdateCurOperate(now_time, elapse_time)
end

function OperateJoystickAttack:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
            return ret
        end
    end
end

function OperateJoystickAttack:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
        self.state = nil
    end
end

return OperateJoystickAttack
