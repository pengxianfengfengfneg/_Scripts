local GuildBattleInfoView = Class(game.BaseView)

function GuildBattleInfoView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_battleinfo_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildBattleInfoView:_delete()
end

function GuildBattleInfoView:OpenViewCallBack()
    self:InitBg()
end

function GuildBattleInfoView:CloseViewCallBack()

end

function GuildBattleInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4781]):HideBtnBack()
end

return GuildBattleInfoView
