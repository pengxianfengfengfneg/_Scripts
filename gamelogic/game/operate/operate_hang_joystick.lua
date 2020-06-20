local OperateHangJoystick = Class(require("game/operate/operate_base"))

function OperateHangJoystick:_init()
    self.oper_type = game.OperateType.HangJoystick
    self.dir = {}
end

function OperateHangJoystick:Init(obj, dir_x, dir_y)
    OperateHangJoystick.super.Init(self, obj)
    self.dir.x = dir_x
    self.dir.y = dir_y
end

function OperateHangJoystick:Reset()
    self.obj:SetSearchFliterFunc()
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.HangChange, false)
    end
    self:ClearCurOperate()
    OperateHangJoystick.super.Reset(self)
end

function OperateHangJoystick:Start()
    if not self.obj:CanDoMove() then
        return false
    end

    local dist, x, y = game.Scene.instance:FindPathByUnit(self.obj.unit_pos, self.dir, 50)
    if dist < 1 then
        return false
    else
        self.cur_oper = self:CreateOperate(game.OperateType.Move, self.obj, x, y)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
    end

    local search_func = function(obj)
        return cc.isFaceTo(self.obj.logic_pos, obj.logic_pos, self.obj.dir)
    end
    self.obj:SetSearchFliterFunc(search_func)
    self.obj:SelectTarget(nil)
    self.search_state = true
    self.search_next_time = 0
    return true
end

function OperateHangJoystick:OnStart()
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.HangChange, true)
    end
end

function OperateHangJoystick:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)
    if not self.cur_oper then
        return false
    end

    if self.search_state then
        if now_time > self.search_next_time then
            self.search_next_time = now_time + 0.2
            local target = self.obj:SearchEnemy()
            if target then
                self.search_state = false
                self.obj:SelectTarget(target)
                self.cur_oper = self:CreateOperate(game.OperateType.Hang, self.obj)
                if not self.cur_oper:Start() then
                    self:ClearCurOperate()
                    return false
                end
            end
        end
    end
end

function OperateHangJoystick:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangJoystick:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangJoystick
