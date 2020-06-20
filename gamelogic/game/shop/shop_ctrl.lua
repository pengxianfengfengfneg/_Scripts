local ShopCtrl = Class(game.BaseCtrl)

function ShopCtrl:_init()
    if ShopCtrl.instance ~= nil then
        error("ShopCtrl Init Twice!")
    end
    ShopCtrl.instance = self
    self.shop_view = require("game/shop/shop_view").New(self)
    self.shop_buy_view = require("game/shop/shop_buy_view").New(self)
    self.data = require("game/shop/shop_data").New()
    
    self:RegisterAllEvents()
    self:RegisterAllProtocal()
end

function ShopCtrl:_delete()
    self.shop_view:DeleteMe()
    self.shop_buy_view:DeleteMe()
    self.data:DeleteMe()
    ShopCtrl.instance = nil
end

function ShopCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, function()
            self:SendGetShopInfo()
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ShopCtrl:RegisterAllProtocal()
    local proto = {
        [20602] = "OnShopInfo",
        [20604] = "OnShopBuy",
    }
    for id, func in pairs(proto) do
        self:RegisterProtocalCallback(id, func)
    end
end

function ShopCtrl:OpenView(func_id, shop_idx, tag_idx, cate_idx, item_id)
    self.shop_view:Open(func_id, shop_idx, tag_idx, cate_idx, item_id)
end

--物品属于多个标签时，跳转到第一个标签
function ShopCtrl:OpenViewByShopId(shop_id, item_id)
    local func_id = config.shop[shop_id].function_id
    local cate_id = self:GetItemCateIdByShopId(shop_id, item_id)
    local tag_id = self:GetTagIdByCateId(cate_id)
    self:OpenView(func_id, self:GetShopIndex(shop_id), self:GetTagIndex(tag_id), self:GetCateIndex(cate_id), item_id)
end

function ShopCtrl:OpenViewByTagId(tag_id, item_id)
    local shop_id = self:GetShopIdByTagId(tag_id)
    local func_id = config.shop[shop_id].function_id
    local cate_id = self:GetItemCateIdByTagId(tag_id, item_id)
    self:OpenView(func_id, self:GetShopIndex(shop_id), self:GetTagIndex(tag_id), self:GetCateIndex(cate_id), item_id)
end

function ShopCtrl:OpenViewByCateId(cate_id, item_id)
    local tag_id = self:GetTagIdByCateId(cate_id)
    local shop_id = self:GetShopIdByTagId(tag_id)
    local func_id = config.shop[shop_id].function_id
    self:OpenView(func_id, self:GetShopIndex(shop_id), self:GetTagIndex(tag_id), self:GetCateIndex(cate_id), item_id)
end

--物品属于多个商店时，打开第一个商店
function ShopCtrl:OpenViewByItemId(item_id)
    local cate_list = self:GetItemCateList(item_id)
    if #cate_list > 0 then
        local cate_id = cate_list[1]
        self:OpenViewByCateId(cate_id, item_id)
    end
end

function ShopCtrl:CloseView()
    self.shop_view:Close()
    self.shop_buy_view:Close()
end

function ShopCtrl:IsOpenView()
    return self.shop_view:IsOpen() or self.shop_view:IsLoading()
end

function ShopCtrl:OpenShopBuyView(goods_info)
    self.shop_buy_view:Open(goods_info)
end

function ShopCtrl:SendGetShopInfo()
    self:SendProtocal(20601, {})
end

function ShopCtrl:SendShopBuy(cate_id, item_id, num)
    self:SendProtocal(20603, { cate_id = cate_id, item_id = item_id, num = num })
end

--物品属于多个标签时，会购买第一个
function ShopCtrl:BuyShopItem(shop_id, item_id, num)
    local cate_id = self:GetItemCateIdByShopId(shop_id, item_id)
    self:SendShopBuy(cate_id, item_id, num)
end

function ShopCtrl:BuyTagItem(tag_id, item_id, num)
    local cate_id = self:GetItemCateIdByTagId(tag_id, item_id)
    self:SendShopBuy(cate_id, item_id, num)
end

function ShopCtrl:OnShopInfo(data)
    self.data:SetShopInfo(data)
end

function ShopCtrl:OnShopBuy(item_info)
    self.data:OnShopBuy(item_info)
end

function ShopCtrl:GetShopList(func_id)
    return self.data:GetShopList(func_id)
end

function ShopCtrl:GetTagList(shop_id, page)
    return self.data:GetTagList(shop_id, page)
end

function ShopCtrl:GetPageNum(shop_id)
    return self.data:GetPageNum(shop_id)
end

function ShopCtrl:HaveCate(tag_id)
    return self.data:HaveCate(tag_id)
end

function ShopCtrl:GetCateIdByTagId(tag_id)
    return self.data:GetCateIdByTagId(tag_id)
end

function ShopCtrl:GetShopIdByTagId(tag_id)
    return self.data:GetShopIdByTagId(tag_id)
end

function ShopCtrl:GetTagIdByCateId(cate_id)
    return self.data:GetTagIdByCateId(cate_id)
end

function ShopCtrl:GetCateTagData(cate_id)
    return self.data:GetCateTagData(cate_id)
end

function ShopCtrl:GetCateList(tag_id)
    return self.data:GetCateList(tag_id)
end

function ShopCtrl:GetFuncIdByShopId(shop_id)
    return self.data:GetFuncIdByShopId(shop_id)
end

function ShopCtrl:GetItems(cate_id)
    return self.data:GetItems(cate_id)
end

function ShopCtrl:GetTagItems(tag_id)
    return self.data:GetTagItems(tag_id)
end

function ShopCtrl:GetShopItems(shop_id)
    return self.data:GetShopItems(shop_id)
end

function ShopCtrl:GetCondMsg(cond, ...)
    return self.data:GetCondMsg(cond, ...)
end

function ShopCtrl:IsMeetCond(cond, ...)
    return self.data:IsMeetCond(cond, ...)
end

function ShopCtrl:CanBuy(item_info)
    return self.data:CanBuy(item_info)
end

function ShopCtrl:GetShopIndex(shop_id)
    return self.data:GetShopIndex(shop_id)
end

function ShopCtrl:GetTagIndex(tag_id)
    return self.data:GetTagIndex(tag_id)
end

function ShopCtrl:GetCateIndex(cate_id)
    return self.data:GetCateIndex(cate_id)
end

function ShopCtrl:GetItemCateIdByTagId(tag_id, item_id)
    return self.data:GetItemCateIdByTagId(tag_id, item_id)
end

function ShopCtrl:GetItemCateIdByShopId(shop_id, item_id)
    return self.data:GetItemCateIdByShopId(shop_id, item_id)
end

function ShopCtrl:IsBuyLimit(cate_id, item_id)
    return self.data:IsBuyLimit(cate_id, item_id)
end

function ShopCtrl:GetBuyLimitNum(cate_id, item_id)
    return self.data:GetBuyLimitNum(cate_id, item_id)
end

function ShopCtrl:GetItemCateList(item_id)
    return self.data:GetItemCateList(item_id)
end

function ShopCtrl:GetMoneyByType(price_type)
    return self.data:GetMoneyByType(price_type)
end

function ShopCtrl:IsMoneyType(price_type)
    return self.data:IsMoneyType(price_type)
end

game.ShopCtrl = ShopCtrl

return ShopCtrl