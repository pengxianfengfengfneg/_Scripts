local GuildSevenLiveView = Class(game.BaseView)

function GuildSevenLiveView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_seven_live_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildSevenLiveView:_delete()
end

function GuildSevenLiveView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function GuildSevenLiveView:CloseViewCallBack()

end

function GuildSevenLiveView:Init()  
    self._layout_objs["txt_title1"]:SetText(config.words[4706])
    self._layout_objs["txt_content1"]:SetText(config.words[4707])
    self._layout_objs["txt_title2"]:SetText(config.words[4708])
    self._layout_objs["txt_content2"]:SetText(config.words[4709])
end

function GuildSevenLiveView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2774]):HideBtnBack()
end

return GuildSevenLiveView
