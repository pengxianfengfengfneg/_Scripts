local TaskData = Class(game.BaseData)

local config_task = config.task

local config_main_task = {}
for k,v in pairs(config_task) do
	local cfg = v[1]
	if cfg.cate == 1 then
		config_main_task[k] = 1
	end
end

local config_branch_task = {}
for k,v in pairs(config_task) do
	local cfg = v[1]
	if cfg.cate == 2 then
		config_branch_task[k] = 1
	end
end

function TaskData:_init()
	self.task_info = {}

	self.last_main_seq = 0
end

function TaskData:_delete()

end

function TaskData:OnTaskInfo(data)
	self.last_main_seq = data.last or 0
	self.task_info = data.tasks

	self:CheckMainTaskContinue()
end

function TaskData:OnTaskAccept(data)
	--[[
        "task__U|CltTask|",
    ]]
    local is_update = false
    for _,v in ipairs(self.task_info) do
    	if v.task.id == data.task.id then
    		is_update = true
    		v.task.stat = data.task.stat
    		v.task.masks = data.task.masks
    		break
    	end
    end

    if not is_update then
	    table.insert(self.task_info, data)
	end
end

-- 1-可接受 2-已接受 3-已完成 4-已领取
function TaskData:OnTaskFinish(data)
	for k,v in ipairs(self.task_info) do
		if v.task.id == data.id then
			v.task.stat = game.TaskState.Finished
			break
		end
	end
end

function TaskData:SendTaskGetReward(task_id)
	for k,v in ipairs(self.task_info) do
		if v.task.id == task_id then
			v.task.has_get_reward = true
			break
		end
	end
end

function TaskData:OnTaskGetReward(data)
	for k,v in ipairs(self.task_info) do
		if v.task.id == data.id then
			table.remove(self.task_info, k)
			break
		end
	end

	if self:IsMainTask(data.id) then
		-- 更新主线任务
		local task_cfg = self:GetTaskCfg(data.id)
		self.last_main_seq = task_cfg.seq

		self:CheckMainTaskContinue()
	end
end

-- 刷新任务进度 or 推送新任务，仅包含变更的
function TaskData:OnTaskRefresh(data)
	for _,v in ipairs(data.tasks) do
		local is_update = false
		for ck,cv in ipairs(self.task_info) do
			if v.task.id == cv.task.id then
				is_update = true
				cv.task.stat = v.task.stat
				cv.task.masks = v.task.masks

				if cv.task.stat == 4 then
					-- 状态4 删除任务
					table.remove(self.task_info, ck)
				end
				break
			end
		end

		if not is_update then
			table.insert(self.task_info, v)
		end
	end
end

function TaskData:GetTaskInfo()
	return self.task_info
end

function TaskData:GetTaskInfoById(task_id)
	for _,v in ipairs(self.task_info) do
		if v.task.id == task_id then
			return v.task
		end
	end
end

function TaskData:GetTaskInfoByType(task_type)
	for _,v in ipairs(self.task_info) do
		if self:GetTaskCfg(v.task.id).type == task_type then
			return v.task
		end
	end
end

function TaskData:IsTaskCompleted(task_id)
	if self.last_main_seq <= 0 then
		return false
	end

	if not self:IsMainTask(task_id) then
		return false
	end

	local cfg = config_task[task_id]
	local task_cfg = cfg[1]
	
	return (task_cfg.seq <= self.last_main_seq)
end

function TaskData:IsAcceptedTask(task_id)
	for k,v in ipairs(self.task_info) do
		if v.task.id == task_id then
			if v.task.stat == game.TaskState.Accepted then
				return true
			end
			break
		end
	end
	return false
end

function TaskData:IsAcceptableTask(task_id)
	for k,v in ipairs(self.task_info) do
		if v.task.id == task_id then
			if v.task.stat == game.TaskState.Acceptable then
				return true
			end
			break
		end
	end
	return false
end

function TaskData:IsFinishedTask(task_id)
	for k,v in ipairs(self.task_info) do
		if v.task.id == task_id then
			if v.task.stat == game.TaskState.Acceptable then
				return false
			end

			if v.task.stat == game.TaskState.Finished or (not v.task.masks[1]) then
				return true
			end
			break
		end
	end
	return false
end

function TaskData:GetTaskCfg(task_id)
	if not task_id then return end

	local cfg = config_task[task_id]
	if cfg then
		local career = game.Scene.instance:GetMainRoleCareer()
		local task_cfg = cfg[career] or cfg[1]
		return task_cfg
	end
end

function TaskData:IsMainTask(task_id)
	return config_main_task[task_id]
end

function TaskData:IsBranchTask(task_id)
	return config_branch_task[task_id]
end

function TaskData:GetMainTaskInfo()
	for k,v in ipairs(self.task_info) do
		if self:IsMainTask(v.task.id) then
			return v.task
		end
	end
	return nil
end

function TaskData:CheckMainTaskContinue()
	--[[
        "tasks__T__task@U|CltTask|",
    ]]

    --[[
		"id__I",
        "stat__C",
        "masks__T__current@H##total@H",
    ]]

    local main_task_info = self:GetMainTaskInfo()
    if main_task_info then
    	return
    end

    local task_cfg = nil
    local next_seq = self.last_main_seq + 1
    for _,v in pairs(config_task) do
    	local cfg = v[1]
    	if cfg.seq == next_seq then
    		task_cfg = cfg
    		break
    	end
    end

    if task_cfg then
    	local lv = game.Scene.instance:GetMainRoleLevel()
    	if lv >= task_cfg.level then
    		return
    	end

	    local task = {
		    id = task_cfg.id,
		    stat = 0,
		    masks = {},
		}

		if #task_cfg.finish_cond > 0 then
			local mask = {
				current = 0,
				total = task_cfg.finish_cond[1][2],
			}
			table.insert(task.masks, mask)
		end
		table.insert(self.task_info, {task = task})
	end
end

-- 跑环
function TaskData:OnCircleInfo(data)
	self.circle_task_info = data
end

function TaskData:OnCircleAccept(data)
	self.circle_task_info.quick_item = data.quick_item
	self.circle_task_info.quick_num = data.quick_num
end

function TaskData:OnCircleWilful(data)
	--[[
        "wilful_times__T__type@C##times@C",
    ]]
    self.circle_task_info.wilful_times = data.wilful_times
end

function TaskData:GetCircleTaskId()
	for _,v in ipairs(self.task_info) do
		local task_cfg = self:GetTaskCfg(v.task.id)
		if task_cfg then
			if task_cfg.cate == game.TaskCate.RunLoop then
				return task_cfg.id
			end
		end
	end
end

function TaskData:GetCircleTaskInfo()
	return self.circle_task_info
end

function TaskData:GetCircleTimes()
	return self.circle_task_info.times
end

function TaskData:GetCircleRoundTimes()
	return self.circle_task_info.round_times
end

local circle_wilful_times = config.sys_config["circle_wilful_times"].value
function TaskData:GetCircleWilfulTimes(type)
	for _,v in ipairs(self.circle_task_info.wilful_times) do
		if v.type == type then
			return v.times
		end
	end
	return 0
end

function TaskData:GetCircleWilfulLeftTimes(type)
	local max_times = 0
	for _,v in ipairs(circle_wilful_times) do
		if v[1] == type then
			max_times = v[2]
			break
		end
	end

	if max_times <= 0 then
		return 1000
	end

	local use_times = self:GetCircleWilfulTimes(type)
	return (max_times - use_times)
end

return TaskData
