local SignTemplate = Class(game.UITemplate)

local _cfg_daily_sign = config.daily_sign
local _cfg_acc_sign = config.acc_sign
local _cfg_drop = config.drop

function SignTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "sign_template"
end

function SignTemplate:OpenViewCallBack()
    self:InitSignList()
    self:InitAccList()
    self:BindEvent(game.RewardHallEvent.UpdateSignInfo, function()
        self:UpdateSign()
    end)
    self._layout_objs.btn_info:AddClickCallBack(function()
        game.GameMsgCtrl.instance:OpenInfoDescView(7)
    end)
    self:UpdateSign()
end

function SignTemplate:InitSignList()
    local server_time = global.Time:GetServerTime()
    local year, month = os.date("%Y", server_time), os.date("%m", server_time) + 1
    self.dayAmount = os.date("%d", os.time({ year = year, month = month, day = 0 }))
    self.sign_list = self:CreateList("sign_list", "game/reward_hall/item/sign_reward_item")
    self.sign_list:SetRefreshItemFunc(function(item, idx)
        local drop_id = _cfg_daily_sign[idx]
        local drop_info = _cfg_drop[drop_id].client_goods_list[1]
        item:SetItemInfo({ id = drop_info[1], num = drop_info[2] })
        item:SetDay(idx)
    end)
    self.sign_list:SetItemNum(tonumber(self.dayAmount))
end

function SignTemplate:InitAccList()
    self.acc_list = self:CreateList("reward_list", "game/reward_hall/item/acc_reward_item")
    self.acc_list:SetRefreshItemFunc(function(item, idx)
        _cfg_acc_sign[idx].id = idx
        item:SetItemInfo(_cfg_acc_sign[idx])
    end)
    self.acc_list:SetItemNum(#_cfg_acc_sign)
end

function SignTemplate:UpdateSign()
    local sign_info = game.RewardHallCtrl.instance:GetSignData()
    if sign_info == nil then
        return
    end
    self._layout_objs.total_sign:SetText(#sign_info.daily .. "/" .. self.dayAmount)
    self._layout_objs.add_sign:SetText(sign_info.times)
    self._layout_objs.add_signed:SetText(sign_info.bq_times .. "/2")

    self.sign_list:Foreach(function(item)
        for _, v in pairs(sign_info.daily) do
            if item:GetDay() == v.day then
                item:SetSign(true)
                item:SetTag(false)
                item:SetSelect(false)
                item:SetMask(true)
                break
            end
        end
        if sign_info.is_get == 0 and item:GetDay() == sign_info.sign_day then
            item:SetSelect(true)
        end
        if sign_info.is_get == 1 and sign_info.times > 0 and sign_info.bq_times < 2 and item:GetDay() == #sign_info.daily + 1 then
            item:SetTag(true)
        end
    end)

    self.acc_list:Foreach(function(item)
        for _, v in pairs(sign_info.acc) do
            if item:GetDay() == _cfg_acc_sign[v.id].day then
                item:SetState(v.state)
                break
            end
        end
    end)
end

return SignTemplate