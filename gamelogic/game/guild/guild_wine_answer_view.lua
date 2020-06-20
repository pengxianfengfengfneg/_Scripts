local GuildWineAnswerView = Class(game.BaseView)

function GuildWineAnswerView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_wine_answer_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self:AddPackage("ui_daily_task")
end

function GuildWineAnswerView:_delete()
    
end

function GuildWineAnswerView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendQuestionInfo()
end

function GuildWineAnswerView:CloseViewCallBack()
    self:StopTimeCounter()
    self:StopNextCounter()
    self:DelCloseTimer()
    self:CloseChatVoice()
end

function GuildWineAnswerView:Init()
    self.txt_title = self._layout_objs["txt_title"]    
    self.txt_time = self._layout_objs["txt_time"]    
    self.txt_question = self._layout_objs["txt_question"]
    self.txt_summary = self._layout_objs["txt_summary"]

    self._layout_objs["txt_help"]:SetText(config.words[4744])

    self.btn_voice = self._layout_objs["btn_voice"]
    self.btn_voice:SetTouchBeginCallBack(function(x, y)
        if game.VoiceMgr:InitEngine() then
            self:OpenChatVoice()
        end
    end)
    self.btn_voice:SetTouchEndCallBack(function(x, y)
        self:CloseChatVoice()
    end)
    self.btn_voice:SetTouchRollOutCallBack(function(x, y)
        self:CancelChatVoice()
    end)

    self.chat_voice_com = self._layout_objs["chat_voice_com"]

    for i=1, 4 do
        local option = "option"..i
        self[option] = self:GetTemplate("game/guild/item/guild_answer_option_item", option)
        self[option]:SetOptionType(0)
    end

    self.ctrl_index = self:GetRoot():GetController("ctrl_index")
    self:SetIndexCtrl(0)

    self.max_quest_num = 5
    self.next_interval = 2.2

    self.click_option = nil
    self.click_option_time = nil

    local quest_info = self.ctrl:GetQuestionInfo()
    if quest_info then
        self:Refresh(quest_info)
    end
end

function GuildWineAnswerView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4746]):HideBtnBack()
end

function GuildWineAnswerView:RefreshQuestion(id)
    self:UpdateAnswerInfo(self.quest_info.index, self.quest_info.bingo_num)

    if self.quest_info.index > self.max_quest_num or self.quest_info.state == 2 then
        self:SetIndexCtrl(2)
        return nil
    end

    local quest_cfg = config.question_bank[id]
    self.txt_question:SetText(quest_cfg.question)
    for i=1, 4 do
        local item_info = {
            index = i,
            option = quest_cfg["options"..i],
            option_format = "%s %s",
            type = 0,
        }
        local option = self["option"..i]
        option:SetItemInfo(item_info)
        option:SetClickFunc(function()
            self:OnOptionClick(quest_cfg, option)
        end)
    end

    self:SetIndexCtrl(1)
    self.click_option = nil
end

function GuildWineAnswerView:OnOptionClick(quest_cfg, option)
    if not self.click_option then
        local option_index = option:GetOptionIndex()
        option:SetOptionType(option_index == quest_cfg.answer and 1 or 2)
        option:SetSelected(true)

        local is_right = option_index == quest_cfg.answer
        if not is_right then
            self["option"..quest_cfg.answer]:SetOptionType(1)
        end
        self.click_option = option
        self.click_option_time = global.Time:GetServerTime()

        self.quest_info.index = self.quest_info.index+1
        if is_right then
            self.quest_info.bingo_num = self.quest_info.bingo_num+1
        end

        if self.quest_info.index > self.max_quest_num then
            self:NextQuestion(0)
        end

        self.ctrl:SendQuestionAnswer(option_index)
    end
end

function GuildWineAnswerView:NextQuestion(id)
    self:StopNextCounter()
    local delay = math.max(0, self.click_option_time + self.next_interval - global.Time:GetServerTime())
    self.next_tween = DOTween:Sequence()
    self.next_tween:AppendInterval(delay)
    self.next_tween:AppendCallback(function()
        self:RefreshQuestion(id)
    end)
    self.next_tween:Play()
end

function GuildWineAnswerView:StopNextCounter()
    if self.next_tween then
        self.next_tween:Kill(false)
        self.next_tween = nil
    end
end

function GuildWineAnswerView:StartTimeCounter(end_time)
    if self.time_tween then
        return nil
    end
    self.time_tween = DOTween:Sequence()
    self.time_tween:AppendCallback(function()
        local time = end_time - global.Time:GetServerTime()
        self.txt_time:SetText(string.format(config.words[4754], game.Utils.SecToTime2(time)))
        if time <= 0 then
            self.txt_time:SetText(string.format(config.words[4754], "00:00"))
            self:SetIndexCtrl(2)
            self:StopTimeCounter()
        end
    end)
    self.time_tween:AppendInterval(1)
    self.time_tween:SetLoops(-1)
    self.time_tween:Play()
end

function GuildWineAnswerView:StopTimeCounter()
    if self.time_tween then
        self.time_tween:Kill(false)
        self.time_tween = nil
    end
end

function GuildWineAnswerView:UpdateAnswerInfo(index, bingo_num)
    self.txt_title:SetText(string.format(config.words[4745], math.min(self.max_quest_num, index), self.max_quest_num))

    if index > self.max_quest_num or self.quest_info.state == 2 then
        self.txt_summary:SetText(string.format(config.words[4755], self.max_quest_num, bingo_num))
    else
        self.txt_summary:SetText(string.format(config.words[4763], bingo_num))
    end
end

function GuildWineAnswerView:Refresh(quest_info)
    self:StartTimeCounter(quest_info.end_time)

    if self.click_option then
        self:NextQuestion(quest_info.conf_id)
    else
        self:RefreshQuestion(quest_info.conf_id)
    end
end

function GuildWineAnswerView:OpenChatVoice()
    if not self.chat_voice_template then
        self.chat_voice_template = require("game/chat/chat_voice_template").New(self.ctrl)
        self.chat_voice_template:SetVirtual(self.chat_voice_com)
        self.chat_voice_template:Open()
        self.chat_voice_template:SetChatChannel(game.ChatChannel.Guild)
        self.chat_voice_template:SetVoiceCallback(function()
            game.ChatCtrl.instance:OpenView(game.ChatChannel.Guild)
        end)
    end
end

function GuildWineAnswerView:CloseChatVoice()
    if self.chat_voice_template then
        self.chat_voice_template:DeleteMe()
        self.chat_voice_template = nil
    end
end

function GuildWineAnswerView:CancelChatVoice()
    if self.chat_voice_template then
        self.chat_voice_template:CancelChatVoice()
    end
end

function GuildWineAnswerView:SetIndexCtrl(index)
    self.ctrl_index:SetSelectedIndex(index)
    if index == 2 then
        self.txt_question:SetText("")
        self:CreateCloseTimer()
    end
end

function GuildWineAnswerView:CreateCloseTimer()
    self:DelCloseTimer()
    self.close_timer = global.TimerMgr:CreateTimer(self.next_interval, function()
        self:Close()
        self.close_timer = nil
        return true
    end)
end

function GuildWineAnswerView:DelCloseTimer()
    if self.close_timer then
        global.TimerMgr:DelTimer(self.close_timer)
        self.close_timer = nil
    end
end

function GuildWineAnswerView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateQuestionInfo] = function(quest_info)
            self.quest_info = quest_info
            self:Refresh(quest_info)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildWineAnswerView
