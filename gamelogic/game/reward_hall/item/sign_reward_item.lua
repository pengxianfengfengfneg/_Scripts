local SignRewardItem = Class(game.UITemplate)

local _config_goods = config.goods

function SignRewardItem:OpenViewCallBack()
    self:SetMask(false)
    self:SetSign(false)
    self:SetTag(false)
    self:SetSelect(false)

    self:GetRoot():AddClickCallBack(function()
        local sign_info = game.RewardHallCtrl.instance:GetSignData()
        if sign_info.is_get == 0 and self.day == sign_info.sign_day then
            game.RewardHallCtrl.instance:SendSignGetDaily()
        elseif self._layout_objs.tag:IsVisible() then
            game.RewardHallCtrl.instance:SendAddSign()
        else
            game.BagCtrl.instance:OpenTipsView(self.info)
        end
    end)
end

function SignRewardItem:CloseViewCallBack()
    if self.ui_effect then
        self.ui_effect = nil
    end
end

function SignRewardItem:SetItemInfo(info)
    info.id = config.money_type[info.id] and config.money_type[info.id].goods or info.id
    self.info = info

    local goods_config = _config_goods[info.id]
    self._layout_objs.bg:SetSprite("ui_common", "item" .. goods_config.color)
    self._layout_objs.image:SetSprite("ui_item", goods_config.icon, true)
    self._layout_objs.num:SetText(info.num)
end

function SignRewardItem:SetMask(val)
    self._layout_objs.mask:SetVisible(val)
    if val and self.ui_effect then
        self.ui_effect:Stop()
    end
end

function SignRewardItem:SetSign(val)
    self._layout_objs.sign:SetVisible(val)
end

function SignRewardItem:SetTag(val)
    self._layout_objs.tag:SetVisible(val)
    if val then
        self.ui_effect = self:CreateUIEffect(self._layout_objs.effect,  "effect/ui/hd_qiandao.ab")
        self.ui_effect:SetLoop(true)
    else
        if self.ui_effect then
            self.ui_effect:Stop()
        end
    end
end

function SignRewardItem:SetDay(day)
    self.day = day
    local sign_info = game.RewardHallCtrl.instance:GetSignData()
    if sign_info.is_get == 0 and day == sign_info.sign_day then
        self.ui_effect = self:CreateUIEffect(self._layout_objs.effect,  "effect/ui/hd_qiandao.ab")
        self.ui_effect:SetLoop(true)
    end
end

function SignRewardItem:GetDay()
    return self.day
end

function SignRewardItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
end

return SignRewardItem