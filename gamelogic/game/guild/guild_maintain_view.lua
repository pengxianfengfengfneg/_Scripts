local GuildMaintainView = Class(game.BaseView)

function GuildMaintainView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_maintain_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildMaintainView:_delete()
end

function GuildMaintainView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function GuildMaintainView:CloseViewCallBack()

end

function GuildMaintainView:Init()
    self.txt_content2 = self._layout_objs["txt_content2"]

    self._layout_objs["txt_title1"]:SetText(config.words[4710])
    self._layout_objs["txt_content1"]:SetText(config.words[4711])
    self._layout_objs["txt_title2"]:SetText(config.words[4712])
    self._layout_objs["txt_title3"]:SetText(config.words[4713])
    self._layout_objs["txt_content3"]:SetText(config.words[4714])

    self:Refresh()
end

function GuildMaintainView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2773]):HideBtnBack()
end

function GuildMaintainView:Refresh()
    local std_funds = self.ctrl:GetStandardDenfFunds()
    self.txt_content2:SetText(config.words[2779] .. "\n" .. string.format(config.words[2775], std_funds))
end

function GuildMaintainView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateGuildLevel] = function()
            self:Refresh()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildMaintainView
