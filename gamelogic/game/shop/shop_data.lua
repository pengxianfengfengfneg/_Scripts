local ShopData = Class(game.BaseData)
local _table_insert = table.insert
local _table_sort = table.sort
local _shop_cond_config = require("game/shop/shop_cond_config")

function ShopData:_init()
    self.func_shop = {}

    for id, v in pairs(config.shop) do
        local func_id = v.function_id
        self.func_shop[func_id] = self.func_shop[func_id] or {}
        _table_insert(self.func_shop[func_id], v)
    end

    for k, shop_list in pairs(self.func_shop) do
        _table_sort(shop_list, function(m, n)
            return m.sort < n.sort
        end)
    end

    self.item_cate_map = {}
    for cate_id, v in pairs(config.shop_item) do
        for id, cv in pairs(v) do
           self.item_cate_map[id] = self.item_cate_map[id] or {}
           table.insert(self.item_cate_map[id], cv.cate_id) 
        end
    end

    self.page_tag_num = 10
end

function ShopData:SetShopInfo(data)
    self.shop_info = {}
    for k, v in pairs(data.items) do
        if not self.shop_info[v.cate_id] then
            self.shop_info[v.cate_id] = {}
        end
        local item = config.shop_item[v.cate_id][v.item_id]
        self.shop_info[v.cate_id][v.item_id] = item.limit_num - v.num
    end
end

function ShopData:OnShopBuy(data)
    if not self.shop_info[data.cate_id] then
        self.shop_info[data.cate_id] = {}
    end
    self.shop_info[data.cate_id][data.item_id] = data.left
    data.tag_id = self:GetTagIdByCateId(data.cate_id)
    data.shop_id = self:GetShopIdByTagId(data.tag_id)
    self:FireEvent(game.ShopEvent.BuySuccess, data)
end

function ShopData:GetBuyLimitNum(cate_id, item_id)
    if not self.shop_info[cate_id] or not self.shop_info[cate_id][item_id] then
        return config.shop_item[cate_id][item_id].limit_num
    end
    return self.shop_info[cate_id][item_id]
end

function ShopData:IsBuyLimit(cate_id, item_id)
    return config.shop_item[cate_id][item_id].limit_num ~= 0
end

function ShopData:GetShopList(func_id)
    return self.func_shop[func_id]
end

function ShopData:GetTagList(shop_id, page)
    local tag_list = {}
    for k, v in pairs(config.shop_tag[shop_id]) do
        _table_insert(tag_list, v)
    end
    _table_sort(tag_list, function(m, n)
        return m.tag_id < n.tag_id
    end)

    if page then
        local list = {}
        for i=(page-1)*self.page_tag_num+1, #tag_list do
            _table_insert(list, tag_list[i])
        end
        return list
    else
        return tag_list
    end
end

function ShopData:GetPageNum(shop_id)
    local tag_num = table.nums(config.shop_tag[shop_id])
    return math.ceil(tag_num / self.page_tag_num)
end

function ShopData:HaveCate(tag_id)
    return table.nums(config.shop_cate[tag_id]) > 1
end

function ShopData:GetCateList(tag_id)
    local cate_list = {}
    for k, v in pairs(config.shop_cate[tag_id]) do
        _table_insert(cate_list, v)
    end
    _table_sort(cate_list, function(m, n)
        return m.cate_id < n.cate_id
    end)
    return cate_list
end

--获取商品
function ShopData:GetItems(cate_id)
    local item_list = {}
    for k, v in pairs(config.shop_item[cate_id] or {}) do
        if v.hide ~= 1 then
            _table_insert(item_list, v)
        end
    end
    _table_sort(item_list, function(m, n)
        return m.index < n.index
    end)
    return item_list
end

function ShopData:GetTagItems(tag_id)
    local item_list = {}
    local cate_list = self:GetCateList(tag_id)
    for k, v in ipairs(cate_list) do
        local tmp_list = self:GetItems(v.cate_id)
        for _, item in ipairs(tmp_list) do
            _table_insert(item_list, item)
        end
    end
    _table_sort(item_list, function(m, n)
        return m.index < n.index
    end)
    return item_list
end

