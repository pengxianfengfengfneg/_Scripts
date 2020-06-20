local OperateHangRunloopTask = Class(require("game/operate/operate_base"))

local HangTaskConfig = require("game/task/hang_task_config")

function OperateHangRunloopTask:_init()
	self.oper_type = game.OperateType.HangRunloopTask
end

function OperateHangRunloopTask:Init(obj)
	OperateHangRunloopTask.super.Init(self, obj)

end

function OperateHangRunloopTask:Reset()
	self:FireStopTask()
	
	self:ClearCurOperate()

	OperateHangRunloopTask.super.Reset(self)
end

function OperateHangRunloopTask:Start()
	self.task_ctrl =game.TaskCtrl.instance 
	local circle_task_info = self.task_ctrl:GetCircleTaskInfo()
	local times = circle_task_info.times
	local round_times = circle_task_info.round_times
	if (times/round_times) >= 3 then
		return false
	end	

	self.cur_round = math.ceil(times/round_times)

	self.target_npc_id = config.activity_hall_ex[1016].npc_id
	
	return true
end

function OperateHangRunloopTask:Update(now_time, elapse_time)
	local circle_task_info = self.task_ctrl:GetCircleTaskInfo()
	local times = circle_task_info.times
	local round_times = circle_task_info.round_times
	if (times/round_times) >= 3 then
		-- 任务全部完成
		self:ClearCurOperate()
		return true,true
	end

	local task_id = self.task_ctrl:GetCircleTaskId()
	if not task_id and (times%round_times)==0 then
		local round = math.ceil(times/round_times)
		if round ~= self.cur_round then
			self.cur_round = round
			-- 新一轮
			if not self.cur_oper then
				self.cur_oper = self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, self.target_npc_id)
				if not self.cur_oper:Start() then
					self:ClearCurOperate()
				end
				return
			end
		end
	end

	self:UpdateCurOperate(now_time, elapse_time)

	if not task_id then
		return
	end

	if not self.cur_oper then
		local task_cfg = self.task_ctrl:GetTaskCfg(task_id)
		local task_info = self.task_ctrl:GetTaskInfoById(task_id)

		if not task_cfg or not task_info then
			return
		end

		self.cur_task_id = task_id

		if task_info.stat == game.TaskState.Finished then
			if not self.task_ctrl:ShouldTaskFindNpc(task_id) then
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

function OperateHangRunloopTask:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret,is_stop = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
        return is_stop
    end
end

function OperateHangRunloopTask:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

local TalkCond = {0}
function OperateHangRunloopTask:GetTaskCondType(task_cfg, task_info)
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

function OperateHangRunloopTask:OnSaveOper()
	self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateHangRunloopTask:FireStartTask(task_id)
    --global.EventMgr:Fire(game.TaskEvent.HangTask, task_id, true)
end

function OperateHangRunloopTask:FireStopTask()
	--global.EventMgr:Fire(game.TaskEvent.HangTask, nil, false)
end

function OperateHangRunloopTask:GetCurTaskId()
	return self.cur_task_id
end

return OperateHangRunloopTask
