local AccRewardItem = Class(game.UITemplate)

local _cfg_goods = config.goods

function AccRewardItem:OpenViewCallBack()
    self._layout_objs.light:SetVisible(false)
    self._layout_objs.got:SetVisible(false)

    self:GetRoot():AddClickCallBack(function()
        if self.state == 1 then
            game.RewardHallCtrl.instance:SendSignGetAcc(self.info.id)
        else
            game.BagCtrl.instance:OpenTipsView(self.item_info)
        end
    end)
end

function AccRewardItem:SetItemInfo(info)
    self.info = info
    if info.day == 0 then
        self._layout_objs.text:SetText(config.words[3055])
    else
        self._layout_objs.text:SetText(string.format(config.words[3035], info.day))
    end
    local drop_info = config.drop[info.reward].client_goods_list[1]
    self.item_info = { id = drop_info[1], num = drop_info[2] }
    self.item_info.id = config.money_type[self.item_info.id] and config.money_type[self.item_info.id].goods or self.item_info.id
    local cfg = _cfg_goods[self.item_info.id]
    self._layout_objs.image:SetSprite("ui_item", cfg.icon, true)
    self._layout_objs.num:SetText(self.item_info.num)
    self._layout_objs.bg:SetSprite("ui_common", "ndk_0" .. cfg.color, true)
end

function AccRewardItem:GetDay()
    return self.info.day
end

function AccRewardItem:SetState(state)
    self.state = state
    self._layout_objs.light:SetVisible(state == 1)
    self._layout_objs.got:SetVisible(state == 2)
    game.Utils.SetTip(self:GetRoot(), state == 1, { x = 120, y = 28 })
end

return AccRewardItem