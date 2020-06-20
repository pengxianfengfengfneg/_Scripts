local TaskTemplate = Class(game.UITemplate)

local config_task = config.task

function TaskTemplate:_init(parent_view, ctrl)
    self.ctrl = ctrl
end

function TaskTemplate:OpenViewCallBack()
	self:InitTask()
	
	self:RegisterAllEvents()
end

function TaskTemplate:CloseViewCallBack()
    if self.ui_list then
    	self.ui_list:DeleteMe()
    	self.ui_list = nil
    end
end

function TaskTemplate:RegisterAllEvents()
    local events = {
        {game.TaskEvent.OnUpdateTaskInfo, handler(self,self.OnUpdateTaskInfo)},
        {game.TaskEvent.OnAcceptTask, handler(self,self.OnAcceptTask)},
        {game.TaskEvent.OnGetTaskReward, handler(self,self.OnGetTaskReward)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function TaskTemplate:InitTask()
	self.list_item = self._layout_objs["list_item"]
	
	self.ui_list = game.UIList.New(self.list_item)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/task/task_item").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetTaskData(idx)
        item:UpdateData(data)
    end)

    self.task_data = {}
    self:UpdateTaskList()
end

function TaskTemplate:UpdateTaskList()
	-- 获取主线、支线任务
	local pre_num = #self.task_data
	self.task_data = {}
	local career = game.Scene.instance:GetMainRoleCareer()

	local task_info = self.ctrl:GetTaskInfo()
	for _,v in ipairs(task_info) do
		local task_id = v.task.id
		local cfg = config_task[task_id]
		if cfg then
			local task_cfg = cfg[career] or cfg[1]

			if task_cfg.cate==game.TaskCate.Main or task_cfg.cate==game.TaskCate.Branch then
				v.task.seq = task_cfg.seq
				table.insert(self.task_data, v.task)
			end
		end
	end

	table.sort(self.task_data, function(v1,v2)
		return v1.seq<v2.seq
	end)

	local item_num = #self.task_data
	if pre_num == item_num then
		self.ui_list:RefreshVirtualList()
	else
		self.ui_list:SetItemNum(#self.task_data)
	end
end

function TaskTemplate:GetTaskData(idx)
	return self.task_data[idx]
end

function TaskTemplate:OnUpdateTaskInfo()
	self:UpdateTaskList()
end

function TaskTemplate:OnAcceptTask()
	self:UpdateTaskList()
end

function TaskTemplate:OnGetTaskReward()
	self:UpdateTaskList()
end

return TaskTemplate
