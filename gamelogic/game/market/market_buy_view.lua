local MarketBuyView = Class(game.BaseView)

local PageIndex = {
    Normal = 0,
    Rare = 1,
    RareGoods = 2,
}

local PetTypeImage = { "zs_wai", "zs_nei", "zs_ping" }

function MarketBuyView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_buy_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function MarketBuyView:_delete()
    
end

function MarketBuyView:OpenViewCallBack(item_info)
    self:Init(item_info)
    self:InitBg()
    self:RegisterAllEvents()
end

function MarketBuyView:CloseViewCallBack()

end

function MarketBuyView:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketFollow, handler(self, self.OnMarketFollow)},
        {game.MarketEvent.OnMarketRarePet, handler(self, self.OnMarketRarePet)},
        {game.MarketEvent.OnMarketRareItem, handler(self, self.OnMarketRareItem)},
        {game.NumberKeyboardEvent.Number, handler(self, self.OnNumberKeyBoard)},
        {game.NumberKeyboardEvent.Close, handler(self, self.OnNumberKeyBoardClose)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketBuyView:Init(item_info)
    self.item_info = item_info
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")

    self.uid = item_info.uid
    self.tag = item_info.tag
    self.cate = self.ctrl:GetTagCateId(self.tag)
    self.id = item_info.id or item_info.cid
    self.price = item_info.price
    self.is_pet = self.ctrl:IsPetCate(self.cate)
    self.price_type = config.market_cate[self.cate].buy_money
    self.item_config = self.is_pet and config.pet[self.id] or config.goods[self.id]
    self.num = item_info.num
    self.rare = self.ctrl:IsRare(self.cate) and 1 or 0

    self.list_star = self._layout_objs.list_star
    self.img_pet_type = self._layout_objs.img_pet_type
    self.img_pet_type:SetVisible(false)

    self.txt_info = self._layout_objs.txt_info

    self.ctrl_color = self:GetRoot():GetController("ctrl_color")
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")

    if self.ctrl:IsEquipItem(self.id) or self.ctrl:IsPetItem(self.id) then
        self:SetPageIndex(PageIndex.Rare)
    elseif not self.ctrl:IsRare(self.cate) then
        self:SetPageIndex(PageIndex.Normal)
    else
        self:SetPageIndex(PageIndex.RareGoods)
    end

    if self.is_pet then
        self.ctrl:SendMarketRarePet(self.uid)

        self.img_pet_type:SetVisible(true)
        self.img_pet_type:SetSprite("ui_common", PetTypeImage[config.pet[self.id].type])
    else
        self.market_item:SetItemInfo(item_info)
        self:SetItemShowInfo(self.id)
        if self.ctrl:IsEquipItem(self.id) then
            self.ctrl:SendMarketRareItem(self.uid)
        end
        if not self.ctrl:IsRare(self.cate) then
            self.txt_info:SetText(config.words[5675])
        end
    end

    self._layout_objs.btn_detail:AddClickCallBack(function()
        if self.is_pet then
            if self.rare_pet_info then
                self.ctrl:OpenPetInfoView(self.rare_pet_info)
            end
        else
            if self.ctrl:IsEquipItem(self.id) then
                game.BagCtrl.instance:OpenBagEquipInfoView(self.rare_item_info)
            else
                game.BagCtrl.instance:OpenTipsView(self.item_info, nil, false)
            end
        end
    end)

    self._layout_objs.img_money:SetSprite("ui_common", config.money_type[self.price_type].icon)

    self._layout_objs.txt_follow:SetText(string.format(config.words[5603], item_info.follower))
    self._layout_objs.txt_name:SetText(self.item_config.name)

    self._layout_objs.btn_minus:AddClickCallBack(function()
        self:SetNumText(self:GetGoodsNum()-1)
    end)

    self._layout_objs.btn_plus:AddClickCallBack(function()
        self:SetNumText(self:GetGoodsNum()+1)
    end)

    self._layout_objs.btn_max:AddClickCallBack(function()
        self:SetNumText(self:GetBuyMaxNum(true))
    end)

    self._layout_objs.txt_num:AddClickCallBack(function()
        game.MainUICtrl.instance:OpenNumberKeyboard(nil, 742)
    end)

    self._layout_objs.btn_follow:AddClickCallBack(function()
        self:OnFollowClick()
    end)

    self._layout_objs.btn_buy:AddClickCallBack(function()
        self:OnBuyClick()
    end)

    self:SetNumText(1)
    self:SetFollowText()
end

function MarketBuyView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5655])
end

function MarketBuyView:SetNumText(val, type)
    if not type then
        val = math.clamp(val, 1, self:GetBuyMaxNum())
        self._layout_objs["txt_num"]:SetText(tostring(val))
    elseif type == 1 then
        val = math.clamp(val, 1, self.num)
        self._layout_objs["txt_num"]:SetText(tostring(val))
    elseif type == 2 then
        self._layout_objs["txt_num"]:SetText(val)
    end
    self:SetPriceText()
end

function MarketBuyView:GetNumText()
    local num = self._layout_objs["txt_num"]:GetText()
    return tonumber(num) or 0
end

function MarketBuyView:GetGoodsNum()
    if self.ctrl:IsEquipItem(self.id) or self.ctrl:IsPetItem(self.id) or self.page_index == PageIndex.RareGoods then
        return 1
    else
        local amt = self._layout_objs["txt_num"]:GetText()
        return tonumber(amt) or 1
    end
end

function MarketBuyView:SetPriceText()
    local price = math.floor(self:GetGoodsNum()) * self.price
    local can_buy = game.BagCtrl.instance:GetMoneyByType(self.price_type) >= price
    self.ctrl_color:SetSelectedIndexEx(can_buy and 0 or 1)
    self._layout_objs["txt_cost"]:SetText(price)
end

function MarketBuyView:GetPrice()
    return math.floor(self:GetGoodsNum()) * self.price
end

function MarketBuyView:GetBuyMaxNum(can_buy)
    local num = self.num
    if can_buy then
        local money = game.BagCtrl.instance:GetMoneyByType(self.price_type)
        local price = self.price
        num = math.min(math.floor(money / price), self.num)
    end
    num = math.max(num, 1)
    return num
end

function MarketBuyView:OnBuyClick()
    local total_price = self:GetPrice()
    local cur_money = game.BagCtrl.instance:GetMoneyByType(self.price_type)
    local buy_func = function()
        self.ctrl:SendMarketBuy(self.uid, self:GetGoodsType(), self.id, self.price, self:GetGoodsNum())
        self:Close()
    end

    if cur_money >= total_price then
        buy_func()
    else
        game.MainUICtrl.instance:OpenAutoMoneyExchangeView(self.price_type, total_price, function()
            buy_func()
        end)
    end
end

function MarketBuyView:OnFollowClick()
    local is_follow = self.ctrl:IsFollow(self.uid)
    self.ctrl:SendMarketFollow(self.uid, is_follow and 0 or 1, self.item_info)
end

function MarketBuyView:SetPageIndex(index)
    self.ctrl_page:SetSelectedIndexEx(index)
    self.page_index = index
end

function MarketBuyView:SetFollowText()
    local is_follow = self.ctrl:IsFollow(self.uid)
    local str = is_follow and config.words[5601] or config.words[5600]
    self._layout_objs.btn_follow:SetText(str)
end

function MarketBuyView:OnMarketFollow(data)
    if data.uid == self.uid then
        self:SetFollowText()
    end
end

function MarketBuyView:GetGoodsType()
    return self.is_pet and 2 or 1
end

function MarketBuyView:OnMarketRarePet(data)
    if data.item.uid == self.uid then
        self.rare_pet_info = data.pet
        self:SetPetShowInfo(data.pet)
        self:SetInfoText(data.pet.sell_times)
    end
end

function MarketBuyView:OnMarketRareItem(data)
    if data.item.uid == self.uid then
        self.rare_item_info = data.goods
        self.rare_item_info.not_show_wear = true
        self:SetItemShowInfo(self.id, data.goods.attr)      
        if self.ctrl:IsRare(self.cate) then
            self:SetInfoText(data.goods.sell_times)
        end
    end
end

function MarketBuyView:SetItemShowInfo(item_id, attr)
    local score = game.Utils.CalculateCombatPower2(config.goods[item_id].attr)
    if attr then
        score =  score + game.Utils.CalculateCombatPower2(attr)
    end
    self._layout_objs.txt_fight:SetText(string.format(config.words[5602], score))
    self._layout_objs.txt_level:SetText(string.format(config.words[5658], config.goods[item_id].lv))
    if config.equip_attr[self.id] then
        self.list_star:SetItemNum(config.equip_attr[self.id].star)
        self.market_item:GetGoodsItem():SetNumText(string.format(config.words[5667], config.goods[self.id].lv))
    end
end

function MarketBuyView:SetPetShowInfo(info)
    self._layout_objs.txt_level:SetText(string.format(config.words[5658], info.level))
    self._layout_objs.txt_fight:SetText(string.format(config.words[5602], game.PetCtrl.instance:CalcFight(info)))
    self.list_star:SetItemNum(info.star)
    self.market_item:SetPetInfo({id = (info.id or info.cid), star = info.star, rare = self.rare})
end

function MarketBuyView:SetInfoText(sell_times)
    local day = math.floor(self.ctrl:GetTradeCD(sell_times) / 24)
    self.txt_info:SetText(string.format(config.words[5674], day))
end

function MarketBuyView:OnNumberKeyBoard(key)
    local num = self:GetNumText()
    if key >= 0 then
        self:SetNumText(num * 10 + key, 1)
    else
        num = math.floor(num / 10)
        local str = (num == 0) and "" or num
        self:SetNumText(str, 2)
    end
end

function MarketBuyView:OnNumberKeyBoardClose()
    self:SetNumText(self:GetNumText())
end

return MarketBuyView
