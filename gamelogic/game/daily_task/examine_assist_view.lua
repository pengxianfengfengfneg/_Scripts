local ExamineAssistView = Class(game.BaseView)

function ExamineAssistView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "examine_assist_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function ExamineAssistView:_delete()

end

function ExamineAssistView:OpenViewCallBack(data)
    self.data = data
    self:Init()
    self:InitBg()
    self:RefreshQuestion()
    self:RegisterAllEvents()
end

function ExamineAssistView:CloseViewCallBack()
    self:StopCloseCounter()
    self:StopNextCounter()
end

function ExamineAssistView:Init()
    self.txt_question = self._layout_objs["txt_question"]
    
    for i=1, 4 do
        local option = "option"..i
        self[option] = self:GetTemplate("game/guild/item/guild_answer_option_item", option)
    end
end

function ExamineAssistView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5141]):HideBtnBack()
end

function ExamineAssistView:RefreshQuestion()
    local quest_cfg = config.examine_bank[self.data.quest_id]
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
    self.click_option = nil
end

function ExamineAssistView:OnOptionClick(quest_cfg, option)
    if not self.click_option then
        option:SetSelected(true)

        local answer_index = option:GetOptionIndex()
        self["option"..answer_index]:SetOptionType(answer_index == quest_cfg.answer and 1 or 2)

        if answer_index == quest_cfg.answer then
            self:AnswerRight(option:GetOptionContent())
        else
            self:AnswerWrong()
        end
        self.click_option = option
    end
end

function ExamineAssistView:AnswerRight(content)
    local help_tag = self.ctrl:GetExamineHelpTag(self.data)
    if help_tag ~= 1 then
        local assist_chat_id = config.examine_info.assist_chat_id
        local href_params = {
            role_id = self.data.role_id,
            answer_num = self.data.answer_num,
            quest_id = self.data.quest_id,
            name = self.data.name,
            time = self.data.time,
            answer_role_id = game.Scene.instance:GetMainRoleID(),
            answer_name = game.Scene.instance:GetMainRoleName(),
        }
        local params = {
            channel = game.ChatChannel.Guild,
            content = "",
            extra = assist_chat_id.."|"..serialize(href_params),
        }
        game.ChatCtrl.instance:SendChatPublic(params)
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[5143])
    end
    self:StartCloseCounter()
end

function ExamineAssistView:AnswerWrong()
    local help_tag = self.ctrl:GetExamineHelpTag(self.data)
    if help_tag ~= 1 then
        self:StartNextCounter()
        game.GameMsgCtrl.instance:PushMsg(config.words[5160])
    else
        self:StartCloseCounter()
        game.GameMsgCtrl.instance:PushMsg(config.words[5143])
    end
end

function ExamineAssistView:StartCloseCounter()
    local end_time = global.Time:GetServerTime() + 2
    self.close_tween = DOTween:Sequence()
    self.close_tween:AppendCallback(function()
        local time = end_time - global.Time:GetServerTime()
        if time <= 0 then
            self:Close()
            self:StopCloseCounter()
        end
    end)
    self.close_tween:AppendInterval(1)
    self.close_tween:SetLoops(-1)
    self.close_tween:Play()
end

function ExamineAssistView:StopCloseCounter()
    if self.close_tween then
        self.close_tween:Kill(false)
        self.close_tween = nil
    end
end

function ExamineAssistView:StartNextCounter()
    local end_time = global.Time:GetServerTime() + 2
    self.next_tween = DOTween:Sequence()
    self.next_tween:AppendCallback(function()
        local time = end_time - global.Time:GetServerTime()
        if time <= 0 then
            self:RefreshQuestion()
            self:StopNextCounter()
        end
    end)
    self.next_tween:AppendInterval(1)
    self.next_tween:SetLoops(-1)
    self.next_tween:Play()
end

function ExamineAssistView:StopNextCounter()
    if self.next_tween then
        self.next_tween:Kill(false)
        self.next_tween = nil
    end
end

function ExamineAssistView:RegisterAllEvents()
    local events = {
        
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return ExamineAssistView
