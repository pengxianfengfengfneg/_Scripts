local OperateHangStay = Class(require("game/operate/operate_base"))

function OperateHangStay:_init()
    self.oper_type = game.OperateType.HangStay
end

function OperateHangStay:Reset()
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.HangChange, false)
    end
    self:ClearCurOperate()
    OperateHangStay.super.Reset(self)
end

function OperateHangStay:Start()
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.HangChange, true)
    end
    return true
end

function OperateHangStay:Update(now_time, elapse_time)
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

            self.obj:SelectTarget(target)

            if target then
                self.cur_oper = self:CreateOperate(game.OperateType.MoveAttack, self.obj, skill_id, skill_lv, target.obj_id, hero_id, legend)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                else
                    self.is_enemy_skill = is_enemy_skill
                end
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

function OperateHangStay:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangStay:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangStay
