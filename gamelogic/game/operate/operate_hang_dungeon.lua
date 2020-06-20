local OperateHangDungeon = Class(require("game/operate/operate_hang"))

function OperateHangDungeon:_init()
    self.oper_type = game.OperateType.HangDungeon
end

function OperateHangDungeon:Update(now_time, elapse_time)
    OperateHangDungeon.super.Update(self, now_time, elapse_time)

    if self.cur_oper then
        if self.state == 2 then
            local target = self.obj:GetTarget()
            if target and target:IsBoss() then

                local priority = self.obj:GetSearchEnemyPriority()
                if priority == 1 then
                    local new_target = self.obj:SearchEnemy()
                    if new_target ~= target then
                        self.obj:SelectTarget(new_target)
                        self:ClearCurOperate()
                    end
                end
            end
        end
    end
end

return OperateHangDungeon
