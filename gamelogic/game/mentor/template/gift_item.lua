local GiftItem = Class(game.UITemplate)

local PageIndex = {
    Mentor = 0,
    Prentice = 1,
}

function GiftItem:_init(ctrl)
    self.ctrl = game.MentorCtrl.instance
end

function GiftItem:OpenViewCallBack()
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")

    self.img_money = self._layout_objs["img_money"]

    self.txt_name = self._layout_objs["txt_name"]
    self.txt_price = self._layout_objs["txt_price"]
    self.txt_cond = self._layout_objs["txt_cond"]
    self.txt_limit = self._layout_objs["txt_limit"]

    self.btn_buy = self._layout_objs["btn_buy"]
    self.btn_buy:AddClickCallBack(function()
        if self.info then
            game.ShopCtrl.instance:OpenShopBuyView(self.info)
        end
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
end

function GiftItem:SetItemInfo(item_info, idx)
    self.info = item_info
    local page_idx = self.ctrl:IsMentor() and PageIndex.Mentor or PageIndex.Prentice

    local shop_data = config.shop[game.ShopId.PrenticeGift]
    self.img_money:SetSprite("ui_common", config.money_type[shop_data.price_type].icon)

    local item_cfg = config.goods[item_info.item_id]
    self.txt_name:SetText(item_cfg.name)
    self.txt_price:SetText(item_info.price)

    local cond = item_info.conds[1]
    local need_mark = cond and cond[2] or 0
    self.txt_cond:SetText(string.format(config.words[6430], need_mark))
    local item_num = game.ShopCtrl.instance:GetBuyLimitNum(item_info.cate_id, item_info.item_id)
    self.goods_item:SetItemInfo({id = item_info.item_id, num = item_num})
    self.goods_item:SetShowTipsEnable(true)

    local is_meet_cond = item_info.mark >= need_mark
    if page_idx == PageIndex.Mentor then
        self.txt_limit:SetVisible(not is_meet_cond)
    end
    self.btn_buy:SetEnable(item_num > 0 and is_meet_cond)

    self.ctrl_page:SetSelectedIndexEx(page_idx)
end

return GiftItem