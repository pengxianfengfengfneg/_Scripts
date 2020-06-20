local MarketGoodsView = Class(game.BaseView)

local PageIndex = {
    NormalGoods = 0,
    RareGoods = 1,
    Rare = 2,
    NormalEquip = 3,
}

local PutIndex = {
    Put = 0,
    TakeOff = 1,
}

local ReferIndex = {
    None = 0,
    Refer = 1,
}

local SellIndex = {
    None = 0,
    Presell = 1,
    Expire = 2,
}

local PetTypeImage = { "zs_wai", "zs_nei", "zs_ping" }

local SearchType = 2

function MarketGoodsView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_goods_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self:AddPackage("ui_pet")
end

function MarketGoodsView:_delete()
    
end

function MarketGoodsView:OpenViewCallBack(item_info)
    self.item_info = item_info
    self:Init(item_info)
    self:InitBg()
    self:RegisterAllEvents()
end

function MarketGoodsView:CloseViewCallBack()
    self:StopTakeOffCounter()
end

function MarketGoodsView:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketSearchInfo, handler(self, self.OnMarketSearchInfo)},
        {game.MarketEvent.OnMarketRarePet, handler(self, self.OnMarketRarePet)},
        {game.MarketEvent.OnMarketRareItem, handler(self, self.OnMarketRareItem)},
        {game.MarketEvent.OnMarketRefreshItem, handler(self, self.OnMarketRefreshItem)},
        {game.NumberKeyboardEvent.Number, handler(self, self.OnNumberKeyboard)},
        {game.NumberKeyboardEvent.Close, handler(self, self.OnNumberKeyboardClose)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketGoodsView:Init(item_info)
    self.id = item_info.id or item_info.cid
    self.uid = item_info.uid
    self.tag = item_info.tag
    self.cate = item_info.cate or self.ctrl:GetTagCateId(item_info.tag)
    self.rare = item_info.rare
    self.pos = item_info.pos or item_info.grid
    self.stat = item_info.stat
    self.is_pet = item_info.is_pet or self.ctrl:IsPetCate(self.cate)
    self.num = item_info.num or 1

    self.price_type = config.market_cate[self.cate].buy_money
    self.item_config = self.is_pet and config.market_pet[self.id] or config.market_item[self.id]

    self.put_index = self.uid and PutIndex.TakeOff or PutIndex.Put

    self.last_price = nil

    self:InitCommonGroup()
    self:InitNormalGoodsGroup()
    self:InitNormalEquipGroup()
    self:InitRareGroup()
    self:InitTakeOffGroup()
    self:InitPage()
    self:InitReferList()

    self.ctrl_put:SetSelectedIndexEx(self.put_index)
end

function MarketGoodsView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5648])
    self:GetBgTemplate("common_bg2"):SetTitleName(config.words[5650])
end

--通用
function MarketGoodsView:InitCommonGroup()
    self.txt_name = self._layout_objs.txt_name
    self.txt_level = self._layout_objs.txt_level
    self.txt_fee = self._layout_objs.txt_fee

    self._layout_objs.txt_fee_label:SetText(config.words[5633])
    self._layout_objs.txt_no_goods:SetText(config.words[5661])
    self._layout_objs.img_fee_money:SetSprite("ui_common", config.money_type[game.MoneyType.Copper].icon)

    self.btn_put_on = self._layout_objs.btn_put_on
    self.btn_put_on:AddClickCallBack(function()
        local fee = self:GetFee()
        local cur_money = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Copper)
        local put_func = function()
            self.ctrl:SendMarketPutOn(self:GetGoodsType(), self.pos, self:GetPutPrice(), self:GetTotalNum())
            self:Close()
        end
        if cur_money >= fee then
            put_func()
        else
            game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, fee, function()
                put_func()
            end)
        end
    end)

    self.btn_put_off = self._layout_objs.btn_put_off
    self.btn_put_off:AddClickCallBack(function()
        self.ctrl:SendMarketTakeOff(self.uid)
        self:Close()
    end)

    self.btn_resell = self._layout_objs.btn_resell
    self.btn_resell:AddClickCallBack(function()
        self.ctrl:SendMarketResale(self.uid)
        self:Close()
    end)

    self.ctrl_put = self:GetRoot():GetController("ctrl_put")
    self.ctrl_refer = self:GetRoot():GetController("ctrl_refer")
end

function MarketGoodsView:SetFeeText(total_price)
    total_price = total_price or 0
    local cate_cfg = config.market_cate[self.cate]
    local fee = math.max(math.floor(total_price * cate_cfg.fee_ratio), cate_cfg.min_fee)
    self.txt_fee:SetText(fee)
end

function MarketGoodsView:GetFee()
    local fee =  self.txt_fee:GetText()
    return tonumber(fee) or 0
end

--普通商品
function MarketGoodsView:InitNormalGoodsGroup()
    self._layout_objs.txt_num_label:SetText(config.words[5628])
    self._layout_objs.txt_price_label:SetText(config.words[5649])
    self._layout_objs.txt_base_price:SetText(config.words[5630])

    self._layout_objs.img_unit_price:SetSprite("ui_common", config.money_type[self.price_type].icon)
    self._layout_objs.txt_base_price:SetVisible(self.put_index == PutIndex.Put)

    self._layout_objs.btn_minus_num:AddClickCallBack(function()
        self:SetSellNumText(self:GetSellNum()-1)
    end)

    self._layout_objs.btn_plus_num:AddClickCallBack(function()
        self:SetSellNumText(self:GetSellNum()+1)
    end)

    self._layout_objs.btn_max_num:AddClickCallBack(function()
        self:SetSellNumText(self:GetSellMaxNum())
    end)

    self._layout_objs.btn_minus_price:AddClickCallBack(function()
        self:SetUnitPriceText(self:GetUnitPriceNum()-self.item_config.step, true)
    end)

    self._layout_objs.btn_plus_price:AddClickCallBack(function()
        self:SetUnitPriceText(self:GetUnitPriceNum()+self.item_config.step, true)
    end)

    self.txt_num = self._layout_objs.txt_num

    self.num_func = function(key)
        local num = self:GetSellNum()
        if key >= 0 then
            self:SetSellNumText(num * 10 + key, 1)
        else
            num = math.floor(num / 10)
            local str = (num == 0) and "" or num
            self:SetSellNumText(str, 2)
        end
    end

    self.num_set_func = function()
        self:SetSellNumText(self:GetSellNum())
    end
    
    self.txt_num:AddClickCallBack(function()
        self.keyboard_func = self.num_func
        self.keyboard_close_func = self.num_set_func
        self:OpenNumberKeyboard()
    end)

    self.txt_unit_price = self._layout_objs.txt_unit_price

    self:SetSellNumText(1)

    if not self.is_pet then
        local base_val = self.item_config.price
        base_val = (base_val == 0) and self.item_config.low or base_val
        self:SetUnitPriceText(base_val)
    end
end

function MarketGoodsView:SetSellNumText(val, type)
    if not type then
        val = math.clamp(val, 1, self:GetSellMaxNum())
        self.txt_num:SetText(tostring(val))
    elseif type == 1 then
        val = math.clamp(val, 1, self:GetSellMaxNum())
        self.txt_num:SetText(tostring(val))
    elseif type == 2 then
        self.txt_num:SetText(val)
    end
    val = tonumber(val) or 0
    self:SetFeeText(val * self:GetUnitPriceNum())
end

function MarketGoodsView:GetSellMaxNum()
    return math.min(self.num, config.market_cate[self.cate].overlap)
end

function MarketGoodsView:GetSellNum()
    local amt = self.txt_num:GetText()
    return tonumber(amt) or 0
end

function MarketGoodsView:SetUnitPriceText(val, clamp)
    if clamp then
        val = math.clamp(val, self.item_config.low, self.item_config.high)
    else
        if val ~= self.last_price then
            if val < self.item_config.low then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5670], self.item_config.low))
            elseif val > self.item_config.high then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5671], self.item_config.high))
            end
        end
    end

    self.last_price = val
    self.txt_unit_price:SetText(val)
    self:SetFeeText(val * self:GetSellNum())
    self:SetBasePriceText(val)
end

function MarketGoodsView:GetUnitPriceNum()
    local unit_price = self.txt_unit_price:GetText()
    return tonumber(unit_price) or 0
end

function MarketGoodsView:SetBasePriceText(price)
    self._layout_objs.txt_base_price:SetText(config.words[5630]..self:GetBasePriceText(price))
end

function MarketGoodsView:GetBasePriceText(price)
    local base_price = self.item_config.price
    local delta = price - base_price
    local str = ""
    if delta ~= 0 and base_price ~= 0 then
        local percent = math.floor(math.abs(delta) / base_price * 100)
        str = (delta > 0) and string.format("+%d%%", percent) or string.format("-%d%%", percent)
    end
    return str
end

--普通装备
function MarketGoodsView:InitNormalEquipGroup()
    self._layout_objs.txt_num_label:SetText(config.words[5628])
    self._layout_objs.txt_price_label3:SetText(config.words[5649])
    self._layout_objs.txt_base_price2:SetText(config.words[5630])

    self._layout_objs.img_price_money2:SetSprite("ui_common", config.money_type[self.price_type].icon)
    self._layout_objs.txt_base_price2:SetVisible(self.put_index == PutIndex.Put)

    self._layout_objs.btn_minus_price2:AddClickCallBack(function()
        self:SetNormalEquipPriceText(self:GetNormalEquipPriceText()-self.item_config.step, true)
    end)

    self._layout_objs.btn_plus_price2:AddClickCallBack(function()
        self:SetNormalEquipPriceText(self:GetNormalEquipPriceText()+self.item_config.step, true)
    end)

    self.txt_price2 = self._layout_objs.txt_price2

    local base_val = self.item_config.price
    base_val = (base_val == 0) and self.item_config.low or base_val
    self:SetNormalEquipPriceText(base_val)
end

function MarketGoodsView:SetNormalEquipPriceText(val, clamp)
    if clamp then
        val = math.clamp(val, self.item_config.low, self.item_config.high)
    else
        if val ~= self.last_price then
            if val < self.item_config.low then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5670], self.item_config.low))
            elseif val > self.item_config.high then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5671], self.item_config.high))
            end
        end
    end

    self.last_price = val
    self.txt_price2:SetText(val)    
    self:SetFeeText(val)

    self._layout_objs.txt_base_price2:SetText(config.words[5630]..self:GetBasePriceText(val))
end

function MarketGoodsView:GetNormalEquipPriceText()
    local price = self.txt_price2:GetText()
    return tonumber(price) or 0
end

--稀有商品
function MarketGoodsView:InitRareGroup()
    self._layout_objs.txt_price_tips:SetText(config.words[5631])
    self._layout_objs.txt_price_label2:SetText(config.words[5632])
    self._layout_objs.txt_fee_label:SetText(config.words[5633])

    self._layout_objs.img_price_money:SetSprite("ui_common", config.money_type[self.price_type].icon)

    self.list_star = self._layout_objs.list_star
    self.txt_fight = self._layout_objs.txt_fight
    self.txt_price = self._layout_objs.txt_price

    self.img_pet_type = self._layout_objs.img_pet_type
    self.img_pet_type:SetVisible(false)

    self.price_func = function(key)
        local num = self:GetPriceNum()
        if key >= 0 then
            self:SetPriceNum(num * 10 + key, 1)
        else
            num = math.floor(num / 10)
            local str = (num == 0) and "" or num
            self:SetPriceNum(str, 2)
        end
    end
    self.price_set_func = function()
        self:SetPriceNum(self:GetPriceNum())
    end
    
    self.txt_price:AddClickCallBack(function()
        self.keyboard_func = self.price_func
        self.keyboard_close_func = self.price_set_func
        self:OpenNumberKeyboard()
    end)

    local base_val = self.item_config.price
    base_val = (base_val == 0) and self.item_config.low or base_val
    self:SetPriceNum(base_val)
end

function MarketGoodsView:GetPriceNum()
    local num = self.txt_price:GetText()
    return tonumber(num) or 0
end

function MarketGoodsView:SetPriceNum(val, type)
    if not type then
        if val ~= self.last_price then
            if val < self.item_config.low then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5670], self.item_config.low))
            elseif val > self.item_config.high then
                game.GameMsgCtrl.instance:PushMsg(string.format(config.words[5671], self.item_config.high))
            end
            val = math.clamp(val, self.item_config.low, self.item_config.high)
            self.last_price = val
            self.txt_price:SetText(val)
        end
    elseif type == 1 then
        val = math.clamp(val, self.item_config.low, self.item_config.high)
        self.txt_price:SetText(val)
    elseif type == 2 then
        self.txt_price:SetText(val)
    end
    val = tonumber(val) or 0
    self:SetFeeText(val)
end

function MarketGoodsView:InitTakeOffGroup()
    self._layout_objs.txt_take_off_num:SetText(self.item_info.num)
    self._layout_objs.txt_take_off_price:SetText(self.item_info.price)

    self._layout_objs.txt_price_label4:SetText(config.words[5632])
    self._layout_objs.img_price_money3:SetSprite("ui_common", config.money_type[self.price_type].icon)
    self._layout_objs.txt_price3:SetText(self.item_info.price)

    self.ctrl_sell = self:GetRoot():GetController("ctrl_sell")

    self:RefreshTakeOffGroup()
end

function MarketGoodsView:RefreshTakeOffGroup(data)
    if self.stat == 1 then
        self.ctrl_sell:SetSelectedIndexEx(SellIndex.Presell)
    elseif self.stat == 3 then
        self.ctrl_sell:SetSelectedIndexEx(SellIndex.Expire)
    else
        self.ctrl_sell:SetSelectedIndexEx(SellIndex.None)
    end
  
    if self.put_index == PutIndex.TakeOff then
        self.btn_resell:SetEnable(self.stat == 3)
    end

    self:StartTakeOffCounter()
end

function MarketGoodsView:StartTakeOffCounter()
    local end_time = self.item_info.end_time
    if end_time then
        self.tw_take_off = DOTween:Sequence()
        self.tw_take_off:AppendCallback(function()
            local time = math.max(0, end_time - global.Time:GetServerTime())
            local strmt = ""
            if self.stat == 1 then
                strmt = config.words[5668]
            elseif self.stat == 2 then
                strmt = config.words[5666]
            elseif self.stat == 3 then
                strmt = config.words[5673]
            end
            self._layout_objs.txt_off_time:SetText(string.format(strmt, self.ctrl:SecToTime(time)))
            if time <= 0 then
                self:StopTakeOffCounter()
                if self.stat == 3 then
                    self._layout_objs.txt_off_time:SetText(config.words[5676])
                end
            end
        end)
        self.tw_take_off:AppendInterval(1)
        self.tw_take_off:SetLoops(-1)
        self.tw_take_off:Play()
    end
end

function MarketGoodsView:StopTakeOffCounter()
    if self.tw_take_off then
        self.tw_take_off:Kill(false)
        self.tw_take_off = nil
    end
end

function MarketGoodsView:InitPage()
    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    if self.ctrl:IsEquipItem(self.id) or self.ctrl:IsPetItem(self.id) then
        if self.ctrl:IsRare(self.cate) then
            self:SetPageIndex(PageIndex.Rare)
        else
            self:SetPageIndex(PageIndex.NormalEquip)
        end
    elseif not self.ctrl:IsRare(self.cate) then
        self:SetPageIndex(PageIndex.NormalGoods)
    else
        self:SetPageIndex(PageIndex.RareGoods)
    end

    if self.ctrl:IsEquipItem(self.id) then
        self:SetEquipItem()
    elseif self.ctrl:IsPetItem(self.id) then
        self:SetPetItem()
    else
        self:SetItem()
    end
end

function MarketGoodsView:SetPetItem()
    local pet_cfg = config.pet[self.id]
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")
    self.market_item:SetPetInfo(self.item_info)
    self.market_item:AddClickEvent(handler(self, self.ShowDetailInfo))

    self.txt_name:SetText(pet_cfg.name)

    if self.uid and self.uid ~= 0 then
        self.ctrl:SendMarketRarePet(self.uid)
    else
        self:SetPetShowInfo(self.item_info)
        self.rare_pet_info = self.item_info
    end

    self.img_pet_type:SetVisible(true)
    self.img_pet_type:SetSprite("ui_common", PetTypeImage[pet_cfg.type])
end

function MarketGoodsView:SetEquipItem()
    self:SetItem()
end

function MarketGoodsView:SetItem()
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")
    self.market_item:SetItemInfo(self.item_info)
    self.market_item:AddClickEvent(handler(self, self.ShowDetailInfo))

    local goods = config.goods[self.id]
    self.txt_name:SetText(goods.name)
    self:SetItemShowInfo(self.id, self.item_info.attr)

    if self.uid and self.uid ~= 0 then
        self.ctrl:SendMarketRareItem(self.uid)
    else
        self.rare_item_info = self.item_info
        self.rare_item_info.not_show_wear = true
    end
end

function MarketGoodsView:SetPageIndex(index)
    self.ctrl_page:SetSelectedIndexEx(index)
    self.page_index = index
end

function MarketGoodsView:GetGoodsType()
    if self.ctrl:IsPetItem(self.id) then
        return 2
    else
        return 1
    end
end

function MarketGoodsView:GetPutPrice()
    if (self.page_index == PageIndex.NormalGoods) or (self.page_index == PageIndex.RareGoods) then
        return self:GetUnitPriceNum()
    else
        if self.page_index == PageIndex.Rare then
            return self:GetPriceNum()
        elseif self.page_index == PageIndex.NormalEquip then
            return self:GetNormalEquipPriceText()
        end
    end
end

function MarketGoodsView:GetTotalNum()
    if self.page_index == PageIndex.NormalGoods or (self.page_index == PageIndex.RareGoods) then
        return self:GetSellNum()
    else
        return 1
    end
end

function MarketGoodsView:InitReferList()
    self.list_refer = self:CreateList("list_refer", "game/market/item/market_refer_item")
    self.list_refer:SetRefreshItemFunc(function(item, idx)
        local item_info = self.refer_list_data[idx]
        item:SetItemInfo(item_info)
        item:AddClickEvent(function()
            self:OnReferClick(item_info)
        end)
    end)
    self.list_refer:SetItemNum(0)

    if self.put_index == PutIndex.Put then
        self.ctrl:SendMarketSearch(self.tag, self.id, SearchType)
    end
end

function MarketGoodsView:OnMarketSearchInfo(data)
    if data.id == self.id and data.tag == self.tag and data.stat == SearchType then
        local item_list = self.ctrl:GetMarketSearchItemsById(self.id, SearchType)
        table.sort(item_list, function(m, n)
            return m.price > n.price
        end)

        self.refer_list_data = {}
        for i=1, 5 do
            if item_list[i] then
                table.insert(self.refer_list_data, item_list[i])
            else
                break
            end
        end

        local num = #self.refer_list_data
        self.list_refer:SetItemNum(num)
        self.ctrl_refer:SetSelectedIndexEx((num == 0) and ReferIndex.None or ReferIndex.Refer)
    end
end

function MarketGoodsView:OnMarketRarePet(data)
    if data.item.uid == self.uid then
        self.rare_pet_info = data.pet
        self:SetPetShowInfo(data.pet)
    elseif self.req_refer_info and data.item.uid == self.req_refer_info.uid then
        self.ctrl:OpenPetInfoView(data.pet)
        self.req_refer_info = nil
    end
end

function MarketGoodsView:OnMarketRareItem(data)
    if data.item.uid == self.uid then
        self.rare_item_info = data.goods
        self.rare_item_info.not_show_wear = true
        self:SetItemShowInfo(self.id, data.goods.attr)
    elseif self.req_refer_info and data.item.uid == self.req_refer_info.uid then
        if self.ctrl:IsEquipItem(data.item.id) then
            local info = data.goods
            info.not_show_wear = true
            game.BagCtrl.instance:OpenBagEquipInfoView(info)
        else
            game.BagCtrl.instance:OpenTipsView(data.goods, nil, false)
        end
        self.req_refer_info = nil
    end
end

function MarketGoodsView:SetItemShowInfo(item_id, attr)
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

function MarketGoodsView:SetPetShowInfo(info)
    self._layout_objs.txt_level:SetText(string.format(config.words[5658], info.level))
    self._layout_objs.txt_fight:SetText(string.format(config.words[5602], game.PetCtrl.instance:CalcFight(info)))
    self.list_star:SetItemNum(info.star)
end

function MarketGoodsView:OnReferClick(item_info)
    if self.is_pet then
        self.ctrl:SendMarketRarePet(item_info.uid)
        self.req_refer_info = item_info
    else
        if self.ctrl:IsEquipItem(item_info.id) then
            self.ctrl:SendMarketRareItem(item_info.uid)
            self.req_refer_info = item_info
        else
            game.BagCtrl.instance:OpenTipsView(item_info, nil, false)
        end
    end
end

function MarketGoodsView:ShowDetailInfo()
    if self.ctrl:IsEquipItem(self.id) then
        if self.rare_item_info then
            game.BagCtrl.instance:OpenBagEquipInfoView(self.rare_item_info)
        end
    elseif self.ctrl:IsPetItem(self.id) then
        if self.rare_pet_info then
            self.ctrl:OpenPetInfoView(self.rare_pet_info)
        end
    else
        game.BagCtrl.instance:OpenTipsView(config.goods[self.id], nil, false)
    end
end

function MarketGoodsView:OnMarketRefreshItem(data)
    if data.uid == self.uid then
        if data.stat > 3 then
            self:Close()
            return
        end
        self.stat = data.stat
        self.end_time = data.end_time
        self:RefreshTakeOffGroup()
    end
end

function MarketGoodsView:OnNumberKeyboard(key)
    if self.keyboard_func then
        self.keyboard_func(key)
    end
end

function MarketGoodsView:OpenNumberKeyboard()
    game.MainUICtrl.instance:OpenNumberKeyboard(156, 311)
    self._layout_objs.group_refer:SetVisible(false)
end

function MarketGoodsView:OnNumberKeyboardClose()
    self._layout_objs.group_refer:SetVisible(true)
    if self.keyboard_close_func then
        self.keyboard_close_func()
    end
end

return MarketGoodsView
