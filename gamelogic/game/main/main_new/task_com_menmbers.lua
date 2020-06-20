local TaskComMenmbers = Class(game.UITemplate)

local config_task = config.task

local DailyTaskConfig = require("game/task/daily_task_config")

local DailyTaskMap = {}
for _,v in pairs(DailyTaskConfig) do
    DailyTaskMap[v.type] = v
end

function TaskComMenmbers:_init()

	TaskComMenmbers.instance = self
end

function TaskComMenmbers:_delete()
	TaskComMenmbers.instance = nil
end

function TaskComMenmbers:OpenViewCallBack()
	self:Init()
	
	self:RegisterAllEvents()
end

function TaskComMenmbers:CloseViewCallBack()
    if self.ui_list then
    	self.ui_list:DeleteMe()
    	self.ui_list = nil
    end
end

function TaskComMenmbers:RegisterAllEvents()
	local events = {
		{ game.TaskEvent.OnUpdateTaskInfo, handler(self, self.OnUpdateTaskInfo)},
        { game.TaskEvent.OnAcceptTask, handler(self, self.OnAcceptTask)},
        { game.TaskEvent.OnGetTaskReward, handler(self, self.OnGetTaskReward)},
        { game.TaskEvent.OnDoneTaskTalk, handler(self, self.OnDoneTaskTalk)},
        { game.TaskEvent.HangTask, handler(self, self.OnHangTask)}
	}

	for _,v in pairs(DailyTaskConfig) do
        for _,cv in ipairs(v.update_event or {}) do
            table.insert(events, {cv, function(...)
                self:OnUpdateDailyTask(v.type, ...)
            end})
        end
    end

	for _,v in ipairs(events) do
		self:BindEvent(v[1],v[2])
	end
end

function TaskComMenmbers:Init()
	self.ctrl = game.TaskCtrl.instance

    self.btn_task = self._layout_objs["btn_task"]
	--点击打开任务界面
    self.btn_task:AddClickCallBack(function()
    	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/task_com/btn_task"})
        game.TaskCtrl.instance:OpenView()
    end)

    self:InitTaskList()
end

function TaskComMenmbers:InitTaskList()
	self.task_data = {}

	self.list_tab = self._layout_objs["list_tab"]

	self.tab_ctrl = self:GetRoot():GetController("c2")

	self.list_task = self._layout_objs["list_task"]

	self.ui_list = game.UIList.New(self.list_task)
    self.ui_list:SetTaskVirtual()

	--点击任务寻路
    self.ui_list:AddClickItemCallback(function(item)
		if item then
			item:OnClick()
		end
	end)

	self.list_task_ctrl = self.ui_list:AddControllerCallback("c1", function(idx, item)
		local index = idx
		if self.task_num > 5 then
			if idx >= 3 then
				index = 3
			end

			if idx >= (self.task_num-2) then
				index = (idx==(self.task_num-1) and 4 or 3)
			end
		end

		if item then
			self.showing_task_id = item:GetTaskId()
		end

		self.tab_ctrl:SetSelectedIndexEx(index-1)
	end)

    self.ui_list:SetCreateItemFunc(function(obj)
        local task_item = require("game/main/main_new/task_item").New(self.ctrl)
        task_item:SetVirtual(obj)
        task_item:Open()

        return task_item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetTaskData(idx)
        item:UpdateData(data)
    end)

    for _,v in pairs(DailyTaskConfig) do
        if v.check_func(v.id) then
            table.insert(self.task_data, v)
        end
    end

    self.next_task_update_time = 0
end

function TaskComMenmbers:OnUpdateDailyTask(daily_task_type, ...)
    local cfg = DailyTaskMap[daily_task_type]
    if not cfg then return end

    local is_enable = cfg.check_func(cfg.id)

    local new_task_list = {}
    for _,v in ipairs(self.task_data) do
    	if v.id ~= cfg.id then    		
			table.insert(new_task_list, v)
		end
    end

    if is_enable then
    	table.insert(new_task_list, cfg)
    end

    self.task_data = new_task_list
    
	self:DoRefresh()
end

function TaskComMenmbers:UpdateTaskList()
	local new_task_list = {}

	 for _,v in ipairs(self.task_data) do
    	if v.name_func then    		
			table.insert(new_task_list, v)
		end
    end

	local career = game.Scene.instance:GetMainRoleCareer()
	local task_info = self.ctrl:GetTaskInfo()

	--设置只显示支线任务
	for _,v in ipairs(task_info) do
		local task_id = v.task.id
		local cfg = config_task[task_id]
		if cfg and cfg[1].cate == 2 then
			local task_cfg = cfg[career] or cfg[1]
			v.task.seq = task_cfg.seq
			v.task.show_seq = task_cfg.show_seq
			table.insert(new_task_list, v.task)
		end
	end

	self.task_data = new_task_list

	self:DoRefresh()
end

function TaskComMenmbers:DoRefresh()
	table.sort(self.task_data, function(v1,v2)
		return v1.seq<v2.seq
	end)

	self.task_num = #self.task_data
	self.list_task_ctrl:SetPageCount(self.task_num)

	self.ui_list:SetItemNum(self.task_num)

	--设置显示任务数量
	if self.task_num > 1 then
		game.MakeTeamCom.instance:SetTaskVil(false)
		self.ui_list:SetItemNum(2)
	elseif self.task_num == 1 then
		game.MakeTeamCom.instance:SetTaskVil(false)
		self.ui_list:SetItemNum(1)
	else
		game.MakeTeamCom.instance:SetTaskVil(true)
	end

	local max_tab = math.min(self.task_num, 5)
	self.list_tab:SetItemNum(max_tab)

	-- global.TimerMgr:CreateTimer(0.01, function()
	-- 	self.tab_ctrl:SetSelectedIndexEx(0)
	-- 	return true
	-- end)
	

	self:RefreshShowingTask()
end

--点击前往执行任务时刷新任务
function TaskComMenmbers:RefreshTaskList(val_id)
	local new_task_list = {}

	local career = game.Scene.instance:GetMainRoleCareer()
	local task_info = self.ctrl:GetTaskInfo()

	for _,v in ipairs(task_info) do
		local task_id = v.task.id
		local cfg = config_task[task_id]
		local task_cfg = cfg[career] or cfg[1]
		if task_id == val_id then
			v.task.seq = task_cfg.seq
			v.task.show_seq = task_cfg.show_seq
			table.insert(new_task_list, v.task)
		end
	end

	for _,v in ipairs(task_info) do
		local task_id = v.task.id
		local cfg = config_task[task_id]
		local task_cfg = cfg[career] or cfg[1]
		if cfg and cfg[1].cate == 2 and task_id ~= val_id then
			v.task.seq = task_cfg.seq
			v.task.show_seq = task_cfg.show_seq
			table.insert(new_task_list, v.task)
		end
	end
	self.task_data = new_task_list

	self:DoRefreshShow()
end

--刷新前往执行的任务显示
function TaskComMenmbers:DoRefreshShow()
	self.task_num = #self.task_data
	self.list_task_ctrl:SetPageCount(self.task_num)

	self.ui_list:SetItemNum(self.task_num)

	--设置显示任务数量
	if self.task_num > 1 then
		game.MakeTeamCom.instance:SetTaskVil(false)
		self.ui_list:SetItemNum(2)
	elseif self.task_num == 1 then
		game.MakeTeamCom.instance:SetTaskVil(false)
		self.ui_list:SetItemNum(1)
	else
		game.MakeTeamCom.instance:SetTaskVil(true)
	end

	local max_tab = math.min(self.task_num, 5)
	self.list_tab:SetItemNum(max_tab)
	self:RefreshShowingTask()
end


function TaskComMenmbers:GetTaskData(idx)
	return self.task_data[idx]
end

function TaskComMenmbers:OnUpdateTaskInfo(data)	
    --self:UpdateTaskList()

    self.next_task_update_time = global.Time.now_time + 0.2
end

function TaskComMenmbers:OnAcceptTask()
	--self:UpdateTaskList()
	self.next_task_update_time = 0
end

function TaskComMenmbers:OnGetTaskReward(task_id, is_main_task)
	--self:UpdateTaskList()
	self.next_task_update_time = global.Time.now_time + 0.5
end

function TaskComMenmbers:OnDoneTaskTalk(task_id)
	--self:UpdateTaskList()
	self.next_task_update_time = global.Time.now_time + 0.5
end

function TaskComMenmbers:OnHangTask(task_id, is_hang)
	if is_hang then
		self.hanging_task_id = task_id
		self:ShowTask(task_id)
	end
end

function TaskComMenmbers:ShowTask(task_id)
	-- if self.showing_task_id == task_id then
	-- 	return
	-- end

	local idx = nil
	for k,v in ipairs(self.task_data) do
		if v.id == task_id then
			idx = k
		end
	end

	if idx then
		self.list_task_ctrl:SetSelectedIndexEx(idx-1)
	end
end

function TaskComMenmbers:GetShowingTask()
	return self.showing_task_id
end

function TaskComMenmbers:RefreshShowingTask()
	local show_task_id = self:CalcShowingTask()
	self:ShowTask(show_task_id)
end

function TaskComMenmbers:CalcShowingTask()
	if self.hanging_task_id then
		if self.ctrl:GetTaskInfoById(self.hanging_task_id) then
			return self.hanging_task_id
		else
			if not self.ctrl:IsMainTask(self.hanging_task_id) then
				local task_cfg = self.ctrl:GetTaskCfg(self.hanging_task_id)
				if task_cfg.next>0 and self.ctrl:GetTaskInfoById(task_cfg.next) then
					self.hanging_task_id = task_cfg.next
					return task_cfg.next
				end
			end

			local daily_cfg = DailyTaskConfig[self.hanging_task_id]
			if daily_cfg then
				if daily_cfg.check_func() then
					return self.hanging_task_id
				end
			end
		end
	end

	if #self.task_data <= 0 then
		return
	end

	local main_task_info = nil
	for k,v in ipairs(self.task_data) do
		if self.ctrl:IsMainTask(v.id) then
			main_task_info = v
			break
		end
	end

	if main_task_info then
		if main_task_info.stat > game.TaskState.NotAcceptable then
			return main_task_info.id
		end

		main_task_info.show_seq = 100000
	end


	local task_id = nil
	local show_seq = 999999
	for k,v in ipairs(self.task_data) do
		if v.show_seq < show_seq then
			show_seq = v.show_seq
			task_id = v.id
		end
	end

	return task_id
end

function TaskComMenmbers:Update(now_time, elapse_time)
	if self.next_task_update_time then
		if now_time >= self.next_task_update_time then
			self:UpdateTaskList()
			self.next_task_update_time = nil
		end
	end
end

game.TaskComMenmbers = TaskComMenmbers

return TaskComMenmbers
