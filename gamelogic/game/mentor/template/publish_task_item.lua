local PublishTaskItem = Class(game.UITemplate)

function PublishTaskItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function PublishTaskItem:OpenViewCallBack()
    self.txt_name = self._layout_objs["txt_name"]

    self.img_bg = self._layout_objs["img_bg"]
    self.img_bg2 = self._layout_objs["img_bg2"]
    self.img_select = self._layout_objs["img_select"]

    self.btn_checkbox = self._layout_objs["btn_checkbox"]
    self.btn_checkbox:SetEnable(false)
    self.btn_checkbox:SetGray(false)

    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event(self)
        end
    end)
end

function PublishTaskItem:SetItemInfo(item_info, idx)
    self.info = item_info
    self.txt_name:SetText(item_info.desc)
    self.img_bg:SetVisible(idx%2==1)
    self.img_bg2:SetVisible(idx%2==0)
end

function PublishTaskItem:SetSelected(val)
    self.img_select:SetVisible(val)
    self.btn_checkbox:SetSelected(val)
end

function PublishTaskItem:IsSelected()
    return self.btn_checkbox:GetSelected()
end

function PublishTaskItem:AddClickEvent(click_event)
    self.click_event = click_event
end

function PublishTaskItem:GetTaskId()
    if self.info then
        return self.info.id
    end
end

return PublishTaskItem