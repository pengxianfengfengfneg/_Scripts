local GuildWineSideInfoView = Class(game.BaseView)

local ViewCounter = {
    Act = 1,
    Next = 2,
}

function GuildWineSideInfoView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_wine_side_info_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self._view_type = game.UIViewType.Fight
end

function GuildWineSideInfoView:_delete()
    
end

function GuildWineSideInfoView:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self.ctrl:SendGuildWineActInfo()
end

function GuildWineSideInfoView:CloseViewCallBack()
    self:ClearCounter()
end

function GuildWineSideInfoView:Init()
    self._layout_objs["txt_title"]:SetText(config.words[4738])

    self.txt_time = self._layout_objs["txt_time"]
    self.txt_exp = self._layout_objs["txt_exp"]
    self.txt_people = self._layout_objs["txt_people"]
    self.txt_next = self._layout_objs["txt_next"]
    self.txt_act_info = self._layout_objs["txt_act_info"]

    self.btn_play = self._layout_objs["btn_play"]
    self.btn_play:AddClickCallBack(handler(self, self.OnPlay))

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self.ctrl_state:SetSelectedIndex(0)

    self.tween_map = {}

    local act = game.ActivityMgrCtrl.instance:GetActivities()
    self:SetExpText(0)
end

function GuildWineSideInfoView:StartActCounter(end_time)
    local counter = ViewCounter.Act
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildWine)
    if act and act.state == game.ActivityState.ACT_STATE_PREPARE then
        end_time = act.end_time
    end
    self:CreateCounter(counter, function()
        local time = end_time - global.Time:GetServerTime()
        self.txt_time:SetText(string.format(config.words[4739], game.Utils.SecToTime2(time)))
        if time <= 0 then
            self.txt_time:SetText(string.format(config.words[4739], "00:00"))
            self:StopCounter(counter)
        end
    end)
end

function GuildWineSideInfoView:StartNextCounter(end_time)
    local counter = ViewCounter.Next
    self:CreateCounter(counter, function()
        local time = end_time - global.Time:GetServerTime()
        local subject_name = self:GetSubjectName(self.wine_info.next_subject)
        local show_time = game.Utils.SecToTime2(time)
        local str_format = config.words[4742]

        if subject_name == "" then
            subject_name = config.words[4757]
            show_time = ""
        else
            str_format = str_format .. config.words[4761]
        end

        self.txt_next:SetText(string.format(str_format, subject_name, show_time))
        if time <= 0 then
            self.txt_next:SetText(string.format(str_format, subject_name, show_time))
            self:SetStateCtrl()
            self:StopCounter(counter)
        end
    end)
end

function GuildWineSideInfoView:CreateCounter(name, callback, interval, loops)
    self:StopCounter(name)
    self.tween_map[name] = DOTween:Sequence()
    self.tween_map[name]:AppendCallback(callback)
    self.tween_map[name]:AppendInterval(interval or 1)
    self.tween_map[name]:SetLoops(loops or -1)
    self.tween_map[name]:Play()
end

function GuildWineSideInfoView:StopCounter(name)
    if self.tween_map[name] then
        self.tween_map[name]:Kill(false)
        self.tween_map[name] = nil
    end
end

function GuildWineSideInfoView:ClearCounter()
    for k, v in pairs(ViewCounter) do
        self:StopCounter(v)
    end
end

function GuildWineSideInfoView:Refresh(wine_info)
    self:StartActCounter(wine_info.end_time)
    self:StartNextCounter(wine_info.next_time)

    self:SetExpText(wine_info.exp_get)
    self:SetPeopleText(wine_info.number, wine_info.exp_add_per)
    self:SetPlayText()

    self:SetStateCtrl()
end

function GuildWineSideInfoView:GetMaxAddPer()
    if not self.max_add_per then
        local sort_list = game.Utils.SortByKey(config.guild_wine_act_by_num, function(m, n)
            return m > n
        end)
        if #sort_list > 0 then
            self.max_add_per = sort_list[1].exp_add_per
        end
    end
    return self.max_add_per
end

function GuildWineSideInfoView:SetExpText(exp_get)
    local exp_str = game.Utils.NumberFormat(exp_get, 4, 2, 5)
    self.txt_exp:SetText(string.format(config.words[4740], exp_str))
end

function GuildWineSideInfoView:SetPeopleText(number, exp_add_per)
    self.txt_people:SetText(string.format(config.words[4741], number, exp_add_per, self:GetMaxAddPer()))
end

function GuildWineSideInfoView:SetPlayText()
    local subject = self.wine_info and self.wine_info.cur_subject
    if subject == 0 then
        subject = 1
    end
    local subject_name = self:GetSubjectName(subject, true)
    self.btn_play:SetText(subject_name)
end

function GuildWineSideInfoView:GetSubjectName(subject, is_btn)
    local cfg = config.guild_wine_act_info[subject]
    local name = ""
    if cfg then
        name = is_btn and cfg.name2 or cfg.name
    end
    return name
end

function GuildWineSideInfoView:OnPlay()
    local role_level = game.RoleCtrl.instance:GetRoleLevel()
    local open_lv = config.guild_wine_act.open_lv
    if role_level < open_lv then
        game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1953], open_lv))
        return nil
    end

    local subject = self.wine_info and self.wine_info.cur_subject
    local next_subject = self.wine_info and self.wine_info.next_subject
    if subject == 0 then
        if next_subject ~= 0 then
            game.GameMsgCtrl.instance:PushMsg(self:GetSubjectName(next_subject)..config.words[4758])
        end
    elseif subject == 1 then
        self.ctrl:OpenGuildWineAnswerView()
    elseif subject == 2 then
        self.ctrl:OpenGuildWineCastDiceView()
    elseif subject == 3 then
        self.ctrl:OpenGuildWineCommentView()
    end
end

function GuildWineSideInfoView:SetStateCtrl()
    local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildWine)
    local wine_info = self.wine_info
    if act and wine_info and wine_info.next_subject == 0 and wine_info.cur_subject == 0 then
        self.ctrl_state:SetSelectedIndex(1)
        if act.state == game.ActivityState.ACT_STATE_PREPARE then
            self.txt_act_info:SetText(config.words[4758])
        else
            self.txt_act_info:SetText(config.words[4759])
        end
    else
        self.ctrl_state:SetSelectedIndex(0)
    end
end

function GuildWineSideInfoView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateWineInfo] = function(data)
            self.wine_info = data
            self:Refresh(data)
        end,
        [game.GuildEvent.UpdateWineExp] = function(exp_get)
            if self.wine_info then
                self.wine_info.exp_get = exp_get
            end
            self:SetExpText(exp_get)
        end,
        [game.GuildEvent.UpdateWineNumber] = function(data)
            if self.wine_info then
                self.wine_info.number = data.number
                self.wine_info.exp_add_per = data.exp_add_per
            end
            self:SetPeopleText(data.number, data.exp_add_per)
        end,
        [game.GuildEvent.UpdateWineNextSubject] = function(data)
            if self.wine_info then
                self.wine_info.cur_subject = data.cur_subject
                self.wine_info.next_subject = data.next_subject
                self.wine_info.next_time = data.next_time
            end
            self:SetPlayText()
            self:StartNextCounter(data.next_time)
        end,
        [game.GuildEvent.OnActStateChange] = function(act_id, state)
            if act_id == game.ActivityId.GuildWine and state == game.ActivityState.ACT_STATE_ONGOING then
                self.ctrl:SendGuildWineActInfo()
            end
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildWineSideInfoView
