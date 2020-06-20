local ShopItem = Class(game.UITemplate)

function ShopItem:OpenViewCallBack()
    self._layout_objs.btn_buy:AddClickCallBack(function()
        game.ShopCtrl.instance:OpenShopBuyView(self.info)
    end)
end

function ShopItem:CloseViewCallBack()
    self.info = nil
end

function ShopItem:SetItemInfo(info)
    self.info = info
    local cfg = config.goods[info.item_id]
    self._layout_objs.name:SetText(cfg.name)
    self._layout_objs.price:SetText(info.price)
    local price_type = info.price_type
    if price_type == 0 then
        price_type = config.shop[12].price_type
    end
    self._layout_objs.money_type:SetSprite("ui_common", config.money_type[price_type].icon)
    local goods_item = self:GetTemplate("game/bag/item/goods_item", "item")
    goods_item:SetItemInfo({id = info.item_id})
    goods_item:SetShowTipsEnable(true)
end

function ShopItem:SetSelect(val)
    self._layout_objs.img_select:SetVisible(val)
end

return ShopItem