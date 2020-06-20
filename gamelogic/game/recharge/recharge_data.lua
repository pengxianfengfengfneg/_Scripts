local RechargeData = Class(game.BaseData)

function RechargeData:_init(ctrl)
    self.ctrl = ctrl
end

function RechargeData:_delete()

end

function RechargeData:SetChargeConsumeInfo(data)
    self.charge_consume_info = data
    self:FireEvent(game.RechargeEvent.OnConsumeInfo, data)
    
    local first_visible = self:CheckShowFirstRecharge()
    if not first_visible then
        self:FireEvent(game.OpenFuncEvent.SetShowFunc, game.OpenFuncId.FirstRecharge, first_visible)
    end
end

function RechargeData:GetChargeConsumeInfo()
    return self.charge_consume_info
end

function RechargeData:OnChargeConsumeRoraty(data)
    if self.charge_consume_info then
        self.charge_consume_info.leave_times = data.leave_times
        for k, v in ipairs(self.charge_consume_info.leave_ids or {}) do
            if v.id == data.id then
                table.remove(self.charge_consume_info.leave_ids, k)
            end
        end
        self.charge_consume_info.index = data.id
    end
    self:FireEvent(game.RechargeEvent.OnConsumeRoraty, data)
end

function RechargeData:OnChargeConsumeRoratyGet(data)
    if self.charge_consume_info then
        self.charge_consume_info.index = 0
    end
    self:FireEvent(game.RechargeEvent.OnConsumeRoratyGet, data.id)
end

function RechargeData:OnChargeConsumeChange(data)
    if self.charge_consume_info then
        self.charge_consume_info.weekly_consume = data.weekly_consume
    end
    self:FireEvent(game.RechargeEvent.OnConsumeChange, data)
end

function RechargeData:OnChargeConsumeFlagChange(data)
    if self.charge_consume_info then
        self.charge_consume_info.flag = data.flag
    end
    self:FireEvent(game.RechargeEvent.OnConsumeFlagChange, data)

    local first_visible = self:CheckShowFirstRecharge()
    if not first_visible then
        self:FireEvent(game.OpenFuncEvent.SetShowFunc, game.OpenFuncId.FirstRecharge, first_visible)
    end
end

function RechargeData:GetCharge(id)
    if self.charge_consume_info then
        table.insert(self.charge_consume_info.charge_got_list, {id = id})
    end
    self:FireEvent(game.RechargeEvent.OnGetCharge, id)
end

function RechargeData:GetConsume(id)
    if self.charge_consume_info then
        table.insert(self.charge_consume_info.consume_got_list, {id = id})
    end
    self:FireEvent(game.RechargeEvent.OnGetConsume, id)
end

function RechargeData:GetFlag()
    if self.charge_consume_info then
        return self.charge_consume_info.flag
    end
end

function RechargeData:GetChargeGiftState(id)
    if self.charge_consume_info then
        for k, v in pairs(self.charge_consume_info.charge_got_list or {}) do
            if v.id == id then
                return 1
            end
        end
        local charge_gold = game.VipCtrl.instance:GetCaculateRechargeMoney()*10
        if charge_gold >= config.charge_gift[id].charge_gold then
            return 2
        end
    end
    return 0
end

function RechargeData:GetWeekRewardState(id)
    if self.charge_consume_info then
        for k, v in pairs(self.charge_consume_info.consume_got_list or {}) do
            if v.id == id then
                return 1
            end
        end
        local week_consume = self.ctrl:GetWeeklyConsume()
        if week_consume >= config.weekly_consume[id].cost_gold then
            return 2
        end
    end
    return 0
end

function RechargeData:GetWeeklyConsume()
    if self.charge_consume_info then
        return self.charge_consume_info.weekly_consume
    end
end

function RechargeData:CanRoraty(id)
    if self.charge_consume_info then
        for k, v in pairs(self.charge_consume_info.leave_ids or {}) do
            if v.id == id then
                return true
            end
        end
    end
    return false
end

function RechargeData:CheckShowFirstRecharge()
    return self:GetFlag() ~= 2
end

function RechargeData:GetRoratyTimes()
    if self.charge_consume_info then
        local item_id = config.sys_config["recharge_ticked_id"].value
        local item_num = game.BagCtrl.instance:GetNumById(item_id)
        return math.min(item_num, self.charge_consume_info.leave_times)
    end
    return 0
end

function RechargeData:CheckGiftRed()
    for k, v in ipairs(config.charge_gift) do
        if self:GetChargeGiftState(v.id) == 2 then
            return true
        end
    end
    return false
end

function RechargeData:CheckWeekRed()
    for k, v in ipairs(config.weekly_consume) do
        if self:GetWeekRewardState(v.id) == 2 then
            return true
        end
    end
    if self:GetRoratyTimes() > 0 then
        return true
    end
    return false
end

function RechargeData:GetRoratyIndex()
    if self.charge_consume_info then
        return self.charge_consume_info.index
    end
    return 0
end

return RechargeData