local GuildTeamRewardPreview = Class(game.BaseView)

function GuildTeamRewardPreview:_init()
    self._package_name = "ui_carbon"
    self._com_name = "guild_team_reward_preview"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
end

function GuildTeamRewardPreview:OpenViewCallBack(info, times)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1416])

    self._layout_objs.text:SetText(string.format(config.words[1430], info.name, config.sys_config.sh_dung_chapter_max_progress.value, config.sys_config.sh_dung_weekly_reward_times.value, times))

    local list = self:CreateList("reward", "game/bag/item/goods_item")
    local rewards = config.drop[info.reward[times][2]].client_goods_list
    list:SetRefreshItemFunc(function(item, idx)
        local item_info = rewards[idx]
        item:SetItemInfo({ id = item_info[1], num = item_info[2] })
        item:SetShowTipsEnable(true)
    end)
    list:SetItemNum(#rewards)

end

function GuildTeamRewardPreview:OnEmptyClick()
    self:Close()
end

return GuildTeamRewardPreview