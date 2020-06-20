local GuildBanquetView = Class(game.BaseView)

function GuildBanquetView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_banquet_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Fouth
end

function GuildBanquetView:_delete()

end

function GuildBanquetView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function GuildBanquetView:CloseViewCallBack()

end

function GuildBanquetView:Init()
    self.txt_cost = self._layout_objs["txt_cost"]
    self.txt_reward = self._layout_objs["txt_reward"]

    self.btn_banquet = self._layout_objs["btn_banquet"]
    self.btn_banquet:SetText(config.words[2790])
    self.btn_banquet:AddClickCallBack(handler(self, self.OnBanquet))

    self._layout_objs["txt_title"]:SetText(config.words[2792])
    self._layout_objs["txt_info"]:SetText(config.words[2791])
    self._layout_objs["txt_cost"]:SetText(string.format(config.words[2788], config.guild_junket.cost_gold))
    self._layout_objs["txt_reward"]:SetText(string.format(config.words[2789], config.guild_junket.get_cont))
end

function GuildBanquetView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2787]):HideBtnBack()
end

function GuildBanquetView:Refresh()
    
end

function GuildBanquetView:OnBanquet()
    self.ctrl:SendGuildBanquet()
    self:Close()
end

function GuildBanquetView:RegisterAllEvents()
    local events = {
        
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildBanquetView
