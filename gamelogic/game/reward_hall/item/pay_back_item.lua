local PayBackItem = Class(game.UITemplate)

function PayBackItem:OpenViewCallBack()
    self:BindEvent(game.RewardHallEvent.UpdatePayBackInfo, function()
        self:SetItemInfo(self.info)
    end)

    self._layout_objs.btn:AddClickCallBack(function()
        if self.cost > 0 then
            game.MainUICtrl.instance:OpenAutoMoneyExchangeView(self.info.cost_type, self.cost, function()
                game.RewardHallCtrl.instance:SendPayBackGet(self.info.type)
            end)
        else
            game.RewardHallCtrl.instance:SendPayBackGet(self.info.type)
        end
    end)

    local item = self:GetTemplate("game/bag/item/goods_item", "item")
    item:SetItemInfo({ id = config.money_type[1].goods })
    item:SetShowTipsEnable(true)
end

function PayBackItem:SetItemInfo(info)
    self.info = info
    self.cost = 0
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local payback_info = game.RewardHallCtrl.instance:GetPayBackInfo()
    if payback_info.type == 0 then
        if role_lv >= info.level then
            self._layout_objs.btn:SetGray(false)
            self._layout_objs.btn:SetTouchEnable(true)
            if info.cost_type == 0 then
                self._layout_objs.btn:SetText(config.words[3048])
            else
                self.cost = math.floor(info.cost * payback_info.leave_num / info.max_num)
                local cost = self.cost .. config.money_type[info.cost_type].name
                self._layout_objs.btn:SetText(cost .. config.words[3047])
            end
        else
            self._layout_objs.btn:SetGray(true)
            self._layout_objs.btn:SetTouchEnable(false)
            self._layout_objs.btn:SetText(info.level .. config.words[1217] .. config.words[3047])
        end
    else
        self._layout_objs.btn:SetTouchEnable(false)
        self._layout_objs.btn:SetGray(true)
        if payback_info.type == info.type then
            self._layout_objs.btn:SetText(config.words[3040])
        else
            self._layout_objs.btn:SetText(config.words[3049])
        end
    end

    local exp = math.floor(payback_info.leave_num / info.max_num * config.level[role_lv][info.cfg_origin])
    self._layout_objs.exp:SetText(exp .. config.words[3050])

    self:SetBG(info.type)
end

function PayBackItem:SetBG(val)
    self._layout_objs.bg:SetSprite("ui_reward_hall", tostring(11 + val))
end

return PayBackItem