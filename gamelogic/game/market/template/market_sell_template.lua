local MarketSellTemplate = Class(game.UITemplate)

local TabIndex = {
    Pet = 1,
    Equip = 2,
    Goods = 3,
}

local TabConfig = {
    [TabIndex.Pet] = {
        title = config.words[5642],
        desc = config.words[5640],
    },
    [TabIndex.Equip] = {
        title = config.words[5643],
        desc = config.words[5641],
    },
    [TabIndex.Goods] = {
        title = config.words[5644],
        desc = config.words[5635],
    },
}

function MarketSellTemplate:_init()
    self.ctrl = game.MarketCtrl.instance   
end

function MarketSellTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function MarketSellTemplate:CloseViewCallBack()
    
end

function MarketSellTemplate:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketInfo, handler(self, self.OnMarketInfo)},
        {game.MarketEvent.OnMarketPutOn, handler(self, self.OnMarketPutOn)},
        {game.MarketEvent.OnMarketTakeOff, handler(self, self.OnMarketTakeOff)},
        {game.MarketEvent.UpdatePutList, handler(self, self.OnMarketPutOn)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketSellTemplate:Init()
    self.txt_put_on = self._layout_objs.txt_put_on
    self.txt_market = self._layout_objs.txt_market
    self.txt_tab_info = self._layout_objs.txt_tab_info

    self.btn_detail = self._layout_objs.btn_detail
    self.btn_detail:SetText(config.words[5639])
    self.btn_detail:AddClickCallBack(function()
        self.ctrl:OpenMarketLevelView()
    end)

    self.ctrl_tab = self:GetRoot():AddControllerCallback("ctrl_tab", function(idx)
        self:OnTabClick(idx+1)
    end)
    self.list_tab = self._layout_objs.list_tab
    local tab_num = table.nums(TabConfig)
    self.list_tab:SetItemNum(tab_num)
    for i=1, tab_num do
        self.list_tab:GetChildAt(i-1):SetText(TabConfig[i].title)
    end

    self.btn_log = self._layout_objs.btn_log
    self.btn_log:SetText(config.words[5636])
    self.btn_log:AddClickCallBack(function()
        self.ctrl:OpenMarketLogView()
    end)

    self.btn_operate = self._layout_objs.btn_operate
    self.btn_operate:SetText(config.words[5637])
    self.btn_operate:AddClickCallBack(function()
        self:OnOperateClick()
    end)

    self.list_put = self:CreateList("list_put", "game/market/item/market_goods_item")
    self.list_put:SetRefreshItemFunc(function(item, idx)
        local item_info = self.put_list_data[idx]

        local idx = 0
        if item_info.stat == 1 then
            idx = 2
        elseif item_info.stat == 3 then
            idx = 3
        end

        item:SetItemInfo(item_info, idx)
        item:AddClickEvent(function()
            self.ctrl:OpenMarketGoodsView(item_info)
        end)
        item:SetFollowVisible(false)
    end)
    self.ctrl_put = self:GetRoot():GetController("ctrl_put")

    self:UpdatePutItems()

    self.list_goods = self:CreateList("list_goods", "game/market/item/market_item")
    self.list_goods:SetRefreshItemFunc(function(item, idx)
        local is_pet_idx = (self.tab_idx == TabIndex.Pet)
        local item_info = is_pet_idx and self.pet_list_data[idx] or self.goods_list_data[idx]

        item_info.tag = is_pet_idx and config.market_pet[item_info.cid].tag or config.market_item[item_info.id].tag
        item_info.cate = self.ctrl:GetTagCateId(item_info.tag)
        item_info.rare = config.market_cate[item_info.cate].rare
        item_info.is_pet = is_pet_idx

        if is_pet_idx then
            item:SetPetInfo(item_info)
        else
            item:SetItemInfo({id = item_info.id, num = item_info.num, rare = item_info.rare})
            if config.equip_attr[item_info.id] then
                item:GetGoodsItem():SetNumText(string.format(config.words[5667], config.goods[item_info.id].lv))
            end
        end
        item:AddClickEvent(function()
            self:OnGoodsClick(item, item_info)
        end)

        if item_info.sell_times > 0 then
            local cd_end_time = item_info.sell_time + self.ctrl:GetTradeCD(item_info.sell_times) * 3600
            item:StartMaskTween(item_info.sell_time, cd_end_time)
        else
            item:StopMaskTween()
        end
    end)
    
    self.ctrl_tab:SetSelectedIndexEx(TabIndex.Pet-1)

    self:OnMarketInfo()
end

function MarketSellTemplate:OnTabClick(idx)
    self.txt_tab_info:SetText(TabConfig[idx].desc)
    self.tab_idx = idx
    if idx == TabIndex.Goods then
        self:UpdateBagItems()
    elseif idx == TabIndex.Equip then
        self:UpdateBagEquip()
    elseif idx == TabIndex.Pet then
        self:UpdateBagPet()
    end
end

function MarketSellTemplate:OnMarketInfo()
    local market_info = self.ctrl:GetMarketInfo()
    if market_info then
        local lv = self.ctrl:GetMarketLevel()
        local market_lv_cfg = config.market_level[lv]
        
        self:UpdatePutText()
        self.txt_market:SetText(market_lv_cfg.name .. config.words[5634])
    end
end

function MarketSellTemplate:UpdatePutText()
    local lv = self.ctrl:GetMarketLevel()
    local market_lv_cfg = config.market_level[lv]
    self.txt_put_on:SetText(string.format(config.words[5638], #self.ctrl:GetPutItems(), market_lv_cfg.num))
end

function MarketSellTemplate:UpdatePutItems()
    self.put_list_data = self.ctrl:GetPutItems()
    local num = #self.put_list_data
    self.list_put:SetItemNum(num)
    self.ctrl_put:SetPageCount(num)

    self:UpdatePutText()
end

function MarketSellTemplate:UpdateBagItems()
    self.goods_list_data = self.ctrl:GetBagMarketItems()
    local num = #self.goods_list_data
    self.list_goods:SetItemNum(num)

    self:OnGoodsClick()
end

function MarketSellTemplate:UpdateBagEquip()
    self.goods_list_data = self.ctrl:GetBagMarketEquip()
    local num = #self.goods_list_data
    self.list_goods:SetItemNum(num)

    self:OnGoodsClick()
end

function MarketSellTemplate:UpdateBagPet()
    self.pet_list_data = self.ctrl:GetBagMarketPet()
    local num = #self.pet_list_data
    self.list_goods:SetItemNum(num)

    self:OnGoodsClick()
end

function MarketSellTemplate:OnGoodsClick(item, item_info)
    if self.select_item then
        self.select_item:SetSelect(false)
        self.select_item = item
    end

    self.select_item = item
    if self.select_item then
        self.select_item:SetSelect(true)

        if not self:IsValid(item_info) then
            game.GameMsgCtrl.instance:PushMsg(config.words[5672])
        elseif self.ctrl:IsTradeCD(item_info.sell_time, item_info.sell_times) then
            game.GameMsgCtrl.instance:PushMsgCode(7709)
        else
            self.ctrl:OpenMarketGoodsView(item_info)
        end
    end
end

function MarketSellTemplate:IsValid(item_info)
    if item_info.is_pet then
        return config.market_pet[item_info.cid].valid == 1
    else
        return config.market_item[item_info.id].valid == 1
    end
end

function MarketSellTemplate:OnMarketPutOn()
    self:UpdatePutItems()
    self.ctrl_tab:SetSelectedIndexEx(self.tab_idx-1)
end

function MarketSellTemplate:OnMarketTakeOff()
    self:UpdatePutItems()
    self.ctrl_tab:SetSelectedIndexEx(self.tab_idx-1)
end

function MarketSellTemplate:IsExpireTime(item_info)
    return (global.Time:GetServerTime() >= item_info.end_time)
end

function MarketSellTemplate:OnOperateClick()
    local expire_items = self.ctrl:GetExpirePutItems()
    if #expire_items == 0 then
        game.GameMsgCtrl.instance:PushMsg(config.words[5653])
    else
        self.ctrl:OpenMarketTipsView(1)
    end
end

function MarketSellTemplate:BackPage()
    return false
end

return MarketSellTemplate