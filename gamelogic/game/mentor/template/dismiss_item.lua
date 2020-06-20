local DismissItem = Class(game.UITemplate)

function DismissItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function DismissItem:OpenViewCallBack()
    self.txt_senior = self._layout_objs["txt_senior"]
    self.txt_level = self._layout_objs["txt_level"]
    self.txt_name = self._layout_objs["txt_name"]

    self.img_career = self._layout_objs["img_career"]
    self.head_icon = self:GetIconTemplate("head_icon")

    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event(self.info)
        end
    end)
end

function DismissItem:SetItemInfo(item_info, idx)
    self.info = item_info
    self.head_icon:UpdateData(item_info)

    self.img_career:SetSprite("ui_common", "career"..item_info.career)
    self.txt_level:SetText(item_info.lv)
    self.txt_name:SetText(item_info.name)
    self.txt_senior:SetText(config.mentor_senior[item_info.senior].name)
end

function DismissItem:AddClickEvent(click_event)
    self.click_event = click_event
end

return DismissItem