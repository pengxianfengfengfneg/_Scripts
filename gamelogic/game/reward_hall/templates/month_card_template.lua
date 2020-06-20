local MonthCardTemplate = Class(game.UITemplate)

local _weekly_card = 9
local _month_card = 10

function MonthCardTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "month_card_template"
end

function MonthCardTemplate:OpenViewCallBack()
    self:Init()
    self:BindEvent(game.RewardHallEvent.UpdateWeekMonthCard, function()
        self:UpdateState()
    end)
    self:UpdateState()
end

function MonthCardTemplate:CloseViewCallBack()
    self:DelTimer()
end

local open_recharge_tips = function(price_type)
    local money_name = config.money_type[price_type].name
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[1621], money_name))
    tips_view:SetBtn1(nil, function()
        game.RechargeCtrl.instance:OpenView()
    end)
    tips_view:Open()
end

function MonthCardTemplate:Init()
    local cfg = config.weekly_month_card[_weekly_card]
    self._layout_objs.text1:SetText(string.format(config.words[3037], cfg.gold))
    self._layout_objs.text2:SetText(string.format(config.words[3038], cfg.daily_get))
    self._layout_objs.text3:SetText(string.format(config.words[3039], cfg.daily_get * cfg.last_day))
    cfg = config.weekly_month_card[_month_card]
    self._layout_objs.text4:SetText(string.format(config.words[3037], cfg.gold))
    self._layout_objs.text5:SetText(string.format(config.words[3038], cfg.daily_get))
    self._layout_objs.text6:SetText(string.format(config.words[3039], cfg.daily_get * cfg.last_day))

    self._layout_objs.btn_buy1:AddClickCallBack(function()
        if self.week_state == 1 then
            game.RewardHallCtrl.instance:SendCardReward(_weekly_card)
        elseif self.week_state == 0 then
            local cur_money = game.ShopCtrl.instance:GetMoneyByType(25)
            local cfg = config.weekly_month_card[9]
            if cur_money < cfg.rmb then
                open_recharge_tips(25)
            else
                game.RewardHallCtrl.instance:SendBuyCard(_weekly_card)
            end
        end
    end)
    self._layout_objs.btn_buy2:AddClickCallBack(function()
        if self.month_state == 1 then
            game.RewardHallCtrl.instance:SendCardReward(_month_card)
        elseif self.month_state == 0 then
            local cur_money = game.ShopCtrl.instance:GetMoneyByType(25)
            local cfg = config.weekly_month_card[10]
            if cur_money < cfg.rmb then
                open_recharge_tips(25)
            else
                game.RewardHallCtrl.instance:SendBuyCard(_month_card)
            end
        end
    end)

    local time = 3
    self.timer = global.TimerMgr:CreateTimer(0.5,
        function()
            time = time - 1
            if time <= 0 then
                self._layout_objs["effect"]:SetVisible(true)
                local ui_effect = self:CreateUIEffect(self._layout_objs["effect"], "effect/ui/hd_youlong.ab")
                ui_effect:SetLoop(true)
                self:DelTimer()
            end
        end)
end

function MonthCardTemplate:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function MonthCardTemplate:UpdateState()
    local server_time = global.Time:GetServerTime()
    local info = game.RewardHallCtrl.instance:GetCardData(_weekly_card)
    local cfg = config.weekly_month_card[9]
    self.week_state = 0
    if info then
        if info.expire_time == 0 or server_time >= info.expire_time then
            self._layout_objs.btn_buy1:SetText(cfg.buy_desc)
            self._layout_objs.btn_buy1:SetGray(false)
            self._layout_objs.btn_buy1:SetTouchEnable(true)
        else
            self.week_state = info.flag
            if info.flag == 1 then
                self._layout_objs.btn_buy1:SetText(config.words[3015])
                self._layout_objs.btn_buy1:SetGray(false)
                self._layout_objs.btn_buy1:SetTouchEnable(true)
            elseif info.flag == 2 then
                self._layout_objs.btn_buy1:SetText(config.words[3040])
                self._layout_objs.btn_buy1:SetGray(true)
                self._layout_objs.btn_buy1:SetTouchEnable(false)
            end
        end
    end

    info = game.RewardHallCtrl.instance:GetCardData(_month_card)
    cfg = config.weekly_month_card[10]
    self.month_state = 0
    if info then
        if info.expire_time == 0 or server_time >= info.expire_time then
            self._layout_objs.btn_buy2:SetText(cfg.buy_desc)
            self._layout_objs.btn_buy2:SetGray(false)
            self._layout_objs.btn_buy2:SetTouchEnable(true)
        else
            self.month_state = info.flag
            if info.flag == 1 then
                self._layout_objs.btn_buy2:SetText(config.words[3015])
                self._layout_objs.btn_buy2:SetGray(false)
                self._layout_objs.btn_buy2:SetTouchEnable(true)
            elseif info.flag == 2 then
                self._layout_objs.btn_buy2:SetText(config.words[3040])
                self._layout_objs.btn_buy2:SetGray(true)
                self._layout_objs.btn_buy2:SetTouchEnable(false)
            end
        end
    end
end

return MonthCardTemplate