local OperateGetTaskReward = Class(require("game/operate/operate_base"))

function OperateGetTaskReward:_init()
    self.oper_type = game.OperateType.GetTaskReward
end

function OperateGetTaskReward:Reset()
    OperateGetTaskReward.super.Reset(self)

    self:UnRegisterAllEvents()
end

function OperateGetTaskReward:Init(obj, task_id, pet_grid_id)
    OperateGetTaskReward.super.Init(self, obj)
    self.task_id = task_id
    self.pet_grid_id = pet_grid_id
end

function OperateGetTaskReward:Start()
    self.is_get_reward = false
    self.send_time = global.Time.now_time

    game.TaskCtrl.instance:SendTaskGetReward(self.task_id, self.pet_grid_id)

    self:RegisterAllEvents()
    return true
end

function OperateGetTaskReward:Update(now_time, elapse_time)
    if self.is_get_reward or (now_time-self.send_time)>3 then
        return true
    end
end

function OperateGetTaskReward:RegisterAllEvents()
    self.event_id = global.EventMgr:Bind(game.TaskEvent.OnGetTaskReward,function()
            self.is_get_reward = true
        end)
end

function OperateGetTaskReward:UnRegisterAllEvents()
    if self.event_id then
        global.EventMgr:UnBind(self.event_id)
        self.event_id = nil
    end
end

return OperateGetTaskReward
