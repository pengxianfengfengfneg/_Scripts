local SevenLoginItem = Class(game.UITemplate)

function SevenLoginItem:OpenViewCallBack()
    self:Init()
end

function SevenLoginItem:Init()
    self.txt_day = self._layout_objs.txt_day
    self.txt_name = self._layout_objs.txt_name
    self.img_icon = self._layout_objs.img_icon
    self.img_bg = self._layout_objs.img_bg
    self.img_red = self._layout_objs.img_red

    self.ctrl = game.RewardHallCtrl.instance
end

function SevenLoginItem:SetItemInfo(info)
    self.txt_day:SetText(string.format(config.words[3060], info.day))

    if self.ctrl:IsGetLoginReward(info.day) then
        self.txt_name:SetText(string.format(config.words[3059]))
    else
        self.txt_name:SetText(info.name)
    end

    self.img_icon:SetSprite("ui_item", info.icon)
    self.img_bg:SetSprite("ui_common", info.bg)

    self.img_red:SetVisible(self.ctrl:CanGetLoginReward(info.day))
    self:SetGray(self.ctrl:IsGetLoginReward(info.day))
end

function SevenLoginItem:SetGray(val)
    self.img_bg:SetGray(val)
    self.img_icon:SetGray(val)
end

return SevenLoginItem