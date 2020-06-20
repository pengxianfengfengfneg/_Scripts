local GuildAnswerOptionItem = Class(game.UITemplate)

function GuildAnswerOptionItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildAnswerOptionItem:_delete()

end

function GuildAnswerOptionItem:OpenViewCallBack()
    self:Init()
end

function GuildAnswerOptionItem:CloseViewCallBack()

end

function GuildAnswerOptionItem:Init()
    self.txt_option = self._layout_objs["txt_option"]
    self.img_right = self._layout_objs["img_right"]

    self.ctrl_select = self:GetRoot():GetController("ctrl_select")
    self:GetRoot():AddClickCallBack(handler(self, self.OnClick))
end

function GuildAnswerOptionItem:SetItemInfo(item_info)
    self.item_info = item_info

    local option_map = {"A","B","C","D"}
    local option_format = item_info.option_format or "%s.%s"
    self.txt_option:SetText(string.format(option_format, option_map[item_info.index], item_info.option))
    self.txt_option:SetPositionY(self:GetRoot():GetSize()[2] * 0.5)

    self:SetSelected(item_info.select)
    self:SetOptionType(item_info.type)
end

function GuildAnswerOptionItem:SetSelected(val)
    local index = val and 1 or 0
    self.ctrl_select:SetSelectedIndex(index)
end

function GuildAnswerOptionItem:SetOptionType(type)
    if type == 0 then
        self.img_right:SetVisible(false)
    else
        local sprite = type == 1 and "bh_13" or "bh_14"
        self.img_right:SetVisible(true)
        self.img_right:SetSprite("ui_common", sprite)
    end
end

function GuildAnswerOptionItem:OnClick()
    if self.click_func then
        self.click_func()
    end
end

function GuildAnswerOptionItem:SetClickFunc(click_func)
    self.click_func = click_func
end

function GuildAnswerOptionItem:GetQuestIndex()
    if self.item_info then
        return self.item_info.quest_index
    end
end

function GuildAnswerOptionItem:GetOptionIndex()
    if self.item_info then
        return self.item_info.index
    end
end

function GuildAnswerOptionItem:GetOptionContent()
    if self.item_info then
        return self.item_info.option
    end
end

return GuildAnswerOptionItem
