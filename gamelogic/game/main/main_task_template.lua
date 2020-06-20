local MainTaskTemplate = Class(game.UITemplate)

local handler = handler
local config_skill = config.skill
local config_task = config.task
local config_scene = config.scene

local DailyTaskConfig = game.DailyTaskConfig

local DailyTaskMap = {}
for _,v in pairs(DailyTaskConfig) do
    DailyTaskMap[v.type] = v
end

function MainTaskTemplate:_init(view)    
    self.parent_view = view

    self.ctrl = game.TaskCtrl.instance
end

function MainTaskTemplate:OpenViewCallBack()
    self:Init()

    self:RegisterAllEvents()
end

function MainTaskTemplate:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function MainTaskTemplate:RegisterAllEvents()
    local events = {
        { game.TaskEvent.OnUpdateTaskInfo, handler(self, self.OnUpdateTaskInfo)},
        { game.TaskEvent.OnAcceptTask, handler(self, self.OnAcceptTask)},
        { game.TaskEvent.OnGetTaskReward, handler(self, self.OnGetTaskReward)},
    }

    for _,v in pairs(DailyTaskConfig) do
        for _,cv in ipairs(v.update_event or {}) do
            table.insert(events, {cv, function(...)
                self:OnUpdateDailyTask(v.type, cv, ...)
            end})
        end
    end

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MainTaskTemplate:Init()
    self.img_bg = self._layout_objs["img_bg"] 
    
    self.is_task_expand = false
    self.btn_task_fold = self._layout_objs["btn_task_fold"]
    self.btn_task_fold:AddClickCallBack(function()
        self:SwitchTaskFold()
    end)

    self.btn_task = self._layout_objs["btn_task"]
    self.btn_task:AddClickCallBack(function()
        game.TaskCtrl.instance:OpenView()
    end)
    
    self:InitTaskList()
    self:InitTaskData()
end

function MainTaskTemplate:InitTaskList()
    self.list_task = self._layout_objs["list_task"]

    self.ui_list = game.UIList.New(self.list_task)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local chat_item = require("game/main/main_task_item").New(self.ctrl)
        chat_item:SetVirtual(obj)
        chat_item:Open()

        return chat_item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetTaskData(idx)
        item:UpdateData(data)
    end)
end

function MainTaskTemplate:InitTaskData()
    self.task_data = {}
    self.daily_task_data = {}

    for _,v in pairs(DailyTaskConfig) do
        if v.check_func(v.id) then
            table.insert(self.daily_task_data, v)
        end
    end

    self:UpdateTaskList()
end

function MainTaskTemplate:SwitchTaskFold()
    self.is_task_expand = not self.is_task_expand

    self:UpdateTaskSize()

    local item_num = #self.task_data
    if item_num > 0 then
        self.list_task:ScrollToView(0)
    end
end

function MainTaskTemplate:GetTaskData(idx)
    return self.task_data[idx]
end

function MainTaskTemplate:OnUpdateDailyTask(daily_task_type, event_type, ...)
    local cfg = DailyTaskMap[daily_task_type]
    local is_enable = cfg.check_func(cfg.id)
    cfg.on_event(event_type, ...)

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
        self:UpdateTaskList()
    else
        if is_exist then
            self.ui_list:RefreshVirtualList()
        end
    end
end

function MainTaskTemplate:UpdateTaskList()
    self.task_data = {}

    local career = game.Scene.instance:GetMainRoleCareer()
    local task_info = self.ctrl:GetTaskInfo()
    for _,v in ipairs(task_info) do
        local task_cfg = config_task[v.task.id]
        local cfg = task_cfg[career] or task_cfg[1]
        v.task.cate = cfg.cate
        v.task.type = cfg.type
        v.task.seq = cfg.seq
        table.insert(self.task_data, v.task)
    end

    for _,v in ipairs(self.daily_task_data) do
        local task_cfg = self.ctrl:GetTaskCfg(v.id) or {seq=9999+v.type}
        v.seq = task_cfg.seq
        table.insert(self.task_data, v)
    end

    table.sort(self.task_data, function(v1,v2)
        return v1.seq<v2.seq
    end)

    self.ui_list:SetItemNum(#self.task_data)

    self:UpdateTaskSize()
end

function MainTaskTemplate:UpdateTaskSize()
    local height = 80
    local item_num = #self.task_data
    if self.is_task_expand then
        height = math.max(item_num*80, 80)
    end

    height = math.min(height, 6*80+20)

    if item_num > 0 then
        local obj = self.list_task:GetChildAt(0)
        local size = obj:GetSize()
        height = math.max(height, size[2])
    end

    self.list_task:SetSize(285, height)
end

function MainTaskTemplate:OnUpdateTaskInfo()
    self:UpdateTaskList()
end

function MainTaskTemplate:OnAcceptTask()
    self:UpdateTaskList()
end

function MainTaskTemplate:OnGetTaskReward(task_id, is_main_task)
    if not is_main_task then
        -- 主线任务在OnUpdateTaskInfo刷新
        self:UpdateTaskList()
    end
end

return MainTaskTemplate
