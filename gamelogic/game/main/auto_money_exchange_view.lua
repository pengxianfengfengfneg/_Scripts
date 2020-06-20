local AutoMoneyExchangeView = Class(game.BaseView)

local _cfg = config.money_exchange

function AutoMoneyExchangeView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "auto_money_exchange_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function AutoMoneyExchangeView:OpenViewCallBack(money_type, num, callback)
    self.type = money_type
    self.callback = callback
    self.exchange_num = tonumber(num)
    self.bg_template = self:GetBgTemplate("common_bg")

    self:BindEvent(game.MoneyEvent.Exchange, function()
        if callback then
            callback()
        end
        self:Close()
    end)

    self:SetTitle()
    self:SetContent()
end

function AutoMoneyExchangeView:SetTitle()
    local cfg = config.money_type
    self.bg_template:SetTitleName(cfg[self.type].name .. config.words[3258])
end

function AutoMoneyExchangeView:SetContent()
    local str
    local cfg = config.money_type
    local gold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Gold)
    local backup_gold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.BackupGold)
    local silver = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Silver)
    local copper = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Copper)
    local txt_str = "<font color=%s>%d</font><img asset=\'ui_common:%s\'/>"
    if self.type == game.MoneyType.Copper then
        local need = self.exchange_num - copper
        str = string.format(config.words[3255], need, cfg[self.type].icon)

        local gold_ratio = _cfg[2].ratio
        local silver_ratio = _cfg[3].ratio
        local need_gold = math.ceil(need / gold_ratio)
        local need_silver = math.ceil(need / silver_ratio)
        local clr = "#ffffff"
        if gold + backup_gold < need_gold then
            clr = cc.GoodsColor2[6]
        end
        self._layout_objs.text1:SetText(string.format(txt_str, clr, need_gold, cfg[game.MoneyType.Gold].icon))
        self._layout_objs.btn1:AddClickCallBack(function()
            if gold + backup_gold >= need_gold then
                game.MainUICtrl.instance:SendMoneyExchange(2, need_gold)
            else
                local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[3253])
                tips_view:SetBtn1(nil, function()
                    game.RechargeCtrl.instance:OpenView()
                end)
                tips_view:Open()
            end
        end)

        clr = "#ffffff"
        if silver < need_silver then
            clr = cc.GoodsColor2[6]
        end
        self._layout_objs.text2:SetText(string.format(txt_str, clr, need_silver, cfg[game.MoneyType.Silver].icon))
        self._layout_objs.btn2:AddClickCallBack(function()
            if silver >= need_silver then
                game.MainUICtrl.instance:SendMoneyExchange(3, need_silver)
            else
                self.type = game.MoneyType.Silver
                self.exchange_num = need_silver
                self.bg_template = self:GetBgTemplate("common_bg")

                self:SetTitle()
                self:SetContent()
            end
        end)
    elseif self.type == game.MoneyType.Silver then
        local ratio = _cfg[1].ratio
        self.exchange_num = self.exchange_num - silver
        local need = math.ceil(self.exchange_num / ratio)
        local need_backup = backup_gold >= need and need or backup_gold
        local need_gold = need - need_backup
        str = string.format(config.words[3256], self.exchange_num, cfg[self.type].icon, need_gold, need_backup, cfg[game.MoneyType.Gold].icon, need * ratio - self.exchange_num, cfg[self.type].icon)

        self._layout_objs.btn1:AddClickCallBack(function()
            self:Close()
        end)
        self._layout_objs.text1:SetText(config.words[101])
        self._layout_objs.btn2:AddClickCallBack(function()
            if gold >= need_gold then
                game.MainUICtrl.instance:SendMoneyExchange(1, need)
            else
                local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[3253])
                tips_view:SetBtn1(nil, function()
                    game.RechargeCtrl.instance:OpenView()
                end)
                tips_view:Open()
            end
        end)
        local clr = "#ffffff"
        if gold < need_gold then
            clr = cc.GoodsColor2[6]
        end
        self._layout_objs.text2:SetText(string.format(txt_str, clr, need, cfg[game.MoneyType.Gold].icon))
    elseif self.type == game.MoneyType.BindGold or self.type == game.MoneyType.Gold then
        local need_backup = backup_gold >= self.exchange_num and self.exchange_num or backup_gold
        local need_gold = self.exchange_num - need_backup
        str = string.format(config.words[3259], self.exchange_num, cfg[self.type].icon, cfg[self.type].name, need_gold, need_backup, cfg[game.MoneyType.Gold].icon)
        self._layout_objs.btn1:AddClickCallBack(function()
            self:Close()
        end)
        self._layout_objs.text1:SetText(config.words[101])
        self._layout_objs.btn2:AddClickCallBack(function()
            if gold >= need_gold then
                if self.callback then
                    self.callback()
                end
                self:Close()
            else
                local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[3253])
                tips_view:SetBtn1(nil, function()
                    game.RechargeCtrl.instance:OpenView()
                end)
                tips_view:Open()
            end
        end)
        self._layout_objs.text2:SetText(config.words[100])
    else
        self._layout_objs.btn1:AddClickCallBack(function()
            self:Close()
        end)
        self._layout_objs.text1:SetText(config.words[101])
        self._layout_objs.btn2:AddClickCallBack(function()
            self:Close()
        end)
        self._layout_objs.text2:SetText(config.words[100])
        str = string.format(config.words[3260], cfg[self.type].name)
    end
    self._layout_objs.txt_content:SetText(str)
end

function AutoMoneyExchangeView:OnEmptyClick()
    self:Close()
end

return AutoMoneyExchangeView
