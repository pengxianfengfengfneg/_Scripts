local RechargeItem = Class(game.UITemplate)

local PageIndex = {
    First = 1,
    NotFirst = 0,
}

function RechargeItem:_init()
    self.ctrl = game.RechargeCtrl.instance   
end

function RechargeItem:OpenViewCallBack()
    self._layout_objs.n1:SetText(config.words[5705])
    self._layout_objs.n2:SetText(config.words[5706])

    self.txt_first_rebate = self._layout_objs.txt_first_rebate
    self.txt_extra_gold = self._layout_objs.txt_extra_gold
    self.txt_name = self._layout_objs.txt_name
    self.txt_price = self._layout_objs.txt_price

    self.img_icon = self._layout_objs.img_icon
    self.img_money = self._layout_objs.img_money
    self.img_first = self._layout_objs.img_first

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self.ctrl_page:SetSelectedIndexEx(PageIndex.NotFirst)

    self:GetRoot():AddClickCallBack(handler(self, self.OnItemClick))
end

function RechargeItem:SetItemInfo(item_info)
    self.txt_first_rebate:SetText(item_info.first_rebate)
    self.txt_extra_gold:SetText(string.format(config.words[5707], item_info.extra_gold))
    self.txt_name:SetText(item_info.product_name)
    self.txt_price:SetText(string.format(config.words[5709], item_info.rmb))
    
    self.img_icon:SetSprite("ui_recharge", item_info.icon, true)
    self.img_money:SetSprite("ui_common", config.money_type[game.MoneyType.Gold].icon)

    self.ctrl_page:SetSelectedIndexEx((item_info.first_rebate ~= 0) and PageIndex.First or PageIndex.NotFirst)

    self.item_info = item_info
end

function RechargeItem:OnItemClick()
    if self.click_event then
        self.click_event()
    end
end

function RechargeItem:AddClickEvent(click_event)
    self.click_event = click_event
end

--商品ID
function RechargeItem:GetId()
    return self.item_info.product_id
end
--RMB
function RechargeItem:GetRMB()
    return self.item_info.rmb
end
--元宝数
function RechargeItem:GetGold()
    return self.item_info.gold
end

return RechargeItem
