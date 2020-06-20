local NeidanCommendItem = Class(game.UITemplate)

function NeidanCommendItem:SetItemInfo(info)
    self.info = info

    self._layout_objs.name:SetText(info.name)

    local list = self:CreateList("list", "game/bag/item/goods_item")
    list:SetRefreshItemFunc(function(item, idx)
        local item_id = info.items[idx]
        item:SetItemInfo({id = item_id})
        item:SetShowTipsEnable(true)
    end)
    list:SetItemNum(#info.items)
end

function NeidanCommendItem:SetBg(val)
    self._layout_objs.bg:SetVisible(val)
end

return NeidanCommendItem