function ShopData:GetShopItems(shop_id)
    local item_list = {}
    local tag_list = self:GetTagList(shop_id)
    for k, v in ipairs(tag_list) do
        local tmp_list = self:GetTagItems(v.tag_id)
        for _, item in ipairs(tmp_list) do
            _table_insert(item_list, item)
        end
    end
    _table_sort(item_list, function(m, n)
        return m.index < n.index
    end)
    return item_list
end

function ShopData:GetItemCateIdByTagId(tag_id, item_id)
    if not tag_id or not item_id then
        return nil
    end
    local cate_list = self:GetCateList(tag_id)
    for k, v in ipairs(cate_list) do
        local item_list = config.shop_item[v.cate_id]
        if item_list and item_list[item_id] then
            return v.cate_id
        end
    end
end

function ShopData:GetItemCateIdByShopId(shop_id, item_id)
    if not shop_id or not item_id then
        return nil
    end
    local tag_list = self:GetTagList(shop_id)
    for k, v in ipairs(tag_list) do
        local cate_id = self:GetItemCateIdByTagId(v.tag_id, item_id)
        if cate_id then
            return cate_id
        end
    end
end

function ShopData:GetCateTagData(cate_id)
    local tag_id = self:GetTagIdByCateId(cate_id)
    local shop_id = self:GetTagIdByCateId(tag_id)
    return config.shop_tag[shop_id][tag_id]
end

function ShopData:GetCateIdByTagId(tag_id)
    if tag_id then
        return tag_id*10+1
    end
end

function ShopData:GetShopIdByTagId(tag_id)
    if tag_id then
        return math.floor((tag_id - 1)/10)
    end
end

function ShopData:GetTagIdByCateId(cate_id)
    if cate_id then
        return math.floor((cate_id - 1)/10)
    end
end

function ShopData:GetFuncIdByShopId(shop_id)
    local cfg = config.shop[shop_id]
    if cfg then
        return cfg.function_id
    end
end

function ShopData:GetCondMsg(cond, ...)
    if cond then
        local type = cond[1]
        return _shop_cond_config[type].desc_func(cond, ...)
    end
    return ""
end

function ShopData:IsMeetCond(cond, ...)
    if cond then
        local type = cond[1]
        return _shop_cond_config[type].check_func(cond, ...)
    end
    return true
end

function ShopData:CanBuy(item_info)
    if item_info then
        for k, v in ipairs(item_info.conds or game.EmptyTable) do
            if not self:IsMeetCond(v) then
                return false
            end
        end
        if self:IsBuyLimit(item_info.cate_id, item_info.item_id) then
            return self:GetBuyLimitNum(item_info.cate_id, item_info.item_id) > 0
        end
        return true
    end
    return false
end

function ShopData:GetShopIndex(shop_id)
    if not shop_id then
        return nil
    end
    local shop_list = self:GetShopList(config.shop[shop_id].function_id)
    for k, v in ipairs(shop_list) do
        if v.id == shop_id then
            return k
        end
    end
end

function ShopData:GetTagIndex(tag_id)
    if not tag_id then
        return nil
    end
    local shop_id = self:GetShopIdByTagId(tag_id)
    local tag_list = self:GetTagList(shop_id)
    for k, v in ipairs(tag_list) do
        if v.tag_id == tag_id then
            return k
        end
    end
end

function ShopData:GetCateIndex(cate_id)
    if not cate_id then
        return nil
    end
    local tag_id = self:GetTagIdByCateId(cate_id)
    local cate_list = self:GetCateList(tag_id)
    for k, v in ipairs(cate_list) do
        if v.cate_id == cate_id then
            return k
        end
    end
end

function ShopData:GetItemCateList(item_id)
    return self.item_cate_map[item_id] or game.EmptyTable
end

function ShopData:GetMoneyByType(price_type)
    if self:IsMoneyType(price_type) then
        return game.BagCtrl.instance:GetMoneyByType(price_type)
    else
        local item_id = price_type
        return game.BagCtrl.instance:GetNumById(item_id)
    end
    return 0
end

function ShopData:IsMoneyType(price_type)
    return price_type <= 255
end

return ShopData