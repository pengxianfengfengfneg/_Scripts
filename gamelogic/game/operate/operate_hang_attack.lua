local OperateHangAttack = Class(require("game/operate/operate_base"))

function OperateHangAttack:_init()
    self.oper_type = game.OperateType.HangAttack
end

function OperateHangAttack:Reset()
    self:ClearCurOperate()
    OperateHangAttack.super.Reset(self)
end

function OperateHangAttack:Start()
    return true
end

function OperateHangAttack:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if not self.cur_oper then
        if not self.obj:CanDoAttack() then
            return
        end

        local skill_id, skill_lv, is_enemy_skill, target, hero_id, legend = self.obj:GetNextSkill(true)
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

function OperateHangAttack:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangAttack:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangAttack
