local FirstRewardView = Class(game.BaseView)

function FirstRewardView:_init(ctrl)
    self._package_name = "ui_carbon"
    self._com_name = "chapter_reward_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self.ctrl = ctrl
end

function FirstRewardView:OpenViewCallBack(dun_id, level)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1416])

    self._layout_objs.btn_get:AddClickCallBack(function()
        self.ctrl:SendGetFirstRwd(dun_id, level, 0)
        self:Close()
    end)

    local list = self:CreateList("list_reward", "game/bag/item/goods_item")

    list:SetRefreshItemFunc(function(item, idx)
        local info = self.first_reward[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    list:SetVirtual(false)

    local carbon_data = self.ctrl:GetData()
    local dun_data = carbon_data:GetDungeDataByID(dun_id)
    local reward_id = config.dungeon_lv[dun_id][level].first_award
    self.first_reward = config.drop[reward_id].client_goods_list

    list:SetItemNum(#self.first_reward)

    local got = true
    for k, v in pairs(dun_data.first_reward) do
        if v.lv == level then
            got = false
            break
        end
    end

    self._layout_objs.btn_get:SetVisible(got)
end

function FirstRewardView:OnEmptyClick()
    self:Close()
end

return FirstRewardView