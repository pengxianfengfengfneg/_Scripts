local DailyTaskGuildTemplate = Class(game.UITemplate)

function DailyTaskGuildTemplate:_init(view)
    self.parent = view
    self.ctrl = game.DailyTaskCtrl.instance   
end

function DailyTaskGuildTemplate:OpenViewCallBack()
    -- self:Init()
    -- self:InitTaskList()
    -- self:InitWeekRewardList()
    -- self:InitTaskRewardList()
    -- self:RegisterAllEvents()
    -- self.ctrl:SendGuildTask()
end

function DailyTaskGuildTemplate:CloseViewCallBack()
    
end

function DailyTaskGuildTemplate:Init()
    self.txt_left_times = self._layout_objs["txt_left_times"]
    self.txt_stage = self._layout_objs["txt_stage"]
    self.txt_week_reward = self._layout_objs["txt_week_reward"]
    self.txt_guild_task = self._layout_objs["txt_guild_task"]
    self.txt_task_info = self._layout_objs["txt_task_info"]
    self.txt_task_reward = self._layout_objs["txt_task_reward"]
    self.txt_no_guild = self._layout_objs["txt_no_guild"]
    self.txt_no_task = self._layout_objs["txt_no_task"]

    for i=1, 5 do
        self._layout_objs["txt_stage"..i]:SetText(string.format(config.words[5112], i))
    end

    self.txt_week_reward:SetText(config.words[5108])
    self.txt_guild_task:SetText(config.words[5109])
    self.txt_task_reward:SetText(config.words[5111])
    self.txt_left_times:SetText(string.format(config.words[5110], config.guild_task_info.daily_max_times))
    self.txt_no_guild:SetText(config.words[5123])
    self.txt_no_task:SetText(config.words[5124])

    self.btn_cancel_task = self._layout_objs["btn_cancel_task"]
    self.btn_cancel_task:SetText(config.words[1939])
    self.btn_cancel_task:AddClickCallBack(function()
        if not self.task_data or self.task_data.flag == 0 then
            game.GameMsgCtrl.instance:PushMsgCode(6505)
        else
            self.ctrl:OpenTipsView(4)
        end
    end)

    self.btn_to_finish = self._layout_objs["btn_to_finish"]
    self.btn_to_finish:SetText(config.words[5101])
    self.btn_to_finish:AddClickCallBack(handler(self, self.ToFinish))

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self:SetStateCtrl()
end

function DailyTaskGuildTemplate:InitTaskList()
    self.list_task = self:CreateList("list_task", "game/daily_task/item/guild_task_item")
    self.list_task:SetRefreshItemFunc(function(item, idx)
        local data = self.task_list_data[idx]
        local item_info = {
            cur_times = data.times,
            total_times = config.guild_task_info.task_stage[self.task_data.task_stage][2],
            name = config.guild_task[data.type][1].name,
            type = data.type,
            multiply = self:GetRewardMultiple(data.type),
            star = self:GetStarNum(data.type)
        }
        item:SetItemInfo(item_info)
    end)
end

function DailyTaskGuildTemplate:UpdateTaskList(task_list_data)
    self.task_list_data = task_list_data or {}
    self.list_task:SetItemNum(#self.task_list_data)
end

function DailyTaskGuildTemplate:UpdateCurTaskInfo()
    self.txt_left_times:SetText(string.format(config.words[5110], config.guild_task_info.daily_max_times - self.task_data.daily_times))
    self.txt_stage:SetText(string.format(config.words[5107], self.task_data.task_stage, config.guild_task_info.task_stage[self.task_data.task_stage][2]))
    self.txt_task_info:SetText(self:GetTaskInfoDesc() or "")
end

function DailyTaskGuildTemplate:InitWeekRewardList()
    self.list_wkreward = self:CreateList("list_wkreward", "game/bag/item/goods_item")
    self.list_wkreward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.wkreward_list_data[idx]
        item:SetItemInfo({id = item_info[3]})
        item:SetShowTipsEnable(true)
    end)
end

function DailyTaskGuildTemplate:UpdateWeekRewardList()
    self.wkreward_list_data = config.guild_task_info.stage_reward
    self.list_wkreward:SetItemNum(#self.wkreward_list_data)
end

function DailyTaskGuildTemplate:InitTaskRewardList()
    self.list_tsreward = self:CreateList("list_tsreward", "game/bag/item/goods_item")
    self.list_tsreward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.tsreward_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)
