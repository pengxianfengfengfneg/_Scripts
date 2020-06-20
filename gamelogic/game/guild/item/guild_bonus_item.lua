local GuildBonusItem = Class(game.UITemplate)

function GuildBonusItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildBonusItem:_delete()
end

function GuildBonusItem:OpenViewCallBack()
    self:Init()
end

function GuildBonusItem:CloseViewCallBack()

end

function GuildBonusItem:Init()
    self.txt_title = self._layout_objs.txt_title
    self.txt_bonus = self._layout_objs.txt_bonus
    self.txt_times = self._layout_objs.txt_times    

    self.bar_progress = self._layout_objs.bar_progress
    self.txt_progress = self.bar_progress:GetChild("title")

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
end

function GuildBonusItem:SetItemInfo(item_info)
    self.txt_title:SetText(string.format(config.words[2798], item_info.name, item_info.stage))
    self.txt_bonus:SetText(string.format(config.words[2799], item_info.bonus))
    self.txt_times:SetText(string.format(config.words[4700], item_info.name, item_info.num))

    self.bar_progress:SetProgressValue(item_info.times/item_info.num*100)
    self.txt_progress:SetText(string.format("%d/%d", item_info.times, item_info.num))

    self.ctrl_state:SetSelectedIndexEx(item_info.times < item_info.num and 0 or 1)
end

return GuildBonusItem