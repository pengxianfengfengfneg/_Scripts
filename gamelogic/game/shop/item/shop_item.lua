local ShopItem = Class(game.UITemplate)

local BuyFunc = {
    [1115] = {
        check_func = function()
            local ret = not game.GuildCtrl.instance:IsDenfState()
            local msg = config.words[6015]
            return ret, msg
        end,
    },
}

function ShopItem:_init(ctrl)
    self.ctrl = game.ShopCtrl.instance
end

function ShopItem:_delete()

end

function ShopItem:OpenViewCallBack()
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")

    self._layout_objs["btn_buy"]:AddClickCallBack(handler(self, self.OnBuy))
    self.img_need = self._layout_objs["img_need"]
end

function ShopItem:CloseViewCallBack()

end

function ShopItem:SetItemInfo(item_info)
    self.item_info = item_info

    local tag_data = self.ctrl:GetCateTagData(item_info.cate_id)
    local shop_data = config.shop[tag_data.shop_id]
    
    self.shop_id = shop_data.id
    self.price_type = item_info.price_type == 0 and shop_data.price_type or item_info.price_type
    self.price = item_info.price
    local good_info = config.goods[item_info.item_id]
    
    self._layout_objs["txt_name"]:SetText(good_info.name)
    self._layout_objs["txt_price"]:SetText(item_info.price)

    if self.ctrl:IsMoneyType(self.price_type) then
        self._layout_objs["img_money"]:SetSprite("ui_common", config.money_type[self.price_type].icon, true)
    else
        self._layout_objs["img_money"]:SetSprite("ui_item", config.goods[self.price_type].icon)
        self._layout_objs["img_money"]:SetSize(42, 33)
    end

    self.goods_item:SetItemInfo({id = item_info.item_id})
    self.goods_item:SetShowTipsEnable(true)

    if self.ctrl:IsBuyLimit(item_info.cate_id, item_info.item_id) then
        local num = self.ctrl:GetBuyLimitNum(item_info.cate_id, item_info.item_id)
        local str = string.format(config.words[1614], num)
        self.goods_item:SetNumText(str)
    end

    self._layout_objs["btn_buy"]:SetEnable(self.ctrl:CanBuy(item_info))
    local need = (shop_data.task == 1) and game.TaskCtrl.instance:IsTaskNeedItem(item_info.item_id)
    if need then
        local ui_effect = self:CreateUIEffect(self._layout_objs.effect, "effect/ui/ui_changkuang.ab")
        ui_effect:SetLoop(true)
        ui_effect:Play()
        ui_effect:SetScale(0.85, 0.75, 1)
    else
        self:ClearUIEffect()
    end
    self.img_need:SetVisible(need)
end

function ShopItem:OnBuy()
    game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_shop/shop_view/shop_item/btn_buy"})

    if self.shop_id then
        local func_id = self.ctrl:GetFuncIdByShopId(self.shop_id)
        local buy_cfg = BuyFunc[func_id]
        if buy_cfg then
            local ret, msg = buy_cfg.check_func()
            if not ret then
                game.GameMsgCtrl.instance:PushMsg(msg)
                return
            end
        end
    end

    if self.item_info then
        self.ctrl:OpenShopBuyView(self.item_info)
    end
end

return ShopItem