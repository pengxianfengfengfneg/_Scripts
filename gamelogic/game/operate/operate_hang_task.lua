local OperateHangTask = Class(require("game/operate/operate_base"))

local HangTaskConfig = require("game/task/hang_task_config")

local TalkCond = {0}

function OperateHangTask:_init()
    self.oper_type = game.OperateType.HangTask
end

function OperateHangTask:Reset()
    self:FireStopTask()

    self.cur_task_id = nil
    self.start_task_id = nil

    self:ClearCurOperate()
    OperateHangTask.super.Reset(self)
end

function OperateHangTask:Init(obj, task_id)
	OperateHangTask.super.Init(self, obj)
    self.start_task_id = task_id
    self.cur_task_id = nil

    self._pause_task = false

	self.task_ctrl = game.TaskCtrl.instance
end

function OperateHangTask:Start()
    if self:CheckDailyTask() then
        return self:DoDailyTask()
    end

    if self:CheckTreasureTask() then
        return self:DoTreasureTask()
    end

    if self:CheckCxdtTask() then
        return self:DoCxdtTask()
    end

    if self:CheckGuildTask() then
        return self:DoGuildTask()
    end

    if self:CheckThiefTask() then
        return self:DoThiefTask()
    end

    if self:CheckRunloopTask() then
        return self:DoRunloopTask()
    end

    if self:CheckYunbiaoTask() then
        return self:DoYunbiaoTask()
    end

    return self:DoMainSubTask()
end

function OperateHangTask:Update(now_time, elapse_time)
    if self._pause_task then
        return
    end

    if self:UpdateCurOperate(now_time, elapse_time) then
        return false
    end
end

function OperateHangTask:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local cur_task_id = self.cur_oper:GetCurTaskId()

        if cur_task_id~=self.cur_task_id then
            self.cur_task_id = cur_task_id

            if self.cur_task_id then
                self:FireStartTask()
            end
        end

        local ret,is_stop = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()            
        end
        return is_stop
    end
end

function OperateHangTask:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangTask:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type, self.cur_task_id)
end

function OperateHangTask:FireStartTask( )
    global.EventMgr:Fire(game.TaskEvent.HangTask, self.cur_task_id, true)
end

function OperateHangTask:FireStopTask()
    global.EventMgr:Fire(game.TaskEvent.HangTask, nil, false)
end

function OperateHangTask:GetCurTaskId()
    return self.cur_task_id
end

function OperateHangTask:SetPause(val)
    self._pause_task = val
end

function OperateHangTask:CheckDailyTask()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.start_task_id)
    if task_cfg and task_cfg.type==game.TaskType.DailyTask then
        return true
    end
    return false
end

function OperateHangTask:DoDailyTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangDailyTask, self.obj)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end
    return true
end

function OperateHangTask:CheckTreasureTask()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.start_task_id)
    if task_cfg and task_cfg.type==game.TaskType.TreasureTask then
        return true
    end
    return false
end

function OperateHangTask:DoTreasureTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangTaskTreasureMap, self.obj)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end

    --self:FireStartTask()
    return true
end

function OperateHangTask:CheckCxdtTask()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.start_task_id)
    if task_cfg and task_cfg.type==game.TaskType.RobberTask then
        return true
    end
    return false
end

function OperateHangTask:DoCxdtTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangTaskCxdt, self.obj)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end

    --self:FireStartTask()
    return true
end

function OperateHangTask:CheckGuildTask()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.start_task_id)
    if task_cfg and task_cfg.type==game.TaskType.GuildTask then
        return true
    end
    return false
end

function OperateHangTask:DoGuildTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangGuildTask, self.obj)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end

    --self:FireStartTask()
    return true
end

function OperateHangTask:CheckThiefTask()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.start_task_id)
    if task_cfg and task_cfg.type==game.TaskType.BanditTask then
        return true
    end
    return false
end

function OperateHangTask:DoThiefTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangTaskThief, self.obj)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end

    return true
end

function OperateHangTask:DoMainSubTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangMainSubTask, self.obj, self.start_task_id)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end

    return true
end

function OperateHangTask:CheckRunloopTask()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.start_task_id)
    if task_cfg and task_cfg.cate==game.TaskCate.RunLoop then
        return true
    end
    return false
end

function OperateHangTask:DoRunloopTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangRunloopTask, self.obj)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end

    return true
end

function OperateHangTask:CheckYunbiaoTask()
    local task_cfg = self.task_ctrl:GetTaskCfg(self.start_task_id)
    if task_cfg and task_cfg.type==game.TaskType.YunbiaoTask then
        return true
    end
    return false
end

function OperateHangTask:DoYunbiaoTask()
    self.cur_oper = self:CreateOperate(game.OperateType.HangGuildCarry, self.obj)
    if not self.cur_oper:Start() then
        self:ClearCurOperate()
        return false,true
    end

    return true
end

return OperateHangTask
