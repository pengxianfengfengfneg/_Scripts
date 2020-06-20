local DailyGiftTemplate = Class(game.UITemplate)

function DailyGiftTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "daily_gift_template"
end

function DailyGiftTemplate:OpenViewCallBack()
    self:InitGift()
end

function DailyGiftTemplate:InitGift()
    local show_gift = {}
    for _, v in pairs(config.daily_gift) do
        table.insert(show_gift, v)
    end
    table.sort(show_gift, function(a, b)
        return a.grade < b.grade
    end)
    local list = self:CreateList("list", "game/reward_hall/item/daily_gift_item")
    list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(show_gift[idx])
        item:SetBG(idx % 2 == 1)
    end)
    list:SetItemNum(#show_gift)
end

return DailyGiftTemplate