local MentorRegisterView = Class(game.BaseView)

local PageIndex = {
    Register = 0,
    ShowInfo = 1,
}

local Type = {
    Mentor = 1,
    Prentice = 2,
}

local max_num = table.nums(config.mentor_register_bank)

function MentorRegisterView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "register_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function MentorRegisterView:OpenViewCallBack(type)
    self.type = type
    self:Init()
    self:RegisterAllEvents()
end

function MentorRegisterView:CloseViewCallBack()
    self.answer_list = {}
end

function MentorRegisterView:RegisterAllEvents()
    local events = {
        {game.MentorEvent.OnMentorRegister, handler(self, self.SetMentorRegisterInfo)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MentorRegisterView:Init()
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.ctrl_register = self:GetRoot():GetController("ctrl_register")

    self.btn_write = self._layout_objs["btn_write"]
    self.btn_write:AddClickCallBack(function()
        self:StartRegister()
    end)

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        if self.type == Type.Mentor then
            self.ctrl:SendMentorRegister(1)
        else
            self.ctrl:OpenRecommendView()
        end
    end)

    self.btn_cancel = self._layout_objs["btn_cancel"]
    self.btn_cancel:AddClickCallBack(function()
        self.ctrl:SendMentorRegister(0)
    end)

    self:SetMentorRegisterInfo()

    for i=1, 3 do
        self._layout_objs["option"..i]:AddClickCallBack(function()
            self:OnOptionClick(i)
        end)
    end

    if self.type == Type.Mentor then
        self._layout_objs["txt_desc"]:SetText(config.words[6403])
        self._layout_objs["txt_desc3"]:SetText(config.words[6405])
        self:GetBgTemplate("common_bg"):SetTitleName(config.words[6408])
    else
        self._layout_objs["txt_desc"]:SetText(config.words[6404])
        self._layout_objs["txt_desc3"]:SetText(config.words[6406])
        self:GetBgTemplate("common_bg"):SetTitleName(config.words[6407])
    end

    for i=1, max_num do
        local quest_cfg = self:GetQuestConfig(i)
        self._layout_objs["txt_info"..i]:SetText(quest_cfg.show_info)
    end

    self.answer_list = self:GetAnswerList()
    if #self.answer_list > 0 then
        self:ShowInfo()
    else
        self:StartRegister()
    end
end

function MentorRegisterView:StartRegister()
    self.answer_list = {}
    self:RefreshQuestion(1)
end

function MentorRegisterView:RefreshQuestion(id)
    self.quest_id = id
    if id <= max_num then
        local quest_cfg = self:GetQuestConfig(id)
        self._layout_objs["txt_quest"]:SetText(quest_cfg.quest)
        for i=1, 3 do
            local option_obj = self._layout_objs["option"..i]
            local visible = quest_cfg.option_list[i] ~= nil
            option_obj:SetVisible(visible)
            if visible then
                option_obj:SetText(quest_cfg.option_list[i])
            end
        end
        self._layout_objs["txt_num"]:SetText(string.format(config.words[6402], id, max_num))
        self.ctrl_page:SetSelectedIndexEx(PageIndex.Register)
    else
        self:ShowInfo()
    end
end

function MentorRegisterView:OnOptionClick(id)
    local index = #self.answer_list + 1
    self.answer_list[index] = {index = index, choice = id}
    if index == max_num then
        self.ctrl:SendMentorAnswerQuiz(self.type, self.answer_list)
    end
    self:RefreshQuestion(index+1)
end

function MentorRegisterView:GetQuestConfig(id)
    local bank_info = self.ctrl:GetRegisterBankInfo()
    return self.type==Type.Mentor and bank_info[id].mentor_info or bank_info[id].prent_info
end

function MentorRegisterView:ShowInfo()
    for i=1, max_num do
        local choice = self.answer_list[i].choice
        local option = self:GetQuestConfig(i).option_list[choice]
        self._layout_objs["txt_value"..i]:SetText(option)
    end
    self.ctrl_page:SetSelectedIndexEx(PageIndex.ShowInfo)
end

function MentorRegisterView:SetMentorRegisterInfo()
    local is_registered = self.ctrl:IsMentorRegistered()
    self.ctrl_register:SetSelectedIndexEx((is_registered and self.type==Type.Mentor) and 1 or 0)
    self.btn_ok:SetText(self.type==Type.Mentor and config.words[6421] or config.words[6420])
end

function MentorRegisterView:GetAnswerList()
    local answer_list = {}
    local mentor_info = self.ctrl:GetMentorInfo()
    if mentor_info then
        if self.type == Type.Mentor then
            for k, v in pairs(mentor_info.mentor_quiz_list) do
                table.insert(answer_list, v)
            end
        else
            for k, v in pairs(mentor_info.tudi_quiz_list) do
                table.insert(answer_list, v)
            end
        end
        table.sort(answer_list, function(m, n)
            return m.index < n.index
        end)
    end
    return answer_list
end

return MentorRegisterView
