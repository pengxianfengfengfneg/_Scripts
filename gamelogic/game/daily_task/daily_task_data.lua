local DailyTaskData = Class(game.BaseData)

function DailyTaskData:_init(ctrl)
    self.ctrl = ctrl
    self.exam_help_info = {}
    self.exam_assist_info = {}
end

function DailyTaskData:_delete()
end

function DailyTaskData:IsMeetOpenLimitCond(open_limit)
    local meet = true
    local lv = game.Scene.instance:GetMainRoleLevel()
    for k, v in ipairs(open_limit) do
        if v[1] == 1 then
            meet = lv >= v[2]
        end
        if not meet then
            break
        end
    end
    return meet
end

function DailyTaskData:SetThiefInfo(data)
    self.thief_info = data
    self:FireEvent(game.DailyTaskEvent.UpdateThiefInfo, data)
end

function DailyTaskData:UpdateThiefInfo(data)
    if not self.thief_info then
        return
    end
    
    for k, v in pairs(data) do
        self.thief_info[k] = v
    end
    self:FireEvent(game.DailyTaskEvent.UpdateThiefInfo, self.thief_info)
end

function DailyTaskData:GetThiefInfo()
    return self.thief_info
end

function DailyTaskData:SetGuildTaskInfo(data)
    self.guild_task_info = data
    self:FireEvent(game.DailyTaskEvent.GuildTaskInfo, data)
end

function DailyTaskData:UpdateGuildTaskInfo(data)
    if self.guild_task_info then
        for k, v in pairs(data) do
            self.guild_task_info[k] = v
        end
        self:FireEvent(game.DailyTaskEvent.GuildTaskInfo, self.guild_task_info)
    end
end

function DailyTaskData:GetGuildTaskInfo()
    return self.guild_task_info
end

function DailyTaskData:SetCxdxData(data)
    self.cxdt_data = data
end

function DailyTaskData:UpdateCxdtData(data)
    if self.cxdt_data then

        self.cxdt_data.scene_id = data.scene_id
        self.cxdt_data.x = data.x
        self.cxdt_data.y = data.y
        self.cxdt_data.state = data.state

        if data.mon_id then
            self.cxdt_data.mon_id = data.mon_id
        end

        if data.times then
            self.cxdt_data.times = data.times
        end
    end
end

function DailyTaskData:GetCxdtData()
    return self.cxdt_data
end

function DailyTaskData:SetExamineInfo(data)
    self.examine_info = data
    self:FireEvent(game.DailyTaskEvent.UpdateExamineInfo, self.examine_info)
end

function DailyTaskData:UpdateExamineInfo(data)
    if self.examine_info then
        for k, v in pairs(data) do
            self.examine_info[k] = v
        end
        self:FireEvent(game.DailyTaskEvent.UpdateExamineInfo, self.examine_info)
    end
end

function DailyTaskData:GetExamineInfo()
    return self.examine_info
end

function DailyTaskData:OnExamineAnswer(data)
    if self.examine_info then
        for k, v in pairs(data) do
            self.examine_info[k] = v
        end
        self:FireEvent(game.DailyTaskEvent.OnExamineAnswer, self.examine_info)
    end
end

function DailyTaskData:SetExamineHelpTag(data, tag)
    local help_info = self.exam_help_info
    local assist_info = self.exam_assist_info
    if data then
        local time = data.time or 0
        local id = data.role_id .. data.quest_id .. time
        help_info[id] = tag
        if tag == 1 then
            if data.role_id == game.RoleCtrl.instance:GetRoleId() then
                local id = data.role_id .. data.quest_id .. game.Utils.NowDaytimeStart(time)
                assist_info[id] = data
            end
        end
    end
end

function DailyTaskData:GetExamineHelpTag(data, tag)
    local help_info = self.exam_help_info
    if data then
        local time = data.time or 0
        local id = data.role_id .. data.quest_id .. time
        return help_info[id]
    end
end

function DailyTaskData:GetExamineHelpData(data)
    local assist_info = self.exam_assist_info
    if data then
        if not data.quest_id then
            return
        end
        local start_time = data.time and game.Utils.NowDaytimeStart(data.time) or 0
        local id = data.role_id .. data.quest_id .. start_time
        return assist_info[id]
    end
end

function DailyTaskData:SetExamineHelpState(data, state)
    self.exam_help_state = {
        answer_num = data.answer_num,
        quest_id = data.quest_id,
        state = state,
        send_time = global.Time.now_time,
    }
end

function DailyTaskData:GetExamineHelpState(data)
    if self.exam_help_state then
        local info = self.exam_help_state
        if info.answer_num == data.answer_num and info.quest_id == data.quest_id then
            return info.state
        end
    end
end

function DailyTaskData:SetExamineAnswerState(state)
    self.exam_answer_state = state
end

function DailyTaskData:GetExamineAnswerState()
    return self.exam_answer_state
end

function DailyTaskData:ResetExamineInfo()
    self.exam_assist_info = {}
    self.exam_help_info = {}
    self.exam_help_state = nil
end

function DailyTaskData:TryResetExamineHelpState()
    if self.exam_help_state then
        local reset_interval = 120
        local info = self.exam_help_state
        local now_time = global.Time.now_time
        if info.send_time and now_time - info.send_time >= reset_interval then
            info.time = now_time
            info.state = 0
        end
    end
end

function DailyTaskData:SetTreasureMapPosInfo(item_id, pos_info)
    self.treas_pos_info = self.treas_pos_info or {}
    self.treas_pos_info[item_id] = pos_info
end

function DailyTaskData:GetTreasureMapPosInfo(item_id)
    if self.treas_pos_info then
        return self.treas_pos_info[item_id]
    end
end

function DailyTaskData:SetTreasureMapInfo(data)
    self.treas_map_info = data
    self:FireEvent(game.DailyTaskEvent.UpdateTreasureMapInfo, self.treas_map_info)
end

function DailyTaskData:ClearTreasureMapMonInfo()
    if self.treas_map_info then
        self.treas_map_info.mon_id = nil
    end
end

function DailyTaskData:UpdateTreasureMapInfo(data, fire)
    fire = fire or true
    if self.treas_map_info then
        for k, v in pairs(data) do
            self.treas_map_info[k] = v
        end
        if fire then
            self:FireEvent(game.DailyTaskEvent.UpdateTreasureMapInfo, self.treas_map_info)
        end
    end
end

function DailyTaskData:GetTreasureMapInfo()
    return self.treas_map_info
end

function DailyTaskData:SetTreasureMapEventTag(tag)
    self.treas_map_event_tag = tag
end

function DailyTaskData:GetTreasureMapEventTag()
    return self.treas_map_event_tag or 0
end

function DailyTaskData:RandomGuildTaskNpcId(type)
    if type == 3 or type == 4 or type == 5 then
        local npc_list = config.guild_task[type][1].npc_id
        if #npc_list > 0 then
            self.guild_task_npc_id = npc_list[math.random(1, #npc_list)]
            game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.GuildTaskNpcId, self.guild_task_npc_id)
        end
    end
end

function DailyTaskData:ResetGuildTaskNpcId()
    self.guild_task_npc_id = 0
    game.MainUICtrl.instance:SendSetCommonlyKeyValue(game.CommonlyKey.GuildTaskNpcId, 0)
end

function DailyTaskData:SetGuildTaskNpcId(npc_id)
    self.guild_task_npc_id = npc_id
end

function DailyTaskData:GetGuildTaskNpcId()
    local npc_id = self.guild_task_npc_id or 4001
    if npc_id <= 0 then
        npc_id = 4001
        self.guild_task_npc_id = npc_id
    end
    return npc_id
end

function DailyTaskData:SetDailyTaskInfo(data)
    self.daily_task_info = data
    self:FireEvent(game.DailyTaskEvent.UpdateDailyTaskInfo, self.daily_task_info)
end

function DailyTaskData:GetDailyTaskInfo()
    return self.daily_task_info
end

function DailyTaskData:UpdateDailyTaskInfo(data)
    for k, v in pairs(data) do
        self.daily_task_info[k] = v
    end
    self:FireEvent(game.DailyTaskEvent.UpdateDailyTaskInfo, self.daily_task_info)
end

function DailyTaskData:GetDailyTaskTimes()
    return self.daily_task_info.times
end

return DailyTaskData