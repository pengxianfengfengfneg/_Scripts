local TreasureView = Class(game.BaseView)

function TreasureView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "treasure_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self._show_money = true

    self.ctrl = ctrl
end

function TreasureView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[3139])
    self._layout_objs.btn_one:AddClickCallBack(function()
        game.HeroCtrl.instance:SendDrawTreasure(1)
    end)
    self._layout_objs.btn_ten:AddClickCallBack(function()
        game.HeroCtrl.instance:SendDrawTreasure(10)
    end)

    self:BindEvent(game.HeroEvent.PulseTreasureDraw, function()
        self:SetOwnNum()
    end)

    self.items = {}
    for i = 1, 8 do
        self.items[i] = self:GetTemplate("game/bag/item/goods_item", "goods_item" .. i)
        self.items[i]:SetShowTipsEnable(true)
    end

    self.list = self:CreateList("list", "game/hero/item/reward_item")

    self:SetViewInfo()
end

function TreasureView:SetViewInfo()
    for i, v in ipairs(config.pulse_treasure) do
        local goods_info = config.drop[v.drop].client_goods_list[1]
        self.items[i]:SetItemInfo({ id = goods_info[1], num = goods_info[2] })
    end

    self.list:SetRefreshItemFunc(function(item, idx)
        local info = config.pulse_treasure_reward[idx]
        item:SetItemInfo(info)
    end)
    self.list:SetItemNum(#config.pulse_treasure_reward)

    self:SetOwnNum()
end

function TreasureView:SetOwnNum()
    local item_id = config.sys_config.channel_draw_item.value
    local own = game.BagCtrl.instance:GetNumById(item_id)
    self._layout_objs.own_num:SetText(own)

    local info = game.HeroCtrl.instance:GetTreasureInfo()
    self._layout_objs.text:SetText(string.format(config.words[3127], 10 - info.times))
end

return TreasureView