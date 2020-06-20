local OperateHangFindWay = Class(require("game/operate/operate_base"))

local _search_mon_interval = 1
local _search_pos_interval = 2
function OperateHangFindWay:_init()
    self.oper_type = game.OperateType.HangFindWay
end

function OperateHangFindWay:Reset()
    self:ClearCurOperate()
    OperateHangFindWay.super.Reset(self)
end

function OperateHangFindWay:Start()
    self.next_search_mon_time = global.Time.now_time
    self.next_search_pos_time = global.Time.now_time
    return true
end

function OperateHangFindWay:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if now_time > self.next_search_mon_time then
        self.next_search_mon_time = now_time + _search_mon_interval
        local target_obj = self.obj:GetTarget()
        if not self.obj:CanAttackObj(target_obj) then
            target_obj = self.obj:SearchEnemy()
            self.obj:SelectTarget(target_obj)
        end
        if target_obj then
            return true
        end
    end

    if not self.cur_oper then
        local x, y = self.obj.scene:GetNextMonPos()
        if x and y and (x+y)>0 then
            x, y = game.LogicToUnitPos(x, y)
            self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, x, y)
            if not self.cur_oper:Start() then
                self:ClearCurOperate()
            end
        else
            if now_time > self.next_search_pos_time then
                self.next_search_pos_time = now_time + _search_pos_interval
                self.obj.scene:SendGetMonPosReq(game.EmptyTable)
            end
        end
    end

end

function OperateHangFindWay:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangFindWay:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangFindWay
