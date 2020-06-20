local GiftTemplate = Class(game.UITemplate)

function GiftTemplate:_init()
    self.ctrl = game.RechargeCtrl.instance   
end

function GiftTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function GiftTemplate:CloseViewCallBack()
   
end

function GiftTemplate:RegisterAllEvents()
    local events = {
        {game.RechargeEvent.OnConsumeInfo, handler(self, self.OnConsumeInfo)},
        {game.RechargeEvent.OnGetCharge, handler(self, self.OnGetCharge)},
        {game.VipEvent.UpdateCaculateRechargeMoney, handler(self, self.UpdateGiftList)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GiftTemplate:Init()
    self.list_gift = self:CreateList("list_gift", "game/recharge/item/gift_item")
    self.list_gift:SetRefreshItemFunc(function(item, idx)
        local item_info = self.gift_list_data[idx]
        item:SetItemInfo(item_info)
        item:SetGetState(self.ctrl:GetChargeGiftState(item_info.id))
        item:SetBarProgress(game.VipCtrl.instance:GetCaculateRechargeMoney()*10, item_info.charge_gold)
        item:AddGetEvent(function()
            self.ctrl:SendChargeConsumeGetCharge(item_info.id)
        end)
    end)
end

function GiftTemplate:UpdateGiftList()
    self.gift_list_data = {}
    for k, v in pairs(config.charge_gift) do
        table.insert(self.gift_list_data, v)
    end
    table.sort(self.gift_list_data, function(m, n)
        return m.id < n.id
    end)
    self.list_gift:SetItemNum(#self.gift_list_data)
end

function GiftTemplate:OnConsumeInfo(data)
    self:UpdateGiftList()
end

function GiftTemplate:OnGetCharge(data)
    self:UpdateGiftList()
end

return GiftTemplate