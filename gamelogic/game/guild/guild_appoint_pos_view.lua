local GuildAppointPosView = Class(game.BaseView)

function GuildAppointPosView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_appoint_pos_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Fouth
end

function GuildAppointPosView:_delete()

end

function GuildAppointPosView:OpenViewCallBack(member_info)
    self.member_info = member_info
    self:Init()
    self:InitBg()
end

function GuildAppointPosView:CloseViewCallBack()

end

function GuildAppointPosView:Init()  
    self.btn_chief = self._layout_objs["btn_chief"]
    self.btn_vice_chief = self._layout_objs["btn_vice_chief"]
    self.btn_elder = self._layout_objs["btn_elder"]
    self.btn_elite = self._layout_objs["btn_elite"]
    self.btn_mass = self._layout_objs["btn_mass"]

    self:RegisterAllEvents()
end

function GuildAppointPosView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2359]):HideBtnBack()

    self.btn_chief:SetText(config.words[2360])
    self.btn_chief:AddClickCallBack(function()
        self.ctrl:SendGuildAppointPos(self.member_info.id, 5)
    end)

    self.btn_vice_chief:SetText(self:GetAppointPosText(2361, 4))
    self.btn_vice_chief:AddClickCallBack(function()
        self.ctrl:SendGuildAppointPos(self.member_info.id, 4)
    end)

    self.btn_elder:SetText(self:GetAppointPosText(2362, 3))
    self.btn_elder:AddClickCallBack(function()
        self.ctrl:SendGuildAppointPos(self.member_info.id, 3)
    end)

    self.btn_elite:SetText(self:GetAppointPosText(2363, 2))
    self.btn_elite:AddClickCallBack(function()
        self.ctrl:SendGuildAppointPos(self.member_info.id, 2)
    end)

    self.btn_mass:SetText(config.words[2364])
    self.btn_mass:AddClickCallBack(function()
        self.ctrl:SendGuildAppointPos(self.member_info.id, 1)
    end)
end

function GuildAppointPosView:Refresh()
    self.btn_vice_chief:SetText(self:GetAppointPosText(2361, 4))
    self.btn_elder:SetText(self:GetAppointPosText(2362, 3))
    self.btn_elite:SetText(self:GetAppointPosText(2363, 2))
end

function GuildAppointPosView:GetAppointPosText(words_idx, pos)
    local guild_level = self.ctrl:GetGuildLevel()
    return string.format("%s(%d/%d)", config.words[words_idx], self.ctrl:GetGuildPosMemberNums(pos), config.guild_pos[guild_level][pos].num)
end

function GuildAppointPosView:OnEmptyClick()
    self:Close()
end

function GuildAppointPosView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.AppointPos] = function()
            self:Close()
        end,
        [game.GuildEvent.UpdateGuildLevel] = function()
            self:Refresh()
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildAppointPosView
