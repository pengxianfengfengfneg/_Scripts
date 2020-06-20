local RechargeView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/recharge_template",
        item_class = "game/recharge/template/recharge_template",
    },
    {
        item_path = "list_page/gift_template",
        item_class = "game/recharge/template/gift_template",
    },
    {
        item_path = "list_page/week_template",
        item_class = "game/recharge/template/week_template",
    },
}

local RedConfig = {
    [2] = {
        check_func = function()
            return game.RechargeCtrl.instance:CheckGiftRed()
        end,
        update_events = {
            game.RechargeEvent.OnConsumeInfo,
            game.RechargeEvent.OnGetCharge,
            game.VipEvent.UpdateCaculateRechargeMoney,
        },
    },
    [3] = {
        check_func = function()
            return game.RechargeCtrl.instance:CheckWeekRed()
        end,
        update_events = {
            game.RechargeEvent.OnConsumeInfo,
            game.RechargeEvent.OnGetConsume,
            game.RechargeEvent.OnConsumeChange,
            game.RechargeEvent.OnConsumeRoraty,
            game.BagEvent.BagItemChange,
        },
    },
}

function RechargeView:_init(ctrl)

    RechargeView.instance = self

    self._package_name = "ui_recharge"
    self._com_name = "recharge_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function RechargeView:_delete()
    RechargeView.instance = nil
end

function RechargeView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()
    self.ctrl:SendChargeConsumeInfo()
end

function RechargeView:CloseViewCallBack()

end

function RechargeView:Init(open_idx)
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)

    self:InitView()
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
    end)

    open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)

    self.list_tab = self._layout_objs.list_tab

    for id, v in pairs(RedConfig) do
        for _, cv in pairs(v.update_events) do
            self:BindEvent(cv, function()
                self:UpdateRedPoint(id)
            end)
        end
    end

    for id, v in pairs(RedConfig) do
        self:UpdateRedPoint(id)
    end
end

function RechargeView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5700])
end

function RechargeView:InitView()
    for _, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function RechargeView:UpdateRedPoint(id)
    local tab = self.list_tab:GetChildAt(id-1)
    game_help.SetRedPoint(tab, RedConfig[id].check_func(), 98)
end

function RechargeView:IsPayBg(val)
    self._layout_objs["bg_pay"]:SetVisible(val)
end

function RechargeView:IsPayInfoBg(val)
    self._layout_objs["bg_payinfo"]:SetVisible(val)
end

function RechargeView:SetPayInfoValue(val)
    self._layout_objs["MerchantID"]:SetText(val.MerchantID)
    self._layout_objs["TradeNo"]:SetText(val.TradeNo)
    self._layout_objs["MerchantTradeNo"]:SetText(val.MerchantTradeNo)
    self._layout_objs["TradeAmt"]:SetText(val.TradeAmt)
    self._layout_objs["BankCode"]:SetText(val.BankCode)
    self._layout_objs["vAccount"]:SetText(val.vAccount)
    self._layout_objs["ExpireDate"]:SetText(val.ExpireDate)
end

function RechargeView:BtnPay1()
    return self._layout_objs["btn_pay1"]
end

function RechargeView:BtnPay2()
    return self._layout_objs["btn_pay2"]
end

function RechargeView:BtnPay3()
    return self._layout_objs["btn_pay3"]
end

function RechargeView:BtnClose()
    return self._layout_objs["btn_close"]
end

function RechargeView:BtnInfoClose()
    return self._layout_objs["btn_info_close"]
end

function RechargeView:SetIstouch(val)
    self._layout_objs["is_touch"]:SetVisible(val)
end

game.RechargeView = RechargeView

return RechargeView
