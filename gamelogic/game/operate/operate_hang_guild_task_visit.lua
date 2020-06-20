local OperateHangGuildTaskVisit = Class(require("game/operate/operate_base"))

function OperateHangGuildTaskVisit:_init()
    self.oper_type = game.OperateType.HangGuildTaskVisit
end

function OperateHangGuildTaskVisit:Init(obj, npc_id)
    OperateHangGuildTaskVisit.super.Init(self, obj)

    self.npc_id = npc_id

    return true
end

function OperateHangGuildTaskVisit:Reset()
    self:ClearCurOperate()

    OperateHangGuildTaskVisit.super.Reset(self)
end

function OperateHangGuildTaskVisit:Start()
    self.cur_oper = self:CreateOperate(game.OperateType.GoToNpc, self.obj, self.npc_id, function()
            game.DailyTaskCtrl.instance:OpenGuildTaskQuestionView()
        end)

    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false
    end

    return true
end

function OperateHangGuildTaskVisit:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
    if task_info.flag <= 0 then
        return false
    end 
end

function OperateHangGuildTaskVisit:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangGuildTaskVisit:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangGuildTaskVisit
