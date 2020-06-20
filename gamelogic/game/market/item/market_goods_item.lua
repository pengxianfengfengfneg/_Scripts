local MarketGoodsItem = Class(game.UITemplate)

local PageIndex = {
    Buy = 0,
    Presell = 1,
    Preselling = 2,
    Expire = 3,
}

function MarketGoodsItem:_init(ctrl)
    self.ctrl = game.MarketCtrl.instance
end

function MarketGoodsItem:_delete()

end

function MarketGoodsItem:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function MarketGoodsItem:CloseViewCallBack()
    self:StopPresellCounter()
end

function MarketGoodsItem:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketFollow, handler(self, self.OnMarketFollow)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketGoodsItem:Init()
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_price = self._layout_objs["txt_price"]
    self.txt_time = self._layout_objs["txt_time"]

    self.img_money = self._layout_objs["img_money"]
    self.img_follow = self._layout_objs["img_follow"]
    self.img_follow_2 = self._layout_objs["img_follow_2"]

    self.ctrl_color = self:GetRoot():GetController("ctrl_color")

    self.btn_follow = self._layout_objs.btn_follow

    self.img_follow1 = self.btn_follow:GetChild("n1")
    self.img_follow2 = self.btn_follow:GetChild("n2")

    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event()
        end
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
end

function MarketGoodsItem:SetItemInfo(item_info, page_idx)
    self.item_info = item_info
    self.id = item_info.id
    self.uid = item_info.uid
    self.tag = item_info.tag
    self.cate = self.ctrl:GetTagCateId(item_info.tag)

    local is_pet = self.ctrl:IsPetCate(self.cate)
    local cate_config = config.market_cate[self.cate]
    local item_config = is_pet and config.pet[self.id] or config.goods[self.id]
    item_info.rare = cate_config.rare

    if is_pet then
        self.market_item:SetPetInfo({id = (item_info.id or item_info.cid), star = item_info.star, rare = item_info.rare})
    else
        self.market_item:SetItemInfo(item_info)
        if config.equip_attr[self.id] then
            self.market_item:GetGoodsItem():SetNumText(string.format(config.words[5667], config.goods[self.id].lv))
        end
    end

    self.txt_name:SetText(item_config.name)
    self.txt_price:SetText(item_info.price)

    local money_type = cate_config.buy_money
    local color_index = (game.BagCtrl.instance:GetMoneyByType(money_type) >= item_info.price * 1) and 0 or 1
    self.ctrl_color:SetSelectedIndexEx(color_index)

    self.img_money:SetSprite("ui_common", config.money_type[money_type].icon)

    self:SetFollowState()

    self:SetPageIndex(page_idx or PageIndex.Buy)
end

function MarketGoodsItem:OnMarketFollow(data)
    if self.uid == data.uid then
        self:SetFollowState()
    end
end

function MarketGoodsItem:SetFollowState()
    local can_follow = self.ctrl:CanFollow(self.cate) 
    if can_follow then
        local is_follow = self.ctrl:IsFollow(self.uid)
        local index = is_follow and 1 or 0
        self.btn_follow:GetController("ctrl_state"):SetSelectedIndexEx(index)

        local max_value = config.sys_config["market_max_follow"].value
        local cur_value = self.item_info.follower
        if is_follow then
            cur_value = max_value
        end       
        self.img_follow1:SetFillAmount(cur_value / max_value)
        self.img_follow2:SetFillAmount(cur_value / max_value)
    end
    self.btn_follow:SetVisible(can_follow)
end

function MarketGoodsItem:AddClickEvent(click_event)
    self.click_event = click_event
end

function MarketGoodsItem:SetPageIndex(index)
    if index == PageIndex.Buy then
        self:StopPresellCounter()
    elseif index == PageIndex.Presell then
        self:StartPresellCounter()
    end
    self.ctrl_page:SetSelectedIndexEx(index)
end

function MarketGoodsItem:StartPresellCounter()
    self:StopPresellCounter()
    local end_time = self.item_info.end_time
    if end_time then
        self.tw_presell = DOTween:Sequence()
        self.tw_presell:AppendCallback(function()
            local time = math.max(0, end_time - global.Time:GetServerTime())
            self._layout_objs.txt_time:SetText(self.ctrl:SecToTime(time))
            if time <= 0 then
                self:StopPresellCounter()
            end
        end)
        self.tw_presell:AppendInterval(1)
        self.tw_presell:SetLoops(-1)
    end
end

function MarketGoodsItem:StopPresellCounter()
    if self.tw_presell then
        self.tw_presell:Kill(false)
        self.tw_presell = nil
    end
end

function MarketGoodsItem:SetFollowVisible(val)
    self.btn_follow:SetVisible(val)
end

return MarketGoodsItem