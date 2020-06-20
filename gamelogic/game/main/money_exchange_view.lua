local MoneyExchangeView = Class(game.BaseView)

local _cfg = config.money_exchange

function MoneyExchangeView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "money_exchange_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function MoneyExchangeView:OpenViewCallBack(type)
    if type == 1 then
        self:GetBgTemplate("common_bg"):SetTitleName(config.words[3251])
        self._layout_objs.txt_gold:SetText(_cfg[1].ratio .. config.money_type[_cfg[1].ttype].name)
    else
        self:GetBgTemplate("common_bg"):SetTitleName(config.words[3252])
        self._layout_objs.txt_gold:SetText(_cfg[2].ratio .. config.money_type[_cfg[2].ttype].name)
        self._layout_objs.txt_silver:SetText(_cfg[3].ratio .. config.money_type[_cfg[3].ttype].name)
    end

    self:BindEvent(game.MoneyEvent.Exchange, function()
        self:SwitchType(self.type)
    end)

    self:InitBtn()

    self:BindEvent(game.NumberKeyboardEvent.Number, function(key)
        local num = tonumber(self._layout_objs.num:GetText())
        if key >= 0 then
            self:SetNum(num * 10 + key)
        else
            self:SetNum(math.floor(num / 10))
        end
    end)

    self.controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:SwitchType(idx + 1)
    end)

    self.controller:SetSelectedIndexEx(type - 1)
end

function MoneyExchangeView:InitBtn()
    self._layout_objs.num:AddClickCallBack(function()
        game.MainUICtrl.instance:OpenNumberKeyboard(nil, 739)
    end)

    self._layout_objs.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_ok:AddClickCallBack(function()
        local own = game.BagCtrl.instance:GetMoneyByType(_cfg[self.type].stype)
        if own <= 0 then
            if self.type == 3 then
                game.GameMsgCtrl.instance:PushMsg(config.words[3254])
            else
                local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[3253])
                tips_view:SetBtn1(nil, function()
                    game.RechargeCtrl.instance:OpenView()
                end)
                tips_view:Open()
            end
            return
        end
        local num = tonumber(self._layout_objs.num:GetText())
        game.MainUICtrl.instance:SendMoneyExchange(self.type, num)
    end)
end

function MoneyExchangeView:SwitchType(type)
    self.type = type
    local cfg = _cfg[type]
    local own = game.BagCtrl.instance:GetMoneyByType(cfg.stype)
    if cfg.stype == 25 then
        own = own .. string.format(config.words[3257], game.BagCtrl.instance:GetMoneyByType(game.MoneyType.BackupGold))
    end
    self._layout_objs.cost:SetText(own)

    self:SetNum(1)
end

function MoneyExchangeView:SetNum(num)
    local own = game.BagCtrl.instance:GetMoneyByType(_cfg[self.type].stype)
    if num > own then
        num = own
    end
    self._layout_objs.num:SetText(num)
    local cfg = _cfg[self.type]
    self._layout_objs.get:SetText(num * cfg.ratio)
end

function MoneyExchangeView:OnEmptyClick()
    self:Close()
end

return MoneyExchangeView
