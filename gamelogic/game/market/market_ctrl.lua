local MarketCtrl = Class(game.BaseCtrl)

local ViewMap = {
    MarketBuyView = "game/market/market_buy_view",
    MarketGoodsView = "game/market/market_goods_view",
    MarketLogView = "game/market/market_log_view",
    MarketLevelView = "game/market/market_level_view",
    MarketPresellView = "game/market/market_presell_view",
    MarketSearchView = "game/market/market_search_view",
    PetInfoView = "game/market/market_pet_info_view",
    MarketTipsView = "game/market/market_tips_view",
}

function MarketCtrl:_init()
    if MarketCtrl.instance ~= nil then
        error("MarketCtrl Init Twice!")
    end
    MarketCtrl.instance = self

    self.data = require("game/market/market_data").New(self)
    self.view = require("game/market/market_view").New(self)

    for view_name, class in pairs(ViewMap) do
        self[view_name] = require(class).New(self)
        self:CreateViewFunc(view_name)
    end

    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function MarketCtrl:_delete()
    self.data:DeleteMe()
    self.view:DeleteMe()

    for view_name, class in pairs(ViewMap) do
        self[view_name]:DeleteMe()
    end

    MarketCtrl.instance = nil
end

function MarketCtrl:CreateViewFunc(view_name)
    local open_func = "Open"..view_name
    self[open_func] = function(self, ...)
        self[view_name]:Open(...)
    end
    local close_func = "Close"..view_name
    self[close_func] = function(self)
        self[view_name]:Close()
    end
end

function MarketCtrl:PrintTable(data)
    if self.log_enable then
        PrintTable(data)
    end
end

function MarketCtrl:print(...)
    if self.log_enable then
        print(...)
    end
end

function MarketCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, handler(self, self.OnLoginRoleRet)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketCtrl:RegisterAllProtocal()
    local proto = {
        [42502] = "OnMarketInfo",
        [42504] = "OnMarketLog",
        [42506] = "OnMarketSearch",
        [42508] = "OnMarketRareItem",
        [42510] = "OnMarketRarePet",
        [42512] = "OnMarketFollow",
        [42514] = "OnMarketPutOn",
        [42516] = "OnMarketTakeOff",
        [42518] = "OnMarketResale",
        [42520] = "OnMarketBuy",
        [42521] = "OnMarketRefreshItem",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function MarketCtrl:OnLoginRoleRet(val)
    if val then
        self:SendMarketInfo()
    end
end

function MarketCtrl:OpenView(index, ...)
    self.view:Open(index, ...)
end

-- 打开购买页面的一级标签
function MarketCtrl:OpenBuyViewByCateId(cate_id)
    self.view:Open(1, cate_id)
end

-- 打开购买页面的二级标签
function MarketCtrl:OpenBuyViewByTagId(tag_id)
    local cate_id = self:GetTagCateId(tag_id)
    self.view:Open(1, cate_id, tag_id)
end

-- 打开购买页面的三级标签
function MarketCtrl:OpenBuyViewByEqTag(eq_tag)
    local tag_id = self.data:GetTagIdByEquipTag(eq_tag)
    local cate_id = self:GetTagCateId(tag_id)
    self.view:Open(1, cate_id, tag_id, eq_tag)
end

-- 根据物品ID打开购买页面
function MarketCtrl:OpenBuyViewByItemId(item_id)
    local item_config = config.market_item[item_id] or config.market_pet[item_id]
    if item_config then
        local cate_id = self:GetTagCateId(item_config.tag)
        self.view:Open(1, cate_id, item_config.tag, item_config.eq_tag)
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[5677])
    end
end

function MarketCtrl:CloseView()
    self.view:Close()
end

function MarketCtrl:IsOpenView()
    return self.view:IsOpen()
end

function MarketCtrl:JumpToBuyPage(cate, tag, eq_tag)
    if self.view:IsOpen() then
        self.view:JumpToBuyPage(cate, tag, eq_tag)
    end
end

function MarketCtrl:JumpToPresellPage(cate, tag, eq_tag)
    if self.view:IsOpen() then
        self.view:JumpToPresellPage(cate, tag, eq_tag)
    end
end

-- 商会信息
function MarketCtrl:SendMarketInfo()
    self:SendProtocal(42501)
end

function MarketCtrl:OnMarketInfo(data)
    --[[
        "volume__I",                          -- 成交额
        "turnover__I",                        -- 成交量
        "use_gold__I",                        -- 累计使用元宝
        "items__T__item@U|CltMarketGoods|",   -- 上架物品(含过期)
        "follow__T__item@U|CltMarketGoods|",  -- 关注的商品唯一ID
    ]]
    self:PrintTable(data)
    self.data:SetMarketInfo(data)
end

-- 商会日志
function MarketCtrl:SendMarketLog()
    self:SendProtocal(42503)
end

function MarketCtrl:OnMarketLog(data)
    --[[
        "logs__T__time@I",                    
    ]]
    self:PrintTable(data)
    self.data:SetMarketLog(data)
end

-- 获取指定标签商品
function MarketCtrl:SendMarketSearch(tag, id, stat)
    --[[
        "tag__C",                             -- 获取指定标签的商品
        "id__I",                              -- 物品配置ID or 宠物配置ID
        "stat__C",                            -- 指定状态 (必须指定, 1 预售, 2 出售中)
    ]]
    self:SendProtocal(42505, {tag = tag, id = id, stat = stat})
end

function MarketCtrl:OnMarketSearch(data)
    --[[
        "tag__C",                             
        "id__I", 
        "stat__C",                             
        "items__T__item@U|CltMarketGoods|",   
    ]]
    self:PrintTable(data)
    self.data:SetMarketSearchInfo(data)
end

-- 获取稀有物品、装备信息
function MarketCtrl:SendMarketRareItem(uid)
    --[[
        "uid__L",                             -- 唯一ID
    ]]
    self:SendProtocal(42507, {uid = uid})
end

function MarketCtrl:OnMarketRareItem(data)
    --[[ 
        "item__U|CltMarketGoods|",
        "goods__U|GoodsInfo|",
    ]]
    self:PrintTable(data)
    self:FireEvent(game.MarketEvent.OnMarketRareItem, data)
end

-- 获取稀有珍兽信息
function MarketCtrl:SendMarketRarePet(uid)
    --[[
        "uid__L",                             -- 唯一ID
    ]]
    self:SendProtocal(42509, {uid = uid})
end

function MarketCtrl:OnMarketRarePet(data)
    --[[ 
        "item__U|CltMarketGoods|",
        "pet__U|CltPet|",
    ]]
    self:PrintTable(data)
    self:FireEvent(game.MarketEvent.OnMarketRarePet, data)
end

-- 关注
function MarketCtrl:SendMarketFollow(uid, opt, item_info)
    --[[
        "uid__L",                             -- 唯一ID
        "opt__C",                             -- 关注 1; 取消 0
    ]]
        self:SendProtocal(42511, {uid = uid, opt = opt})
        self:CacheItem(item_info)
end

function MarketCtrl:OnMarketFollow(data)
    --[[ 
        "uid__L",
        "opt__C",
    ]]
    self:PrintTable(data)
    self.data:SetMarketFollow(data)
end

-- 上架
function MarketCtrl:SendMarketPutOn(type, pos, price, num)
    --[[
        "type__C",                            -- 物品1 or 宠物2
        "pos__L",                             -- 唯一ID
        "price__I",                           -- 单价
        "num__H",                             -- 数量
    ]]
    self:SendProtocal(42513, {type = type, pos = pos, price = price, num = num})
end

function MarketCtrl:OnMarketPutOn(data)
    --[[ 
        "items__T__item@U|CltMarketGoods|",
    ]]
    self:PrintTable(data)
    self.data:PutOnItems(data.items)
end

-- 下架
function MarketCtrl:SendMarketTakeOff(uid)
    --[[
        "uid__L",                             -- 唯一ID
    ]]
    self:SendProtocal(42515, {uid = uid})
end

function MarketCtrl:OnMarketTakeOff(data)
    --[[ 
        "uid__L",
    ]]
    self:PrintTable(data)
    self.data:PutOff(data.uid)
end

-- 重新上架
function MarketCtrl:SendMarketResale(uid)
    --[[
        "uid__L",                             -- 唯一ID, 0 表示所有
    ]]
    self:SendProtocal(42517, {uid = uid})
end

function MarketCtrl:OnMarketResale(data)
    --[[ 
        "items__T__item@U|CltMarketGoods|",
    ]]
    self:PrintTable(data)
    self.data:SetPutList(data.items)
end

-- 购买
function MarketCtrl:SendMarketBuy(uid, type, id, price, num)
    --[[
        uid__L                              // 唯一ID (仅购买稀有物品)
        type__C                             // 物品1 or 宠物2 (购买普通物品，下同)
        id__I                               // 物品配置ID or 宠物配置ID
        price__I                            // 价格
        num__H                              // 数量
    ]]
    self:SendProtocal(42519, {uid = uid, type = type, id = id, price = price, num = num})
end

function MarketCtrl:OnMarketBuy(data)
    self:PrintTable(data)
    self:FireEvent(game.MarketEvent.OnMarketBuy, data)
end

function MarketCtrl:OnMarketRefreshItem(data)
    -- item__U|CltMarketGoods|				// 物品信息，following 数据无效
    self:PrintTable(data)
    self.data:OnMarketRefreshItem(data.item)
end

function MarketCtrl:GetTagCateId(tag)
    return self.data:GetTagCateId(tag)
end

function MarketCtrl:GetHotList()
    return self.data:GetHotList()
end

function MarketCtrl:GetCateList()
    return self.data:GetCateList()
end

function MarketCtrl:GetTagList(cate)
    return self.data:GetTagList(cate)
end

function MarketCtrl:IsEquipTag(tag)
    return self.data:IsEquipTag(tag)
end

function MarketCtrl:GetEquipTagList(tag)
    return self.data:GetEquipTagList(tag)
end

function MarketCtrl:GetPutItems()
    return self.data:GetPutItems()
end

function MarketCtrl:GetMarketSearchItems(tag, stat)
    return self.data:GetMarketSearchItems(tag, stat)
end

function MarketCtrl:GetMarketSearchItemsById(id, stat)
    return self.data:GetMarketSearchItemsById(id, stat)
end

function MarketCtrl:GetMarketSearchEquipItems(tag, eq_tag, stat)
    return self.data:GetMarketSearchEquipItems(tag, eq_tag, stat)
end

function MarketCtrl:IsPetItem(id)
    return self.data:IsPetItem(id)
end

function MarketCtrl:IsEquipItem(id)
    return self.data:IsEquipItem(id)
end

function MarketCtrl:IsPetCate(cate)
    return self.data:IsPetCate(cate)
end

function MarketCtrl:IsRare(cate)
    return self.data:IsRare(cate)
end

function MarketCtrl:IsRareTag(tag)
    return self.data:IsRareTag(tag)
end

function MarketCtrl:GetRareState(cate)
    return self.data:GetRareState(cate)
end

function MarketCtrl:GetMarketInfo()
    return self.data:GetMarketInfo()
end

function MarketCtrl:GetMarketLevel()
    return self.data:GetMarketLevel()
end

function MarketCtrl:CanFollow(cate)
    return self.data:CanFollow(cate)
end

function MarketCtrl:IsFollow(uid)
    return self.data:IsFollow(uid)
end

function MarketCtrl:GetFollowItems(tag)
    return self.data:GetFollowItems(tag)
end

function MarketCtrl:GetFollowEquipItems(tag, eq_tag)
    return self.data:GetFollowEquipItems(tag, eq_tag)
end

function MarketCtrl:GetRareCateList()
    return self.data:GetRareCateList()
end

function MarketCtrl:GetBagMarketItems()
    return self.data:GetBagMarketItems()
end

function MarketCtrl:GetBagMarketEquip()
    return self.data:GetBagMarketEquip()
end

function MarketCtrl:GetBagMarketPet()
    return self.data:GetBagMarketPet()
end

function MarketCtrl:GetFee(cate_id, price, num)
    return self.data:GetFee(cate_id, price, num)
end

function MarketCtrl:GetExpirePutItems()
    return self.data:GetExpirePutItems()
end

function MarketCtrl:GetCateIndex(cate)
    return self.data:GetCateIndex(cate)
end

function MarketCtrl:GetTagIndex(tag)
    return self.data:GetTagIndex(tag)
end

function MarketCtrl:GetEquipTagIndex(tag, eq_tag)
    return self.data:GetEquipTagIndex(tag, eq_tag)
end

function MarketCtrl:GetResaleTipsStr()
    local expire_items = self.data:GetExpirePutItems()
    local cost = 0
    local fee_money_type = 4
    for k, v in pairs(expire_items) do
        local tag = v.tag
        local cate = self.data:GetTagCateId(tag)
        cost = cost + self:GetFee(cate, v.price, v.num)
    end
    local str = math.floor(cost) .. config.money_type[fee_money_type].name
    return string.format(config.words[5654], str)
end

function MarketCtrl:CacheItem(item)
    self.data:CacheItem(item)
end

function MarketCtrl:GetCacheItem(uid)
    return self.data:GetCateItem(uid)
end

function MarketCtrl:GetTradeCD(sell_times)
    return self.data:GetTradeCD(sell_times)
end

function MarketCtrl:IsTradeCD(sell_time, sell_times)
    return self.data:IsTradeCD(sell_time, sell_times)
end

function MarketCtrl:SecToTime(second)
    local WordDay = config.words[107]
    local WordHour = config.words[108]
    local WordMin = config.words[103]
    local WordSec = config.words[104]
    
    local hour = math.floor(second / 3600)
    local minutes = math.floor((second - hour * 3600) / 60)
    local seconds = (second - hour * 3600) % 60
    if hour ~= 0 then
        return string.format("%d%s%02d%s", hour, WordHour, minutes, WordMin)
    else
        return string.format("%d%s", minutes, WordMin)
    end
end

function MarketCtrl:IsValid(id)
    return self.data:IsValid(id)
end

function MarketCtrl:GetFollowNum()
    return self.data:GetFollowNum()
end

game.MarketCtrl = MarketCtrl

return MarketCtrl