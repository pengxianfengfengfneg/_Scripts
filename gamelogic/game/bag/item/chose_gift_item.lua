local ChoseGiftItem = Class(game.UITemplate)

function ChoseGiftItem:OpenViewCallBack()
end

function ChoseGiftItem:CloseViewCallBack()
    self.info = nil
end

function ChoseGiftItem:SetItemInfo(item_id)
    self.info = item_id
    local cfg = config.goods[item_id]
    self._layout_objs.name:SetText(cfg.name)
    local goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    goods_item:SetItemInfo({id = item_id})
    goods_item:SetShowTipsEnable(true)
end

function ChoseGiftItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

function ChoseGiftItem:SetIndex(idx)
    self.idx = idx
end

function ChoseGiftItem:GetIndex()
    return self.idx
end

return ChoseGiftItem