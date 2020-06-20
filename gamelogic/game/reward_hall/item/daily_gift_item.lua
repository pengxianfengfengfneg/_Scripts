local DailyGiftItem = Class(game.UITemplate)

function DailyGiftItem:OpenViewCallBack()
    self.buy_state = 0
    self:BindEvent(game.RewardHallEvent.UpdateDailyGiftInfo, function()
        self:SetItemInfo(self.info)
    end)

    self._layout_objs.btn:AddClickCallBack(function()
        if self.buy_state == 1 then
            if self.buy_id == 1 then
                game.RewardHallCtrl.instance:SendDailyGiftGet(self.info.grade, 1)
            else
                game.RewardHallCtrl.instance:OpenGetGiftView(self.info)
            end
        end
    end)

    self.item = self:GetTemplate("game/bag/item/goods_item", "item")
    self.item:SetShowTipsEnable(true)
end

function DailyGiftItem:SetItemInfo(info)
    self.info = info
    self._layout_objs.name:SetText(info.name)
    self._layout_objs.text:SetText(string.format(config.words[3051], info.gold))
    self._layout_objs.gift:SetText(info.gift)
    local drop_info = config.drop[info.reward[1][3]]
    local show_goods = drop_info.client_goods_list[1]
    self.item:SetItemInfo({ id = show_goods[1], num = show_goods[2] })
    self.buy_id = 1
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    for _, v in ipairs(info.reward) do
        if role_lv >= v[2] then
            self.buy_id = v[1]
        end
    end
    local gift_info = game.RewardHallCtrl.instance:GetDailyGiftInfo()
    if gift_info == nil then
        return
    end
    self.buy_state = 0
    for _, v in pairs(gift_info) do
        if v.grade == info.grade then
            self.buy_state = v.state
        end
    end
    if self.buy_state == 0 then
        self._layout_objs.btn:SetText(config.words[3046])
        self._layout_objs.btn:SetGray(false)
        self._layout_objs.btn:SetTouchEnable(true)
    elseif self.buy_state == 1 then
        self._layout_objs.btn:SetText(config.words[3047])
        self._layout_objs.btn:SetGray(false)
        self._layout_objs.btn:SetTouchEnable(true)
    else
        self._layout_objs.btn:SetText(config.words[3052])
        self._layout_objs.btn:SetGray(true)
        self._layout_objs.btn:SetTouchEnable(false)
    end
end

function DailyGiftItem:SetBG(val)
    if val then
        self._layout_objs.bg:SetSprite("ui_common", "009_1")
    else
        self._layout_objs.bg:SetSprite("ui_common", "009_2")
    end
end

return DailyGiftItem