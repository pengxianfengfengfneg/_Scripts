local GuildTeamCarbonItem = Class(game.UITemplate)

function GuildTeamCarbonItem:OpenViewCallBack()
    self._layout_objs.btn:AddClickCallBack(function()
        local times = self.chapter_info.reward_times + 1
        local weekly_max_times = config.sys_config.sh_dung_weekly_reward_times.value
        times = times <= weekly_max_times and times or weekly_max_times
        game.CarbonCtrl.instance:OpenGuildTeamRewardPreview(self.info, times)
    end)
end

function GuildTeamCarbonItem:SetItemInfo(info)
    self.info = info
    self._layout_objs.bg:SetSprite("ui_carbon", info.client_res)
    local guild_info = game.GuildCtrl.instance:GetGuildInfo()
    for _, v in pairs(guild_info.sh_dung) do
        if v.id == info.id then
            self.chapter_info = v
            break
        end
    end
    if self.chapter_info.id < guild_info.sh_cur_page then
        self._layout_objs.text:SetText(config.words[1427])
    elseif self.chapter_info.id == guild_info.sh_cur_page then
        self._layout_objs.text:SetText(string.format(config.words[1428], self.chapter_info.chal_times, info.times))
    else
        self._layout_objs.text:SetText(string.format(config.words[1429], self.chapter_info.id - 1))
    end
end

return GuildTeamCarbonItem