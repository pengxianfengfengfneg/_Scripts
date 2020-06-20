local GuildChangeAnnounceView = Class(game.BaseView)

function GuildChangeAnnounceView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_change_announce_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildChangeAnnounceView:_delete()
    
end

function GuildChangeAnnounceView:OpenViewCallBack()
    self:Init()
    self:InitBg()
end

function GuildChangeAnnounceView:Init()
    self.txt_content = self._layout_objs["txt_content"]
    self.txt_desc = self._layout_objs["txt_desc"]

    self.btn_change = self._layout_objs["btn_change"]
    self.btn_change:AddClickCallBack(function()
        local content = self.txt_content:GetText()
        if game.Utils.CheckMaskChatWords(self.txt_content:GetText()) then
            game.GameMsgCtrl.instance:PushMsgCode(1413)
        else
            self.ctrl:SendGuildChangeAnnounce(content)
        end
    end)

    self:RegisterAllEvents()
end

function GuildChangeAnnounceView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2327])

    self.txt_content:SetText(self.ctrl:GetGuildInfo().announce)
    self.txt_desc:SetText(config.words[2329])
    self.btn_change:SetText(config.words[2330])
end

function GuildChangeAnnounceView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.ChangeAnnounce] = function()
            self:Close()
        end,
    }
    for i, v in pairs(events) do
        self:BindEvent(i, v)
    end
end

return GuildChangeAnnounceView
