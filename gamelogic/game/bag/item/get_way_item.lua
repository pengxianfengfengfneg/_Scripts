local GetWayItem = Class(game.UITemplate)

function GetWayItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        if self.click_func then
            self.click_func(self.item_id)
        end
    end)
end

function GetWayItem:SetItemInfo(info, item_id)
    self.item_id = item_id
    self._layout_objs.name:SetText(info.name)
end

function GetWayItem:AddClickEvent(func)
    self.click_func = func
end

function GetWayItem:SetGoVisible(val)
    self._layout_objs.go:SetVisible(val)
end

return GetWayItem