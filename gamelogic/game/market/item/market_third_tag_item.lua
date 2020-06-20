local MarketThirdTagItem = Class(game.UITemplate)

function MarketThirdTagItem:_init(ctrl)
    self.ctrl = game.MarketCtrl.instance
end

function MarketThirdTagItem:_delete()

end

function MarketThirdTagItem:OpenViewCallBack()
    self:Init()
    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event()
        end
    end)
end

function MarketThirdTagItem:CloseViewCallBack()

end

function MarketThirdTagItem:Init()
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")
end

function MarketThirdTagItem:SetItemInfo(item_info, search_type)
    self._layout_objs.txt_name:SetText(item_info.name)

    if search_type then
        local items = self.ctrl:GetMarketSearchEquipItems(item_info.tag, item_info.id, search_type)
        local num = self:GetTotalSellNum(items)
        self._layout_objs.txt_num:SetText(string.format(config.words[5664], num))
    else
        local num = #self.ctrl:GetFollowEquipItems(item_info.tag, item_info.id)
        self._layout_objs.txt_num:SetText(string.format(config.words[5665], num))
    end

    local cate = self.ctrl:GetTagCateId(item_info.tag)
    if self.ctrl:IsPetCate(cate) then
        self.market_item:SetPetInfo({id = item_info.show_icon, rare = config.market_cate[cate].rare})
    else
        self.market_item:SetItemInfo({id = item_info.show_icon, rare = config.market_cate[cate].rare})
    end
end

function MarketThirdTagItem:AddClickEvent(click_event)
    self.click_event = click_event
end

function MarketThirdTagItem:GetTotalSellNum(items)
    local count = 0
    for k, v in ipairs(items or game.EmptyTable) do
        count = count + v.num
    end
    return count
end

return MarketThirdTagItem