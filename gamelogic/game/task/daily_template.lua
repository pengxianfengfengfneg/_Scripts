local DailyTemplate = Class(game.UITemplate)

local DailyTaskConfig = require("game/task/daily_task_config")

local DailyTaskMap = {}
for _,v in pairs(DailyTaskConfig) do
    DailyTaskMap[v.type] = v
end

local config_task = config.task

function DailyTemplate:_init(parent_view, ctrl)
    self.ctrl = ctrl
end

function DailyTemplate:OpenViewCallBack()
	self:Init()
	
    self:RegisterAllEvents()
end

function DailyTemplate:CloseViewCallBack()
    if self.ui_list then
    	self.ui_list:DeleteMe()
    	self.ui_list = nil
    end
end

function DailyTemplate:RegisterAllEvents()
    local events = {
        {game.TaskEvent.OnUpdateTaskInfo, handler(self,self.OnUpdateTaskInfo)},
        {game.TaskEvent.OnAcceptTask, handler(self,self.OnAcceptTask)},
        {game.TaskEvent.OnGetTaskReward, handler(self,self.OnGetTaskReward)},
    }

    for _,v in pairs(DailyTaskConfig) do
        for _,cv in ipairs(v.update_event or {}) do
            table.insert(events, {cv, function(...)
                self:OnUpdateDailyTask(v.type, ...)
            end})
        end
    end

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function DailyTemplate:Init()
	self.txt_go = self._layout_objs["txt_go"]
	self.btn_go = self._layout_objs["btn_go"]
	self.btn_go:AddClickCallBack(function()
		game.ActivityMgrCtrl.instance:OpenActivityHallView()

		game.TaskCtrl.instance:CloseView()
	end)

	self:InitDaily()
end

function DailyTemplate:InitDaily()
	self.daily_task_data = {}

	self.list_item = self._layout_objs["list_item"]

    self.ui_list = game.UIList.New(self.list_item)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/task/daily_item").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetDailyTaskData(idx)
        item:UpdateData(data)
    end)

    for _,v in pairs(DailyTaskConfig) do
        if v.check_func(v.id) then
            table.insert(self.daily_task_data, v)
        end
    end

    self:UpdateTaskList()
    self:UpdateTemplate()
end

function DailyTemplate:GetDailyTaskData(idx)
	return self.daily_task_data[idx]
end

function DailyTemplate:OnUpdateDailyTask(daily_task_type, ...)
    local cfg = DailyTaskMap[daily_task_type]
    local is_enable = cfg.check_func(cfg.id)

    local insert_idx = 1
    local is_exist = false
    local remove_key = nil
    
    for k,v in ipairs(self.daily_task_data or {}) do
        if daily_task_type >= v.type then
            insert_idx = k+1
        end

        if v.type == daily_task_type then
            is_exist = true

            if not is_enable then
                remove_key = k
            end
            break
        end
    end

    local is_update = false
    if not is_exist and is_enable then
        is_update = true
        table.insert(self.daily_task_data, insert_idx, cfg)
    end

    if remove_key then
        is_update = true
        table.remove(self.daily_task_data,remove_key)
    end

    if is_update then
        self:UpdateTemplate()
    else
        if is_exist then
            self.ui_list:RefreshVirtualList()
        end
    end
end

local function sort_func(v1,v2)
    return v1.seq<v2.seq
end

function DailyTemplate:UpdateTemplate()
    table.sort(self.daily_task_data, sort_func)

    local item_num = #self.daily_task_data
    self.ui_list:SetItemNum(item_num)

    local height = math.max(item_num*155, 410)
    self.list_item:SetSize(720, height)
    
    -- self.txt_go:SetVisible(item_num<=0)
    -- self.btn_go:SetVisible(item_num<=0)
end

function DailyTemplate:UpdateTaskList()
    -- 获取主线、支线任务
    local career = game.Scene.instance:GetMainRoleCareer()

    local new_task_list = {}
    for _,v in ipairs(self.daily_task_data) do
        if v.name_func then
            table.insert(new_task_list, v)
        end
    end

    self.daily_task_data = new_task_list

    local task_info = self.ctrl:GetTaskInfo()
    for _,v in ipairs(task_info) do
        local task_id = v.task.id
        local cfg = config_task[task_id]
        local task_cfg = cfg[career] or cfg[1]

        if task_cfg.cate == game.TaskCate.Daily or task_cfg.cate==game.TaskCate.RunLoop then
            v.task.seq = task_cfg.seq
            v.task.type = task_cfg.type
            table.insert(self.daily_task_data, v.task)
        end
    end
end

function DailyTemplate:OnUpdateTaskInfo()
    self:UpdateTaskList()
    self:UpdateTemplate()
end

function DailyTemplate:OnAcceptTask()
    self:UpdateTaskList()
    self:UpdateTemplate()
end

function DailyTemplate:OnGetTaskReward()
    self:UpdateTaskList()
    self:UpdateTemplate()
end

return DailyTemplate
