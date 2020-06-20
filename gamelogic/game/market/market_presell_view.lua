local MarketPresellView = Class(game.BaseView)

local PageIndex = {
    Rare = 0,
    RareGoods = 1,
}

local PetTypeImage = { "zs_wai", "zs_nei", "zs_ping" }

function MarketPresellView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_presell_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function MarketPresellView:_delete()
    
end

function MarketPresellView:OpenViewCallBack(item_info)
    self:Init(item_info)
    self:InitBg()
    self:RegisterAllEvents()
end

function MarketPresellView:CloseViewCallBack()
    self:StopTimeCounter()
end

function MarketPresellView:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketFollow, handler(self, self.OnMarketFollow)},
        {game.MarketEvent.OnMarketRarePet, handler(self, self.OnMarketRarePet)},
        {game.MarketEvent.OnMarketRareItem, handler(self, self.OnMarketRareItem)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketPresellView:Init(item_info)
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")

    self.item_info = item_info
    self.uid = item_info.uid
    self.tag = item_info.tag
    self.cate = self.ctrl:GetTagCateId(self.tag)
    self.id = item_info.id
    self.price = item_info.price
    self.is_pet = self.ctrl:IsPetCate(self.cate)
    self.price_type = config.market_cate[self.cate].buy_money
    self.item_config = self.is_pet and config.pet[self.id] or config.goods[self.id]

    item_info.presell = (item_info.stat == 1) and 1 or 0
    
    self.list_star = self._layout_objs.list_star
    self.img_pet_type = self._layout_objs.img_pet_type
    self.img_pet_type:SetVisible(false)

    self._layout_objs.txt_price:SetText(self.price)

    if self.is_pet then
        self.market_item:SetPetInfo(item_info)
        self.ctrl:SendMarketRarePet(self.uid)

        self.img_pet_type:SetVisible(true)
        self.img_pet_type:SetSprite("ui_common", PetTypeImage[config.pet[self.id].type])
    else
        self.market_item:SetItemInfo(item_info)
        self:SetItemShowInfo(self.id)
        if self.ctrl:IsEquipItem(self.id) then
            self.ctrl:SendMarketRareItem(self.uid)
        end
    end

    self.txt_time = self._layout_objs.txt_time

    self._layout_objs.btn_detail:AddClickCallBack(function()
        self:OnDetailClick()
    end)

    self._layout_objs.txt_follow:SetText(string.format(config.words[5603], item_info.follower))
    self._layout_objs.txt_name:SetText(self.item_config.name)

    self:SetFollowText()
    self:StartTimeCounter(item_info.end_time)

    self._layout_objs.btn_follow:AddClickCallBack(function()
        self:OnFollowClick()
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")

    if self.ctrl:IsEquipItem(self.id) or self.ctrl:IsPetItem(self.id) then
        self:SetPageIndex(PageIndex.Rare)
    else
        self:SetPageIndex(PageIndex.RareGoods)
    end
end

function MarketPresellView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5659])
end

function MarketPresellView:OnFollowClick()
    local is_follow = self.ctrl:IsFollow(self.uid)
    self.ctrl:SendMarketFollow(self.uid, is_follow and 0 or 1, self.item_info)
end

function MarketPresellView:SetPageIndex(index)
    self.ctrl_page:SetSelectedIndexEx(index)
    self.page_index = index
end

function MarketPresellView:SetFollowText()
    local is_follow = self.ctrl:IsFollow(self.uid)
    local str = is_follow and config.words[5601] or config.words[5600]
    self._layout_objs.btn_follow:SetText(str)
end

function MarketPresellView:StartTimeCounter(end_time)
    self:StopTimeCounter()
    self.tw_time = DOTween:Sequence()
    self.tw_time:AppendCallback(function()
        local time = math.max(0, end_time - global.Time:GetServerTime())
        self.txt_time:SetText(string.format(config.words[5627], self.ctrl:SecToTime(time)))
        if time <= 0 then
            self:StopTimeCounter()
        end
    end)
    self.tw_time:AppendInterval(1)
    self.tw_time:SetLoops(-1)
    self.tw_time:Play()
end

function MarketPresellView:StopTimeCounter()
    if self.tw_time then
        self.tw_time:Kill(false)
        self.tw_time = nil
    end
end

function MarketPresellView:OnMarketFollow(data)
    if data.uid == self.uid then
        self:SetFollowText()
    end
end

function MarketPresellView:OnMarketRarePet(data)
    if data.item.uid == self.uid then
        self.rare_pet_info = data.pet
        self:SetPetShowInfo(data.pet)
    end
end

function MarketPresellView:OnMarketRareItem(data)
    if data.item.uid == self.uid then
        self.rare_item_info = data.goods
        self.rare_item_info.not_show_wear = true
        self:SetItemShowInfo(self.id, data.goods.attr)
    end
end

function MarketPresellView:SetItemShowInfo(item_id, attr)
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

function MarketPresellView:SetPetShowInfo(info)
    self._layout_objs.txt_level:SetText(string.format(config.words[5658], info.level))
    self._layout_objs.txt_fight:SetText(string.format(config.words[5602], game.PetCtrl.instance:CalcFight(info)))
    self.list_star:SetItemNum(info.star)
end

function MarketPresellView:OnDetailClick()
    if self.is_pet then
        if self.rare_pet_info then
            self.ctrl:OpenPetInfoView(self.rare_pet_info)
        end
    else
        if self.ctrl:IsEquipItem(self.id) then
            if self.rare_item_info then
                game.BagCtrl.instance:OpenBagEquipInfoView(self.rare_item_info)
            end
        else
            game.BagCtrl.instance:OpenTipsView(self.item_info, nil, false)
        end
    end
end

return MarketPresellView
