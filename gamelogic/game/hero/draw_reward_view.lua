local DrawRewardView = Class(game.BaseView)

function DrawRewardView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "reward_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function DrawRewardView:OpenViewCallBack(rewards)
    self._layout_objs.btn_ok:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.btn_again:AddClickCallBack(function()
        self.ctrl:SendDrawTreasure(10)
        self:Close()
    end)

    local reward_list = {}
    for _, v in pairs(rewards) do
        local goods_info = config.drop[v.reward].client_goods_list
        for _, val in pairs(goods_info) do
            table.insert(reward_list, val)
        end
    end

    self.list = self:CreateList("list", "game/bag/item/goods_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = reward_list[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    self.list:SetItemNum(#reward_list)
end

function DrawRewardView:OnEmptyClick()
    self:Close()
end

return DrawRewardView
