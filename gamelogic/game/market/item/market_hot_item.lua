local MarketHotItem = Class(game.UITemplate)

local PosIndex = {
    Left = 0,
    Right = 1,
}

function MarketHotItem:_init(ctrl)
    self.ctrl = ctrl
end

function MarketHotItem:OpenViewCallBack()
    self:Init()
end

function MarketHotItem:Init()
    self.market_item = self:GetTemplate("game/market/item/market_item", "market_item")
    self.ctrl_pos = self:GetRoot():GetController("ctrl_pos")
    self.img_bg = self._layout_objs["img_bg"]

    self:GetRoot():AddClickCallBack(function()
        self:OnItemClick()
    end)
end

function MarketHotItem:SetItemInfo(item_info)
    self.item_info = item_info
    self.ctrl_pos:SetSelectedIndexEx((item_info.item_pos == 0) and PosIndex.Left or PosIndex.Right)
    if item_info.is_pet == 0 then
        self.market_item:SetItemInfo({id = item_info.item_id})
    else
        self.market_item:SetPetInfo({id = item_info.item_id})
    end
    self.img_bg:SetSprite("ui_market", item_info.icon)
end

function MarketHotItem:OnItemClick()
    local cate = self.item_info.cate
    local tag = self.item_info.tag
    game.MarketCtrl.instance:JumpToBuyPage(cate, tag)
end

return MarketHotItem