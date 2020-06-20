local OperateHangDailyTask = Class(require("game/operate/operate_base"))

local HangTaskConfig = require("game/task/hang_task_config")

function OperateHangDailyTask:_init()
	self.oper_type = game.OperateType.HangDailyTask
end

function OperateHangDailyTask:Init(obj)
	OperateHangDailyTask.super.Init(self, obj)

end

function OperateHangDailyTask:Reset()
	self:FireStopTask()
	
	self:ClearCurOperate()

	OperateHangDailyTask.super.Reset(self)
end

function OperateHangDailyTask:Start()
	local daily_task_info = game.DailyTaskCtrl.instance:GetDailyTaskInfo()
	if not daily_task_info then
		return false
	end	
	
	return true
end

function OperateHangDailyTask:Update(now_time, elapse_time)
	local daily_task_info = game.DailyTaskCtrl.instance:GetDailyTaskInfo()
	if not daily_task_info then
		self:ClearCurOperate()
		return true,true
	end

	if daily_task_info.times >= 10 then
		-- 任务全部完成
		self:ClearCurOperate()
		return true,true
	end

	local is_stop = self:UpdateCurOperate(now_time, elapse_time)
	if is_stop then
		return true,true
	end

	if not self.cur_oper then
		local task_id = daily_task_info.task_id

		local task_ctrl = game.TaskCtrl.instance
		local task_cfg = task_ctrl:GetTaskCfg(task_id)
		local task_info = task_ctrl:GetTaskInfoById(task_id)

		if not task_cfg or not task_info then
			return
		end

		self.cur_task_id = task_id

		if task_info.stat == game.TaskState.Finished then
			if not task_ctrl:ShouldTaskFindNpc(task_id) then
				self.cur_oper = self:CreateOperate(game.OperateType.GetTaskReward, self.obj, task_id)
				if not self.cur_oper:Start() then
					self:ClearCurOperate()
				end
				return
			end
		end

		local conds = self:GetTaskCondType(task_cfg, task_info)

		local oper_list = {}
		for k,v in ipairs(conds) do
    		local cfg = HangTaskConfig[v]
    		if cfg then
    			local opers = {cfg.oper_func(self, task_cfg, task_info, k)}
                for _,cv in ipairs(opers) do
        			table.insert(oper_list, cv)
                end
    		end
    	end

    	self:FireStartTask(task_id)
		self.cur_oper = self:CreateOperate(game.OperateType.HangSequence, self.obj, oper_list)
        local res,is_stop = self.cur_oper:Start()
        if not res then
            self:ClearCurOperate()
        end

        if is_stop then
            return false,true
        end
	end
end

function OperateHangDailyTask:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret,is_stop = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
        return is_stop
    end
end

function OperateHangDailyTask:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

local TalkCond = {0}
function OperateHangDailyTask:GetTaskCondType(task_cfg, task_info)
    if #task_cfg.client_action > 0 then
        local conds = {
            task_cfg.client_action[1][1],
        }
        return conds
    end

	if #task_cfg.finish_cond <= 0 then
		return TalkCond
	end

    if task_info.stat == game.TaskState.Finished then
        return TalkCond
    end

	local conds = {}
	for _,v in ipairs(task_cfg.finish_cond) do
		table.insert(conds, v[1])
	end
	return conds
end

function OperateHangDailyTask:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateHangDailyTask:FireStartTask(task_id)
    --global.EventMgr:Fire(game.TaskEvent.HangTask, task_id, true)
end

function OperateHangDailyTask:FireStopTask()
	--global.EventMgr:Fire(game.TaskEvent.HangTask, nil, false)
end

function OperateHangDailyTask:GetCurTaskId()
	return self.cur_task_id
end

return OperateHangDailyTask
