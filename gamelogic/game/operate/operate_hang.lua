local OperateHang = Class(require("game/operate/operate_base"))

function OperateHang:_init()
    self.oper_type = game.OperateType.Hang
end

function OperateHang:Reset()
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.HangChange, false)
    end
    self:ClearCurOperate()
    OperateHang.super.Reset(self)
end

function OperateHang:Start()
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.HangChange, true)
    end
    
    return true
end

function OperateHang:OnStart()
    -- if self.obj:IsMainRole() then
    --     global.EventMgr:Fire(game.SceneEvent.HangChange, true)
    -- end
end

function OperateHang:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if not self.cur_oper then
        if not self.obj:HasEnemy() then
            self.cur_oper = self:CreateOperate(game.OperateType.HangFindWay, self.obj)
            self.state = 1
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end
        else
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
                    self.state = 2
                    if not self.cur_oper:Start() then
                        self:ClearCurOperate()
                    end
                end
            end
        end
    else
        if self.state == 1 then
            if self.obj:HasEnemy() then
                self:ClearCurOperate()
            end
        end
    end
end

function OperateHang:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHang:ClearCurOperate()
    self.state = 0
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHang
