local SwornRegisterView = Class(game.BaseView)

local PageIndex = {
    Question = 0,
    Info = 1,
}

function SwornRegisterView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "register_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full
end

function SwornRegisterView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function SwornRegisterView:Init()
    self.txt_question = self._layout_objs.txt_question
    self.txt_num = self._layout_objs.txt_num

    for i=1, 3 do
        local option = self._layout_objs["option"..i]
        option:AddClickCallBack(function()
            self:OnOptionClick(i)
        end)
        self["option"..i] = option
    end

    self.txt_time = self._layout_objs.txt_time
    self.txt_career = self._layout_objs.txt_career
    self.txt_level = self._layout_objs.txt_level

    self.btn_write = self._layout_objs.btn_write
    self.btn_write:AddClickCallBack(function()
        self:StartRegister()
    end)

    self.btn_ok = self._layout_objs.btn_ok
    self.btn_ok:AddClickCallBack(function()
        local career = self.answer_info[2]
        local level = self.answer_info[3]
        local time = self.answer_info[1]
        
        self.ctrl:SendSwornRegister(career, level, time)
        self:Close()
    end)

    self.answer_info = {}

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self:StartRegister()
end

function SwornRegisterView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6278])
end

function SwornRegisterView:OnOptionClick(idx)
    self.answer_info[self.quest_id] = idx
    self:RefreshQuestion(self.quest_id + 1)
end

function SwornRegisterView:RefreshQuestion(id)
    local register_bank_cfg = config.sworn_register_bank
    local max_quest_num = #register_bank_cfg

    if id <= max_quest_num then
        local quest_info = register_bank_cfg[id]
        self.txt_question:SetText(quest_info.question)
        for i=1, 3 do
            self["option"..i]:SetText(quest_info["option"..i])
        end
        self.txt_num:SetText(string.format(config.words[6292], id, max_quest_num))
        self.quest_id = id
    else
        self:ShowRegisterInfo()
    end
end

function SwornRegisterView:ShowRegisterInfo()
    local register_bank_cfg = config.sworn_register_bank

    self.txt_time:SetText(register_bank_cfg[1]["option"..self.answer_info[1]])
    self.txt_career:SetText(register_bank_cfg[2]["option"..self.answer_info[2]])
    self.txt_level:SetText(register_bank_cfg[3]["option"..self.answer_info[3]])

    self.ctrl_page:SetSelectedIndexEx(PageIndex.Info)
end

function SwornRegisterView:StartRegister()
    self:RefreshQuestion(1)
    self.ctrl_page:SetSelectedIndexEx(PageIndex.Question)
end

return SwornRegisterView