end

function DailyTaskGuildTemplate:UpdateTaskRewardList(type, task_stage)
    if task_stage ~= 0 and type ~= 0 then
        local rw_cfg = self:GetTaskRewardConfig(type, task_stage)
        local drop_id = rw_cfg.mul_reward
        self.tsreward_list_data = config.drop[drop_id].client_goods_list
        self.list_tsreward:SetItemNum(#self.tsreward_list_data)
    else
        self.list_tsreward:SetItemNum(0)
    end
end

function DailyTaskGuildTemplate:Refresh()
    self:UpdateTaskList(self.task_data.task_info)
    self:UpdateTaskRewardList(self.task_data.type, self.task_data.task_stage)
    self:UpdateWeekRewardList()
    self:UpdateCurTaskInfo()
    self:SetStateCtrl()
end

function DailyTaskGuildTemplate:ToFinish()
    if not self.task_data or self.task_data.flag == 0 then
        game.GameMsgCtrl.instance:PushMsgCode(6505)
        return
    end
    
    local main_role = game.Scene.instance:GetMainRole()
    main_role:GetOperateMgr():DoHangGuildTask()

    self.ctrl:CloseDailyTaskView()
end

function DailyTaskGuildTemplate:SetStateCtrl()
    local index = 0
    if not game.GuildCtrl.instance:IsGuildMember() then
        index = 0
    elseif not self.task_data or self.task_data.flag == 0 then
        index = 1
    elseif self.task_data and self.task_data.flag == 1 then
        index = 2
    end
    self.ctrl_state:SetSelectedIndex(index)
end

function DailyTaskGuildTemplate:RegisterAllEvents(task_cfg)
    local events = {
        [game.DailyTaskEvent.GuildTaskInfo] = function(task_data)
            -- task_info__T__type@C##times@H -- 帮会任务进度
            -- task_stage__C  -- 当前帮会任务阶段
            -- daily_times__C -- 今日已完成次数
            -- flag__C -- 状态(0:未接取|1:正在进行)
            -- type__C -- 正在进行时，接取的任务类型
            -- id__C -- 该任务类型下的id
            -- finish_times__C  -- 此次任务已完成次数
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

function DailyTaskGuildTemplate:GetTaskRewardConfig(type, stage)
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

function DailyTaskGuildTemplate:GetTaskInfoDesc()
    if not self.task_data or self.task_data.flag == 0 then
        return
    end

    local type = self.task_data.type
    local id = self.task_data.id
    local task_cfg = config.guild_task[type][id]

    local cur_times = self.task_data.finish_times
    local total_times = task_cfg.obj_num
    local scene_id = task_cfg.task_scene_info and task_cfg.task_scene_info[1]
    local obj_id = task_cfg.obj_id
    local npc_id = self.ctrl:GetGuildTaskNpcId()

    local scene_name = (scene_id and config.scene[scene_id].name) or (npc_id and config.scene[config.npc[npc_id].scene].name)

    if type == 1 then
        return string.format(config.words[5116], scene_name, config.gather[obj_id].name, cur_times, total_times)
    elseif type == 2 then
        return string.format(config.words[5117], scene_name, config.monster[obj_id].name, cur_times, total_times)
    elseif type == 3 then
        return string.format(config.words[5118], scene_name, config.npc[npc_id].name, cur_times, total_times)
    elseif type == 4 then
        return string.format(config.words[5119], config.npc[npc_id].name, config.pet[obj_id].name, cur_times, total_times)
    elseif type == 5 then
        return string.format(config.words[5120], config.goods[obj_id].name, scene_name, config.npc[npc_id].name, cur_times, total_times)
    end
end

function DailyTaskGuildTemplate:GetRewardMultiple(type)
    local task_stage = config.guild_task_info.task_stage
    local cur_times = self.task_data.task_info[type].times
    local total_times = task_stage[self.task_data.task_stage][2]
    if cur_times >= total_times then
        return 1
    else
        return self:GetStarNum(type)
    end
end

function DailyTaskGuildTemplate:GetStarNum(type)
    local star_list = {2, 2, 3, 4, 5}
    return star_list[type] or 1
end

return DailyTaskGuildTemplate
