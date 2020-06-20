local WeekTemplate = Class(game.UITemplate)

function WeekTemplate:_init()
    self.ctrl = game.RechargeCtrl.instance
end

function WeekTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function WeekTemplate:CloseViewCallBack()
   
end

function WeekTemplate:RegisterAllEvents()
    local events = {
        {game.RechargeEvent.OnConsumeInfo, handler(self, self.OnConsumeInfo)},
        {game.RechargeEvent.OnGetConsume, handler(self, self.OnGetConsume)},
        {game.RechargeEvent.OnConsumeChange, handler(self, self.SetCostText)},
        {game.RechargeEvent.OnConsumeRoraty, handler(self, self.OnConsumeRoraty)},
        {game.BagEvent.BagItemChange, handler(self, self.OnBagItemChange)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function WeekTemplate:Init()
    self.list_week = self:CreateList("list_week", "game/recharge/item/gift_item")
    self.list_week:SetRefreshItemFunc(function(item, idx)
        local item_info = self.week_list_data[idx]
        item:SetItemInfo(item_info)
        item:SetGetState(self.ctrl:GetWeekRewardState(item_info.id))
        item:SetBarProgress(self.ctrl:GetWeeklyConsume(), item_info.cost_gold)
        item:AddGetEvent(function()
            self.ctrl:SendChargeConsumeGetConsume(item_info.id)
        end)
    end)

    self._layout_objs.txt_title:SetText(config.words[5714])
    self._layout_objs.txt_content:SetText(config.words[5715])

    self._layout_objs.img_money:SetSprite("ui_common", config.money_type[game.MoneyType.Gold].icon)

    self.txt_times = self._layout_objs.txt_times
    self.txt_cost = self._layout_objs.txt_cost

    self.btn_roraty = self._layout_objs.btn_roraty
    self.btn_roraty:AddClickCallBack(function()
        if self.ctrl:GetChargeConsumeInfo().leave_times <= 0 then
            game.GameMsgCtrl.instance:PushMsg(config.words[5716])
        else
            self.ctrl:OpenRoratyView()
        end
    end)
end

function WeekTemplate:UpdateWeekList()
    self.week_list_data = {}
    for k, v in pairs(config.weekly_consume) do
        table.insert(self.week_list_data, v)
    end
    table.sort(self.week_list_data, function(m, n)
        return m.id < n.id
    end)
    self.list_week:SetItemNum(#self.week_list_data)
end

function WeekTemplate:OnConsumeInfo(data)
    self:UpdateWeekList()
    self:SetTimesText()
    self:SetCostText()
    self:UpdateRoratyRedPoint()
end

function WeekTemplate:SetTimesText()
    local charge_info = self.ctrl:GetChargeConsumeInfo()
    self.txt_times:SetText(string.format(config.words[5712], self.ctrl:GetRoratyTimes()))
end

function WeekTemplate:SetCostText()
    self.txt_cost:SetText(string.format(config.words[5713], self.ctrl:GetWeeklyConsume()))
end

function WeekTemplate:OnGetConsume(data)
    self:UpdateWeekList()
    self:UpdateRoratyRedPoint()
end

function WeekTemplate:OnBagItemChange(change_list)
    local item_id = config.sys_config["recharge_ticked_id"].value
    if change_list[item_id] then
        self:SetTimesText()
        self:UpdateRoratyRedPoint()
    end
end

function WeekTemplate:UpdateRoratyRedPoint()
    game_help.SetRedPoint(self.btn_roraty, self.ctrl:GetRoratyTimes()>0)
end

function WeekTemplate:OnConsumeRoraty()
    self:SetTimesText()
    self:UpdateRoratyRedPoint()
end

return WeekTemplate