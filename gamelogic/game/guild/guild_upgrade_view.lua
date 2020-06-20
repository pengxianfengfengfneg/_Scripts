local GuildUpgradeView = Class(game.BaseView)

function GuildUpgradeView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_upgrade_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildUpgradeView:_delete()
    
end

function GuildUpgradeView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function GuildUpgradeView:CloseViewCallBack()

end

function GuildUpgradeView:Init()
    self._layout_objs.txt_level:SetText(config.words[2764])
    self._layout_objs.txt_welfare:SetText(config.words[2765])
    self._layout_objs.txt_info:SetText(config.words[2768])

    self.txt_cur_level = self._layout_objs.txt_cur_level
    self.txt_next_level = self._layout_objs.txt_next_level
    self.txt_cur_num = self._layout_objs.txt_cur_num
    self.txt_next_num = self._layout_objs.txt_next_num
    self.txt_cost = self._layout_objs.txt_cost
    self.txt_funds = self._layout_objs.txt_funds
    self.txt_min_funds = self._layout_objs.txt_min_funds

    self.btn_upgrade = self._layout_objs.btn_upgrade
    self.btn_upgrade:SetText(config.words[2770])
    self.btn_upgrade:AddClickCallBack(handler(self, self.OnUpgrade))

    self:Refresh()
    self:RegisterAllEvents()
end

function GuildUpgradeView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2718])
end

function GuildUpgradeView:Refresh()
    local guild_info = self.ctrl:GetGuildInfo()
    local max_level = config.guild_level[#config.guild_level].level
    local next_level = guild_info.level + 1
    local level_cfg = self.ctrl:GetGuildLevelConfig()

    if next_level <= max_level then
        self.txt_next_level:SetText(guild_info.level + 1)
        self.txt_next_num:SetText("999")
    else
        self.txt_next_level:SetText(config.words[2399])
        self.txt_next_num:SetText(config.words[2399])
    end

    self.txt_cur_level:SetText(guild_info.level)
    self.txt_cur_num:SetText(string.format(config.words[2769], level_cfg.mem_num))   
    self.txt_cost:SetText(string.format(config.words[2766], level_cfg.funds))
    self.txt_funds:SetText(string.format(config.words[2767], guild_info.funds))
    self.txt_min_funds:SetText(string.format(config.words[2776], level_cfg.min_have_funds))
end

function GuildUpgradeView:OnUpgrade()
    self.ctrl:SendGuildUpgrade()
end

function GuildUpgradeView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateGuildLevel] = function()
            self:Refresh()
        end,
        [game.GuildEvent.UpdateGuildInfo] = function()
            self:Refresh()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildUpgradeView
