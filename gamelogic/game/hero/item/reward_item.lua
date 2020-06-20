local RewardItem = Class(game.UITemplate)

function RewardItem:OpenViewCallBack()
    self:BindEvent(game.HeroEvent.PulseTreasureDraw, function()
        self:SetItemInfo(self.info)
    end)

    self:GetRoot():AddClickCallBack(function()
        if self.can_get == true then
            game.HeroCtrl.instance:SendGetReward(self.info.id)
        else
            game.BagCtrl.instance:OpenGoodsInfoView({id = self.goods_info[1], num = self.goods_info[2]})
        end
    end)
end

function RewardItem:SetItemInfo(cfg)
    self.info = cfg
    self.goods_info = config.drop[cfg.drop].client_goods_list[1]
    local goods_cfg = config.goods[self.goods_info[1]]
    self._layout_objs.image:SetSprite("ui_item", goods_cfg.icon, true)
    self._layout_objs.bg:SetSprite("ui_common", "ndk_0" .. goods_cfg.color)
    local reward_info = game.HeroCtrl.instance:GetTreasureInfo()
    local flag = true
    for i, v in pairs(reward_info.acc) do
        if v.id == cfg.id then
            flag = false
            break
        end
    end
    if flag then
        self._layout_objs.text:SetText(reward_info.week_times .. "/" .. cfg.times)
        self.can_get = reward_info.week_times >= cfg.times
    else
        self.can_get = false
        self._layout_objs.text:SetText(config.words[2804])
    end
    game.Utils.SetTip(self:GetRoot(), self.can_get, cc.vec2(112, 105))
end

return RewardItem