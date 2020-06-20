local HonorListItem = Class(game.UITemplate)

function HonorListItem:OpenViewCallBack()
end

function HonorListItem:SetItemInfo(info)
    if info == nil then
        return
    end
    self.info = info
    table.sort(info, function(a, b)
        return a.level < b.level
    end)
    local color = info[1].color
    self._layout_objs.text:SetText(config.words[1242 + color] .. config.words[3208])

    local list = self:CreateList("list", "game/role/item/honor_item")
    list:SetRefreshItemFunc(function(item, idx)
        local honor_info = info[idx]
        item:SetItemInfo(honor_info)
    end)
    list:SetItemNum(table.nums(info))

    self:GetRoot().height = 50 + 60 * math.ceil(table.nums(info) / 3)
end

return HonorListItem