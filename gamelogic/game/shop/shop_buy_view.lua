local ShopBuyView = Class(game.BaseView)
local _words = config.words
local _shop_ctrl = game.ShopCtrl.instance

local MoneyConfig = {
    [game.MoneyType.BindGoldFirst] = {
        types = {
            game.MoneyType.BindGold,
            game.MoneyType.BackupGoldFirst,
        },
        check_types_func = function(total_price)
            if _shop_ctrl:GetMoneyByType(game.MoneyType.BindGold) < total_price then
                if _shop_ctrl:GetMoneyByType(game.MoneyType.BindGoldFirst) >= total_price then
                    return true
                end
            end
            return false
        end,
    }
}

local open_recharge_tips = function(price_type)
    local money_name = config.money_type[price_type].name
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[1621], money_name))
    tips_view:SetBtn1(nil, function()
        game.RechargeCtrl.instance:OpenView()
    end)
    tips_view:Open()
end

local BuyFuncMap = {
    [game.MoneyType.Silver] = {
        buy_func = function(buy_info)
            game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Silver, buy_info.total_price, function()
                game.ShopCtrl.instance:SendShopBuy(buy_info.item_info.cate_id, buy_info.item_info.item_id, buy_info.num)
            end)
        end,
        check_func = function(buy_info)
            return game.ShopCtrl.instance:GetMoneyByType(buy_info.price_type) < buy_info.total_price
        end,
    },
    [game.MoneyType.BindGold] = {
        buy_func = function(buy_info)
            open_recharge_tips(buy_info.price_type)
        end,
        check_func = function(buy_info)
            return game.ShopCtrl.instance:GetMoneyByType(buy_info.price_type) < buy_info.total_price
        end,
    },
    [game.MoneyType.Gold] = {
        buy_func = function(buy_info)
            open_recharge_tips(buy_info.price_type)
        end,
        check_func = function(buy_info)
            return game.ShopCtrl.instance:GetMoneyByType(buy_info.price_type) < buy_info.total_price
        end,
    },
    [game.MoneyType.BindGoldFirst] = {
        buy_func = function(buy_info)
            open_recharge_tips(buy_info.price_type)
        end,
        check_func = function(buy_info)
            return game.ShopCtrl.instance:GetMoneyByType(buy_info.price_type) < buy_info.total_price
        end,
    },
    [game.MoneyType.BackupGoldFirst] = {
        buy_func = function(buy_info)
            open_recharge_tips(buy_info.price_type)
        end,
        check_func = function(buy_info)
            return game.ShopCtrl.instance:GetMoneyByType(buy_info.price_type) < buy_info.total_price
        end,
    },
}

function ShopBuyView:_init(ctrl)
    self._package_name = "ui_shop"
    self._com_name = "shop_buy_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
    self.ctrl = ctrl
end

function ShopBuyView:OpenViewCallBack(info)
    self.info = info
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function ShopBuyView:Init()
    local info = self.info
    local goods = config.goods[info.item_id]

    local tag_data = self.ctrl:GetCateTagData(info.cate_id)
    local shop_data = config.shop[tag_data.shop_id]

    self.price_type = info.price_type == 0 and shop_data.price_type or info.price_type
    self.cost = info.price
    self.cate_id = info.cate_id
    self.item_id = info.item_id

    self._layout_objs["txt_name"]:SetText(goods.name)
    self._layout_objs["txt_amount"]:SetText("1")

    self.buy_money_com = self._layout_objs.buy_money_com

    self.img_money1 = self.buy_money_com:GetChild("img_money1")
    self.img_money2 = self.buy_money_com:GetChild("img_money2")

    self.txt_price1 = self.buy_money_com:GetChild("txt_price1")
    self.txt_price2 = self.buy_money_com:GetChild("txt_price2")

    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.goods_item:SetItemInfo({id = info.item_id, rare = info.rare})
    if self.ctrl:IsBuyLimit(self.cate_id, self.item_id) then
        local num = self.ctrl:GetBuyLimitNum(self.cate_id, self.item_id)
        self.goods_item:SetNumText(string.format(config.words[1614], num))
    end

    self:SetPriceText()

    self._layout_objs["btn_buy"]:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_shop/shop_buy_view/btn_buy"})

        local buy_info = {
            total_price = self:GetTotalPrice(),
            cur_money = self.ctrl:GetMoneyByType(self.price_type),
            price_type = self.price_type,
            num = self:GetAmount(),
            item_info = self.info,
        }
        local buy_cfg = BuyFuncMap[self.price_type]
        if buy_cfg and buy_cfg.check_func(buy_info) then
            buy_cfg.buy_func(buy_info)
        else
            self.ctrl:SendShopBuy(info.cate_id, info.item_id, buy_info.num)
        end
    end)

    self._layout_objs["txt_amount"]:AddClickCallBack(function()
        game.MainUICtrl.instance:OpenNumberKeyboard(nil, 653)
    end)

    self._layout_objs["btn_plus"]:AddClickCallBack(function()
        self:SetAmountText(self:GetAmount()+1, 3)
    end)
    self._layout_objs["btn_minus"]:AddClickCallBack(function()
        self:SetAmountText(self:GetAmount()-1, 3)
    end)

    self._layout_objs["btn_plus100"]:AddClickCallBack(function()
        self:SetAmountText(self:GetAmount()+100, 3)
    end)

    self:SetAmountText(1)
