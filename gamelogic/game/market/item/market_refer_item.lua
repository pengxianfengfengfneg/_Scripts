local MarketReferItem = Class(game.UITemplate)

function MarketReferItem:_init(ctrl)
    self.ctrl = game.MarketCtrl.instance
end

function MarketReferItem:_delete()

end

function MarketReferItem:OpenViewCallBack()
    self:Init()
end

function MarketReferItem:Init()
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_price = self._layout_objs["txt_price"]

    self.img_money = self._layout_objs["img_money"]

    self.btn_detail = self._layout_objs["btn_detail"]
    self.btn_detail:SetText(config.words[5660])
    self.btn_detail:AddClickCallBack(handler(self, self.OnDetailClick))
end

function MarketReferItem:SetItemInfo(item_info)
    self.item_info = item_info
    self.id = item_info.id
    self.uid = item_info.uid
    self.tag = item_info.tag
    self.cate = self.ctrl:GetTagCateId(item_info.tag)

    self.is_pet = self.ctrl:IsPetCate(self.cate)
    local cate_config = config.market_cate[self.cate]
    local item_config = self.is_pet and config.pet[self.id] or config.goods[self.id]
    item_info.rare = cate_config.rare

    if self.is_pet then
        self.market_item:SetPetInfo(item_info)
    else
        self.market_item:SetItemInfo({id = item_info.id, rare = cate_config.rare})
        if config.equip_attr[self.id] then
            self.market_item:GetGoodsItem():SetNumText(string.format(config.words[5667], config.goods[self.id].lv))
        end
    end

    self.txt_name:SetText(item_config.name)
    self.txt_price:SetText(item_info.price)

    local money_type = cate_config.buy_money

    self.img_money:SetSprite("ui_common", config.money_type[money_type].icon)
end

function MarketReferItem:OnDetailClick()
    if self.click_event then
        self.click_event()
    end
end

function MarketReferItem:AddClickEvent(click_event)
    self.click_event = click_event
end

return MarketReferItem