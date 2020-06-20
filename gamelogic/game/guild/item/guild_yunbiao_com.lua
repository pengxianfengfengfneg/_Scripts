local GuildYunbiaoCom = Class(game.UITemplate)

function GuildYunbiaoCom:_init(idx)
    self.index = idx
end

function GuildYunbiaoCom:OpenViewCallBack()
    self:GetRoot():GetController("c1"):SetSelectedIndexEx(self.index - 1)
    self:InitRewards()

    if self.index == 4 then
        self._layout_objs["bg"]:SetHeight(220)
    else
        self._layout_objs["bg"]:SetHeight(143)
    end
end

function GuildYunbiaoCom:CloseViewCallBack()
    self.ui_list:DeleteMe()
    self.ui_list = nil
end

function GuildYunbiaoCom:InitRewards()
    local drop_id = config.carry_reward[self.index].show_drop
    local award_items = config.drop[drop_id].client_goods_list
    local list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(list)
    self.ui_list:SetVirtual(true)
    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
        item:SetVirtual(obj)
        item:SetShowTipsEnable(true)
        item:Open()
        return item
    end)
    self.ui_list:SetRefreshItemFunc(function (item, idx)
        local item_info = award_items[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
    end)

    self.ui_list:SetItemNum(#award_items)
end

return GuildYunbiaoCom