end

function ShopBuyView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1606])
end

function ShopBuyView:SetAmountText(val, type)
    if type == 1 then
        local max_num = self:GetBuyMaxAmount()
        if self.ctrl:IsBuyLimit(self.cate_id, self.item_id) then
            max_num = self.ctrl:GetBuyLimitNum(self.cate_id, self.item_id)
        end
        val = math.clamp(val, 1, max_num)
        self._layout_objs["txt_amount"]:SetText(tostring(val))
    elseif type == 2 then
        self._layout_objs["txt_amount"]:SetText(val)
    else
        val = math.clamp(val, 1, self:GetBuyMaxAmount(type==3))
        self._layout_objs["txt_amount"]:SetText(val)
    end
    
    self:SetPriceText()
end

function ShopBuyView:GetAmount()
    local amt = self._layout_objs["txt_amount"]:GetText()
    return tonumber(amt) or 0
end

function ShopBuyView:SetPriceText()
    local money_config = MoneyConfig[self.price_type]
    local total_price = math.floor(self:GetAmount()) * self.cost
    local money = self.ctrl:GetMoneyByType(self.price_type)

    if not money_config or not money_config.check_types_func(total_price) then
        local color = (money >= total_price) and game.Color.GrayBrown or game.Color.Red    
        self:SetPriceTextById(1, total_price, color)
        self:SetMoneyInfo()
    else
        local types = money_config and money_config.types or {self.price_type}
        for k, v in ipairs(types) do
            local money = self.ctrl:GetMoneyByType(v)
            self:SetPriceTextById(k, math.min(money, total_price), game.Color.GrayBrown)
            total_price = total_price - money
        end
        self:SetMoneyInfo(types)
    end
end

function ShopBuyView:GetTotalPrice()
    return math.floor(self:GetAmount()) * self.cost
end

function ShopBuyView:SetPriceTextById(id, text, color)
    local price = self["txt_price"..id]
    price:SetText(text)
    price:SetColor(table.unpack(color))
end

function ShopBuyView:GetBuyMaxAmount(can_buy)
    local money = self.ctrl:GetMoneyByType(self.price_type)
    local price = self.cost
    local num = math.floor(money / price)

    local proto_max = 65535
    local num = proto_max
    if can_buy then
        local money = self.ctrl:GetMoneyByType(self.price_type)
        local price = self.cost
        num = math.min(num, math.floor(money / price))
    end
    if self.ctrl:IsBuyLimit(self.cate_id, self.item_id) then
        num = math.min(self.ctrl:GetBuyLimitNum(self.cate_id, self.item_id), num)
    end
    num = math.max(1, num)

    return num
end

function ShopBuyView:RegisterAllEvents()
    local events = {
        [game.ShopEvent.BuySuccess] = function()
            self:Close()
        end,
        [game.NumberKeyboardEvent.Number] = function(key)
            local num = self:GetAmount()
            if key >= 0 then
                self:SetAmountText(num * 10 + key, 1)
            else
                num = math.floor(num / 10)
                local str = (num == 0) and "" or num
                self:SetAmountText(str, 2)
            end
        end,
        [game.NumberKeyboardEvent.Close] = function()
            self:SetAmountText(self:GetAmount())
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

function ShopBuyView:SetMoneyInfo(types)
    local index = nil
    if types then
        for k, v in ipairs(types) do
            self:SetMoneyInfoById(k, v)
        end
        index = 1
    else
        self:SetMoneyInfoById(1, self.price_type)
        index = 0
    end
    self.buy_money_com:GetController("ctrl_page"):SetSelectedIndexEx(index)
    local widget = self["txt_price"..(index+1)]
    local width = widget.x + widget.width
    self.buy_money_com:SetWidth(width)
    self.buy_money_com:SetPositionX((self:GetRoot().width - width) * 0.5)
end

function ShopBuyView:SetMoneyInfoById(id, price_type)
    local image = self["img_money"..id]
    if self.ctrl:IsMoneyType(price_type) then
        image:SetSprite("ui_common", config.money_type[price_type].icon, true)
    else
        image:SetSprite("ui_item", config.goods[price_type].icon)
        image:SetSize(42, 33)
    end
end

return ShopBuyView
