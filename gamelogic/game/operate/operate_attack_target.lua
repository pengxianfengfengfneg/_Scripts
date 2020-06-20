local OperateAttackTarget = Class(require("game/operate/operate_base"))

function OperateAttackTarget:_init()
    self.oper_type = game.OperateType.AttackTarget
end

function OperateAttackTarget:Init(obj, target_id, active_skill)
    OperateAttackTarget.super.Init(self, obj)
    self.target_id = target_id
    self.active_skill = active_skill
end

function OperateAttackTarget:Reset()
    self:ClearCurOperate()
    OperateAttackTarget.super.Reset(self)
end

function OperateAttackTarget:Start()
    local target_obj = self.obj.scene:GetObj(self.target_id)
    self.obj:SelectTarget(target_obj)
    return true
end

function OperateAttackTarget:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    local target_obj = self.obj.scene:GetObj(self.target_id)
    if not self.obj:CanAttackObj(target_obj) then
        return false
    end

    if not self.cur_oper then
        if not self.obj:CanDoAttack() then
            return
        end

        local skill_id, skill_lv, is_enemy_skill, target, hero_id, legend = self.obj:GetNextSkill(self.active_skill)
        if skill_id then
            if not target then
                target = self.obj:GetSkillTarget(skill_id)
            end

            if target then
                self.cur_oper = self:CreateOperate(game.OperateType.MoveAttack, self.obj, skill_id, skill_lv, target.obj_id, hero_id, legend)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                else
                    self.is_enemy_skill = is_enemy_skill
                end
            else
                return false
            end
        end
    else
        if self.is_enemy_skill then
            if not self.obj:CanAttackObj(self.obj:GetTarget()) then
                self:ClearCurOperate()
            end
        end
    end
end

function OperateAttackTarget:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateAttackTarget:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateAttackTarget
