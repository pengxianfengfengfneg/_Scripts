local FirstRewardView = Class(game.BaseView)

function FirstRewardView:_init(ctrl)
    self._package_name = "ui_carbon"
    self._com_name = "chapter_reward_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
    self.ctrl = ctrl
end

function FirstRewardView:OpenViewCallBack(carbon_id, level)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1416])

    local list = self:CreateList("list_reward", "game/bag/item/goods_item")

    local dun_cfg = config.dungeon_lv[carbon_id][level]
    local reward_list = config.drop[dun_cfg.first_award].client_goods_list

    list:SetRefreshItemFunc(function(item, idx)
        local info = reward_list[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    list:SetVirtual(false)

    list:SetItemNum(#reward_list)

    local dunge_data = game.CarbonCtrl.instance:GetData()
    self.hero_dun_data = dunge_data:GetDungeDataByID(carbon_id)
    local flag = true
    for _, v in pairs(self.hero_dun_data.first_reward) do
        if v.lv == level then
            flag = false
        end
    end
    self._layout_objs.btn_get:SetVisible(flag and self.hero_dun_data.max_lv > level)
    self._layout_objs.text:SetText(string.format(config.words[1949], dun_cfg.name))
    self._layout_objs.btn_get:AddClickCallBack(function()
        game.CarbonCtrl.instance:SendGetFirstRwd(carbon_id, level, 0)
        self:Close()
    end)
end

function FirstRewardView:OnEmptyClick()
    self:Close()
end

return FirstRewardView