local MarketItem = Class(game.UITemplate)

local PageIndex = {
    Goods = 0,
    Pet = 1,
}

function MarketItem:_init(ctrl)
    self.ctrl = game.MarketCtrl.instance
end

function MarketItem:_delete()

end

function MarketItem:OpenViewCallBack()
    self:Init()
    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event()
        end
    end)
end

function MarketItem:CloseViewCallBack()
    self:StopMaskTween()
end

function MarketItem:Init()
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.pet_item = self:GetTemplate("game/pet/item/pet_icon_item", "pet_item")

    self.ctrl_index = self:GetRoot():GetController("ctrl_index")

    self.img_rare = self._layout_objs.img_rare
    self.img_presell = self._layout_objs.img_presell

    self.img_mask = self._layout_objs.img_mask
    self.img_mask:SetVisible(false)

    self.txt_time = self._layout_objs.txt_time
    self.txt_time:SetVisible(false)
end

function MarketItem:SetItemInfo(item_info)
    self.item = self.goods_item
    self.goods_item:SetItemInfo({id = item_info.id, num = item_info.num})
    self.ctrl_index:SetSelectedIndexEx(PageIndex.Goods)
    self:SetRareImg(item_info.rare)
    self:SetPresellImg(item_info.presell)
end

function MarketItem:SetPetInfo(pet_info)
    self.item = self.pet_item
    self.pet_item:SetItemInfo(({id = (pet_info.id or pet_info.cid), star = pet_info.star}))
    self.ctrl_index:SetSelectedIndexEx(PageIndex.Pet)
    self:SetRareImg(pet_info.rare)
    self:SetPresellImg(pet_info.presell)
end

function MarketItem:SetSelect(val)
    if self.item then
        self.item:SetSelect(val)
    end
end

function MarketItem:ResetItem()
    if self.item then
        self.item:ResetItem()
    end
end

function MarketItem:SetRareImg(rare)
    self.img_rare:SetVisible(rare == 1)
end

function MarketItem:SetPresellImg(presell)
    self.img_presell:SetVisible(presell == 1)
end

function MarketItem:AddClickEvent(click_event)
    self.click_event = click_event
end

function MarketItem:GetGoodsItem()
    return self.goods_item
end

function MarketItem:StartMaskTween(start_time, end_time)
    self:StopMaskTween()

    local delta = end_time - start_time
    self.img_mask:SetVisible(true)
    self.txt_time:SetVisible(true)

    self.tw_mask = DOTween:Sequence()
    self.tw_mask:AppendCallback(function()
        local server_time = global.Time:GetServerTime()
        local time_str = math.ceil((end_time - server_time) / 86400)
        self.txt_time:SetText(time_str..config.words[107])
        self.img_mask:SetFillAmount(1 - (server_time - start_time) / delta)
        if server_time >= end_time then
            self:StopMaskTween()
        end
    end)
    self.tw_mask:AppendInterval(1)
    self.tw_mask:SetLoops(-1)
    self.tw_mask:Play()
end

function MarketItem:StopMaskTween()
    if self.tw_mask then
        self.tw_mask:Kill(false)
        self.tw_mask = nil
    end
    self.img_mask:SetVisible(false)
    self.txt_time:SetVisible(false)
end

return MarketItem