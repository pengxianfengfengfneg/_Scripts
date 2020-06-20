local OperateHangTaskGatherQueue = Class(require("game/operate/operate_base"))

function OperateHangTaskGatherQueue:_init()
    self.oper_type = game.OperateType.HangTaskGatherQueue
end

function OperateHangTaskGatherQueue:Reset()
    self:ClearCurOperate()
    OperateHangTaskGatherQueue.super.Reset(self)
end

function OperateHangTaskGatherQueue:Init(obj, task_id, gather_id, scene_id)
    OperateHangTaskGatherQueue.super.Init(self, obj)

    self.task_id = task_id
    self.gather_id = gather_id
    self.scene_id = scene_id

    return true
end

function OperateHangTaskGatherQueue:Start()
    self.task_ctrl = game.TaskCtrl.instance

    local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
    if not task_info then
        return false
    end

    self.stop_func = function()
        local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
        if task_info then
            local info = task_info.masks[1]
            if info then
                if info.current >= info.total then
                    return 0
                end
            end
            return 1
        else
            return -1
        end
    end

    return true
end

function OperateHangTaskGatherQueue:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    local stop = self.stop_func()
    if stop <= 0 then
        self:ClearCurOperate()
        return stop == 0
    end

    if not self.cur_oper then
        self.cur_oper = self:CreateOperate(game.OperateType.HangGatherQueue, self.obj, self.gather_id, self.scene_id, self.stop_func)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
    end
end

function OperateHangTaskGatherQueue:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskGatherQueue:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangTaskGatherQueue
