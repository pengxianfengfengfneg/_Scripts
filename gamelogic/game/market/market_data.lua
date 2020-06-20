
local MarketData = Class(game.BaseData)

function MarketData:_init()
    self._config_market_hot = game.Utils.SortByKey(config.market_hot)
    for k, v in ipairs(self._config_market_hot) do
        table.sort(v, function(m, n)
            return m.id < n.id
        end)
    end

    self._config_market_cd = game.Utils.SortByKey(config.market_cd)

    self.market_items = {}
    self.market_id_items = {}

    self.follow_list = {}
    self.follow_items = {}

    self.cache_items = {}
    self.is_login_data = true
end

function MarketData:SetMarketInfo(data)
    self.market_info = data

    self.put_list = {}
    for k, v in pairs(data.items) do
        local item = v.item
        table.insert(self.put_list, item)
    end

    self.follow_list = {}
    self.follow_items = {}

    for k, v in pairs(data.follow) do
        local item = v.item
        self.follow_list[item.uid] = 1

        if not self.follow_items[item.tag] then
            self.follow_items[item.tag] = {}
        end
        self.follow_items[item.tag][item.uid] = item
    end

    self.cache_items = {}

    self:FireEvent(game.MarketEvent.OnMarketInfo, data)

    if self.is_login_data then
        if #self:GetExpirePutItems() > 0 then
            print("FireEvent:game.MsgNoticeEvent.AddMsgNotice", game.MsgNoticeId.GoodsExpired)
            self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, game.MsgNoticeId.GoodsExpired)
        end
        self.is_login_data = false
    end
end

function MarketData:PutOnItems(items)
    for k, v in pairs(items) do
        local item = v.item
        table.insert(self.put_list, item)
    end
    self:FireEvent(game.MarketEvent.OnMarketPutOn, items)
end

function MarketData:PutOff(uid)
    for k, v in ipairs(self.put_list) do
        if v.uid == uid then
            table.remove(self.put_list, k)
            break
        end
    end
    self:FireEvent(game.MarketEvent.OnMarketTakeOff)
end

function MarketData:GetExpirePutItems()
    local now_time = global.Time:GetServerTime()
    local expire_items = {}
    for k, v in ipairs(self.put_list) do
        if v.stat == 3 then
            table.insert(expire_items, v)
        end
    end
    return expire_items
end

function MarketData:GetFee(cate_id, price, num)
    local cate_cfg = config.market_cate[cate_id]
    return math.max(price * num * cate_cfg.fee_ratio, cate_cfg.min_fee)
end

function MarketData:SetMarketLog(data)
    self.market_log = data
    self:FireEvent(game.MarketEvent.OnMarketLog, data)
end

function MarketData:SetMarketSearchInfo(data)
    if data.id == 0 then
        self.market_items[data.tag] = self.market_items[data.tag] or {}
        self.market_items[data.tag][data.stat] = {}
        for k, v in pairs(data.items) do
            table.insert(self.market_items[data.tag][data.stat], v.item)
        end
        table.sort(self.market_items[data.tag][data.stat], function(m, n)
            return m.price < n.price
        end)
    else
        self.market_id_items[data.id] = self.market_id_items[data.id] or {}
        self.market_id_items[data.id][data.stat] = {}
        for k, v in pairs(data.items) do
            table.insert(self.market_id_items[data.id][data.stat], v.item)
        end
    end
    self:FireEvent(game.MarketEvent.OnMarketSearchInfo, data)
end

function MarketData:GetCateList()
    local cate_list = {}
    for k, v in pairs(config.market_cate) do
        table.insert(cate_list, v)
    end
    table.sort(cate_list, function(m, n)
        return m.id < n.id
    end)
    return cate_list
end

function MarketData:GetTagList(cate)
    local tag_list = {}
    for k, v in pairs(config.market_tag[cate] or {}) do
        table.insert(tag_list, v)
    end
    table.sort(tag_list, function(m, n)
        return m.id < n.id
    end)
    return tag_list
end

function MarketData:IsEquipTag(tag)
    return config.market_equip_tag[tag] ~= nil
end

function MarketData:GetEquipTagList(tag)
    local equip_tag_list = {}
    for k, v in pairs(config.market_equip_tag[tag] or {}) do
        if v.valid == 1 then
            table.insert(equip_tag_list, v)
        end
    end
    table.sort(equip_tag_list, function(m, n)
        return m.id < n.id
    end)
    return equip_tag_list
end

function MarketData:GetPutItems()
    return self.put_list or {}
end

function MarketData:GetMarketSearchItems(tag, stat)
    if self.market_items[tag] then
        return self.market_items[tag][stat] or {}
    end
    return {}
end

function MarketData:GetMarketSearchItemsById(id, stat)
    if self.market_id_items[id] then
        return self.market_id_items[id][stat] or {}
    end
    return {}
end

function MarketData:GetMarketSearchEquipItems(tag, eq_tag, stat)
    local item_list = {}
    for k, v in ipairs(self:GetMarketSearchItems(tag, stat)) do
        local item_cfg = config.market_item[v.id]
        local pet_cfg = config.market_pet[v.id]
        if (item_cfg and item_cfg.eq_tag == eq_tag) or (pet_cfg and pet_cfg.eq_tag == eq_tag) then
            table.insert(item_list, v)
        end
    end
    table.sort(item_list, function(m, n)
        return m.price < n.price
    end)
    return item_list
end

function MarketData:GetHotList()
    local hot_list = nil
    local ro_lv = game.RoleCtrl.instance:GetRoleLevel()
    if config.market_hot[ro_lv] then
        hot_list = config.market_hot[ro_lv]
        table.sort(hot_list, function(m, n)
            return m.id < n.id
        end)
    else
        for k, li in ipairs(self._config_market_hot) do
            if li[1] and ro_lv <= li[1].level then
                hot_list = li
            end
        end
    end
    return hot_list
end

function MarketData:IsPetItem(id)
    return config.market_pet[id] ~= nil
end

function MarketData:IsEquipItem(id)
    return config.equip_attr[id] ~= nil
end

function MarketData:IsRare(cate)
    return config.market_cate[cate].rare == 1
end

function MarketData:GetRareState(cate)
    return config.market_cate[cate].rare
end

function MarketData:GetTagCateId(tag)
    for k, v in pairs(config.market_tag) do
        for _, data in pairs(v) do
            if data.id == tag then
                return data.cate
            end
        end
    end
end

function MarketData:GetTagIdByEquipTag(eq_tag)
    for k, v in pairs(config.market_equip_tag) do
        for _, data in pairs(v) do
            if data.id == eq_tag then
                return data.tag
            end
        end
    end
end

function MarketData:IsRareTag(tag)
    local cate = self:GetTagCateId(tag)
    if config.market_cate[cate].rare == 1 then
        return true
    end
    return false
end

function MarketData:IsPetCate(cate)
    return cate == config.market_cate[2].id
end

function MarketData:CanFollow(cate)
    return config.market_cate[cate].follow == 1
end

function MarketData:IsFollow(uid)
    return self.follow_list[uid] == 1
end

function MarketData:SetMarketFollow(data)
    local item = self:GetCacheItem(data.uid)

    if not item and data.opt == 0 then
        item = self:GetFollowItem(data.uid)
        if not item then
            return
        end
    end

    if data.opt == 1 then
        self.follow_list[data.uid] = data.opt

        self.follow_items[item.tag] = self.follow_items[item.tag] or {}
        if not self.follow_items[item.tag][data.uid] then
            self.follow_items[item.tag][data.uid] = item
        end
    else
        self.follow_list[data.uid] = nil

        if self.follow_items[item.tag] then
            self.follow_items[item.tag][data.uid] = nil
        end
    end

    self:FireEvent(game.MarketEvent.OnMarketFollow, data)
end

function MarketData:GetFollowItem(uid)
    for k, ls in pairs(self.follow_items or {}) do
        for _, v in pairs(ls) do
            if v.uid == uid then
                return v
            end
        end
    end
end

function MarketData:GetFollowItems(tag)
    local item_list = {}
    if tag then
        for k, v in pairs(self.follow_items[tag] or {}) do
            table.insert(item_list, v)
        end
        table.sort(item_list, function(m, n)
            return m.price < n.price
        end)
    else
        for k, ls in pairs(self.follow_items) do
            for i, v in pairs(ls) do
                table.insert(item_list, v)
            end
        end
    end
    return item_list
end

function MarketData:GetFollowEquipItems(tag, eq_tag)
    local item_list = {}
    for k, v in pairs(self:GetFollowItems(tag)) do
        local item_cfg = config.market_item[v.id]
        local pet_cfg = config.market_pet[v.id]
        if (item_cfg and item_cfg.eq_tag == eq_tag) or (pet_cfg and pet_cfg.eq_tag == eq_tag) then
            table.insert(item_list, v)
        end
    end
    table.sort(item_list, function(m, n)
        return m.price < n.price
    end)
    return item_list
end

function MarketData:GetMarketInfo()
    return self.market_info
end

function MarketData:GetMarketLevel()
    local market_info = self.market_info
    local level = 1
    for k, v in ipairs(config.market_level or {}) do
        if market_info.turnover >= v.turnover and market_info.volume >= v.volume then
            if v.level > level then
                level = v.level
            end
        end
    end
    return level
end

function MarketData:GetRareCateList()
    local cate_list = {}
    for k, v in pairs(config.market_cate) do
        if v.rare == 1 then
            table.insert(cate_list, v)
        end
    end
    table.sort(cate_list, function(m, n)
        return m.id < n.id
    end)
    return cate_list
end

function MarketData:GetBagMarketItems()
    local item_list = {}
    local goods_list = game.BagCtrl.instance:GetGoodsBagByBagId(1)
    for _, v in pairs(goods_list.goods) do
        local goods = v.goods
        local cfg = config.market_item[goods.id]
        if cfg and cfg.valid == 1 and goods.bind == 0 and not config.equip_attr[goods.id] then
            table.insert(item_list, goods)
        end
    end
    return item_list
end

function MarketData:GetBagMarketPet()
    local pet_list = {}
    local pets = game.PetCtrl.instance:GetPetInfo()
    for i, v in pairs(pets) do
        local pet = v.pet
        local cfg = config.market_pet[pet.cid]
        if cfg and cfg.valid == 1 and pet.star >= 7 and pet.stat == 0 then   
            table.insert(pet_list, pet)
        end
    end
    return pet_list
end

function MarketData:GetBagMarketEquip()
    local equip_list = {}
    local goods_list = game.BagCtrl.instance:GetGoodsBagByBagId(1)
    for _, v in pairs(goods_list.goods) do
        local goods = v.goods
        local cfg = config.market_item[goods.id]
        if config.equip_attr[goods.id] and cfg and cfg.valid == 1 and goods.bind == 0 then
            table.insert(equip_list, goods)
        end
    end
    return equip_list
end

function MarketData:GetCateIndex(cate)
    local cate_list = self:GetCateList()
    for k, v in ipairs(cate_list) do
        if v.id == cate then
            return k
        end
    end
end

function MarketData:GetTagIndex(tag)
    local cate = self:GetTagCateId(tag)
    local tag_list = self:GetTagList(cate)
    for k, v in ipairs(tag_list) do
        if v.id == tag then
            return k
        end
    end
end

function MarketData:GetEquipTagIndex(tag, eq_tag)
    local eq_list = self:GetEquipTagList(tag)
    for k, v in ipairs(eq_list) do
        if v.id == eq_tag then
            return k
        end
    end
end

function MarketData:CacheItem(item)
    self.cache_items[item.uid] = item
end

function MarketData:GetCacheItem(uid)
    return self.cache_items[uid]
end

function MarketData:GetTradeCD(sell_times)
    for k, v in ipairs(self._config_market_cd) do
        if sell_times <= v.times then
            return v.cd
        end 
    end
end

function MarketData:IsTradeCD(sell_time, sell_times)
    if sell_times == 0 or (global.Time:GetServerTime() > sell_time + self:GetTradeCD(sell_times) * 3600) then
        return false
    end
    return true
end

function MarketData:OnMarketRefreshItem(item)
    if item.stat == 3 then
        self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, game.MsgNoticeId.GoodsExpired)
    end
    for k, v in ipairs(self.put_list) do
        if v.uid == item.uid then
            if item.stat > 3 then
                table.remove(self.put_list, k)
            else
                v = item
            end
            self:FireEvent(game.MarketEvent.UpdatePutList, self.put_list)
            break
        end
    end

    if self.follow_list[item.uid] and item.stat >= 3 then
        self:SetMarketFollow({uid = item.uid, opt = 0})
    end

    if self.cache_items[item.uid] then
        self.cache_items[item.uid] = item
    end

    self:FireEvent(game.MarketEvent.OnMarketRefreshItem, item)
end

function MarketData:IsValid(id)
    local cfg = config.market_item[id] or config.market_pet[id]
    if cfg and cfg.valid == 1 then
        return true
    end
    return false
end

function MarketData:GetFollowNum()
    if self.follow_list then
        return table.nums(self.follow_list)
    end
    return 0
end

return MarketData