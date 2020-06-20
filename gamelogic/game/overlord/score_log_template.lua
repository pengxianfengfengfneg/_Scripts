local OverlordLogTemplate = Class(game.UITemplate)

function OverlordLogTemplate:SetLogList(log_list)
    local list = self:CreateList("list", "game/overlord/item/overlord_log_item")
    list:SetRefreshItemFunc(function(item, idx)
        local item_data = log_list[idx]
        item:SetRoleInfo(item_data)
        item:SetBg(idx % 2 == 1)
    end)
    list:SetItemNum(#log_list)
end

return OverlordLogTemplate