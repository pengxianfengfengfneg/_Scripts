local GuildWarView = Class(game.BaseView)

function GuildWarView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_war_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildWarView:_delete()
end

function GuildWarView:OpenViewCallBack()
    self:InitBg()
end

function GuildWarView:CloseViewCallBack()

end

function GuildWarView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4780]):HideBtnBack()
end

return GuildWarView
