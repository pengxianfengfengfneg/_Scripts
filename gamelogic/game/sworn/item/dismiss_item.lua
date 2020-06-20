local DismissItem = Class(game.UITemplate)

function DismissItem:_init(ctrl)
    self.ctrl = game.SwornCtrl.instance
end

function DismissItem:OpenViewCallBack()
    self.txt_senior = self._layout_objs.txt_senior
    self.txt_level = self._layout_objs.txt_level
    self.txt_name = self._layout_objs.txt_name

    self.img_career = self._layout_objs.img_career

    self.head_icon = self:GetIconTemplate("head_icon")
end

function DismissItem:SetItemInfo(item_info, idx)
    self.txt_senior:SetText(self.ctrl:GetSeniorName(item_info.senior))
    self.txt_level:SetText(item_info.lv)
    self.txt_name:SetText(item_info.name)

    self.head_icon:UpdateData(item_info)
    self.img_career:SetSprite("ui_common", "career"..item_info.career)
end

return DismissItem