local GuildTaskView = Class(game.BaseView)

local config_kill_mon_exp_scene = config.kill_mon_exp_scene
local task_stage_cfg = config.guild_task_info.task_stage

function GuildTaskView:_init(ctrl)
    self._package_name = "ui_guild_task"
    self._com_name = "guild_task_view"

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = game.DailyTaskCtrl.instance

    self:AddPackage("ui_daily_task")
end

function GuildTaskView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitTaskList()
    self:InitWeekRewardList()
    self:RegisterAllEvents()
    self.ctrl:SendGuildTask()
end

function GuildTaskView:CloseViewCallBack()
    
end

function GuildTaskView:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.GuildTaskInfo] = function(task_data)
            self.task_data = task_data
            self:Refresh()
        end,
        [game.DailyTaskEvent.GuildTaskGet] = function()
            self:ToFinish()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function GuildTaskView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2749]):ShowBtnBack()
end

function GuildTaskView:Init()
    self.txt_left_times = self._layout_objs["txt_left_times"]
    self.txt_stage = self._layout_objs["txt_stage"]
    self.txt_week_reward = self._layout_objs["txt_week_reward"]
    self.txt_guild_task = self._layout_objs["txt_guild_task"]

    for i=1, 5 do
        self._layout_objs["txt_stage"..i]:SetText(string.format(config.words[5112], i))
    end
    self._layout_objs["txt_bottom_info"]:SetText(config.words[5168])

    self.txt_week_reward:SetText(config.words[5108])
    self.txt_guild_task:SetText(config.words[5109])
    self.txt_left_times:SetText(string.format(config.words[5110], config.guild_task_info.daily_max_times))
end

function GuildTaskView:InitTaskList()
    self.list_task = self:CreateList("list_task", "game/daily_task/item/guild_task_item")
    self.list_task:SetRefreshItemFunc(function(item, idx)
        local data = self.task_list_data[idx]
        local task_stage = self.task_data.task_stage
        local total_times = task_stage_cfg[math.min(#task_stage_cfg, self.task_data.task_stage)][2]

        local cur_times = data.times
        if task_stage > #task_stage_cfg then
            cur_times = cur_times + total_times
        end

        local item_info = {
            cur_times = cur_times,
            total_times = total_times,
            name = self:GetTypeName(data.type),
            type = data.type,
            multiply = self:GetRewardMultiple(data.type),
            star = self:GetStarNum(data.type)
        }

        item:SetItemInfo(item_info, idx)
    end)
end

function GuildTaskView:UpdateTaskList(task_list_data)
    self.task_list_data = task_list_data or {}
    local sort_lv = {1,2,3,5,4}
    table.sort(self.task_list_data, function(m, n)
        return sort_lv[m.type] < sort_lv[n.type]
    end)
    self.list_task:SetItemNum(#self.task_list_data)
end

function GuildTaskView:UpdateCurTaskInfo()
    self.txt_left_times:SetText(string.format(config.words[5110], config.guild_task_info.daily_max_times - self.task_data.daily_times))
    local task_stage = math.min(self.task_data.task_stage, #task_stage_cfg) 
    local total_times = self:GetTotalTimes(self.task_data.task_stage)
    self.txt_stage:SetText(string.format(config.words[5107], task_stage, total_times))
end

function GuildTaskView:InitWeekRewardList()
    self.list_wkreward = self:CreateList("list_wkreward", "game/bag/item/goods_item")
    self.list_wkreward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.wkreward_list_data[idx]
        item:SetItemInfo({id = item_info[3]})
        item:SetShowTipsEnable(true)

        local lock = self:IsLock(idx)
        item:SetGray(lock)
        self._layout_objs["lock"..idx]:SetVisible(lock)
        self._layout_objs["txt_stage"..idx]:SetText(lock and string.format(config.words[5112], idx) or config.words[5170])
    end)
end

function GuildTaskView:UpdateWeekRewardList()
    self.wkreward_list_data = config.guild_task_info.stage_reward
    self.list_wkreward:SetItemNum(#self.wkreward_list_data)
end

function GuildTaskView:Refresh()
    self:UpdateTaskList(self.task_data.task_info)
    self:UpdateWeekRewardList()
    self:UpdateCurTaskInfo()
end

function GuildTaskView:GetTaskRewardConfig(type, stage)
    local level = game.RoleCtrl.instance:GetRoleLevel()
    if not config.guild_task_reward[level] then
        local sort_list = game.Utils.SortByKey(config.guild_task_reward)
        for k, v in ipairs(sort_list) do
            if level <= v[stage][type].lv then
                return v[stage][type]
            end
        end
    else
        return config.guild_task_reward[level][stage][type]
    end
end

function GuildTaskView:GetRewardMultiple(type)
    local task_stage = config.guild_task_info.task_stage
    local cur_times = 0
    for k, v in ipairs(self.task_data.task_info) do
        if v.type == type then
            cur_times = v.times
            break
        end
    end
    local stage = self.task_data.task_stage
    local total_times = self:GetTotalTimes(stage)
    if cur_times >= total_times and stage < #task_stage then
        return 1
    else
        return self:GetStarNum(type)
    end
end

function GuildTaskView:GetStarNum(type)
    local star_list = {2, 2, 3, 5, 4}
    return star_list[type] or 1
end

function GuildTaskView:ToFinish()
    if not self.task_data or self.task_data.flag == 0 then
        game.GameMsgCtrl.instance:PushMsgCode(6505)
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.GuildTask)

    self:Close()
end

function GuildTaskView:IsLock(stage)
    if self.task_data then
        local task_stage = self.task_data.task_stage
        return stage >= task_stage and task_stage < #task_stage_cfg
    end
    return true
end

function GuildTaskView:InitTaskData(task_data)
    task_data.task_stage = math.min(5, task_data.task_stage)
    self.task_data = task_data
end

function GuildTaskView:GetTotalTimes(stage)
    return task_stage_cfg[math.min(#task_stage_cfg, stage)][2]
end

function GuildTaskView:GetTypeName(type)
    local config = config.guild_task[type]
    for k, v in pairs(config) do
        return v.name
    end
    return ""
end

return GuildTaskView
