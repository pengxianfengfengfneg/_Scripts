--科举考试新手任务
local OperateHangTaskExamineNew = Class(require("game/operate/operate_base"))

local bank_num = #config.examine_new_bank

function OperateHangTaskExamineNew:_init()
    self.oper_type = game.OperateType.HangTaskExamineNew
end

function OperateHangTaskExamineNew:Reset()
    self:ClearCurOperate()
    OperateHangTaskExamineNew.super.Reset(self)
end

function OperateHangTaskExamineNew:Init(obj, task_cfg)
    OperateHangTaskExamineNew.super.Init(self, obj)
    self.task_cfg = task_cfg
    self.task_id = task_cfg.id
    return true
end

function OperateHangTaskExamineNew:Start()
    local task_info = game.TaskCtrl.instance:GetTaskInfoById(self.task_id)
    if not task_info then
        return false
    end

    if not self:IsFinishTask() then
        local client_action = self.task_cfg.client_action or game.EmptyTable
        client_action = client_action[1]
        local npc_id = client_action[3]
        self.cur_oper = self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id, function()
            game.ImperialExamineCtrl.instance:OpenTaskView()
        end,1)
        if not self.cur_oper:Start() then
            return false
        end
    end
    return true
end

function OperateHangTaskExamineNew:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if self:IsFinishTask() then
        game.TaskCtrl.instance:SendTaskGetReward(self.task_id)
        return true
    end
end

function OperateHangTaskExamineNew:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskExamineNew:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangTaskExamineNew:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type, self.task_id)
end

function OperateHangTaskExamineNew:IsFinishTask()
    local num = game.DailyTaskCtrl.instance:GetExamineNewTaskNum()
    return (num >= bank_num)
end

return OperateHangTaskExamineNew
