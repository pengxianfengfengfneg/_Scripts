local LuckyMoneyOpenView = Class(game.BaseView)

function LuckyMoneyOpenView:_init(ctrl)
    self._package_name = "ui_lucky_money"
    self._com_name = "lucky_money_open_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function LuckyMoneyOpenView:OpenViewCallBack(info)
    self:Init(info)
end

function LuckyMoneyOpenView:Init(info)
    self.lucky_money_com = self:GetTemplate("game/lucky_money/lucky_money_com", "lucky_money_com")
    self.lucky_money_com:RefreshGuildLuckyMoney(info)
end

function LuckyMoneyOpenView:OnEmptyClick()
    self:Close()
end

return LuckyMoneyOpenView
