local GuildInfoTemplate = Class(game.UITemplate)

function GuildInfoTemplate:_init(view)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
end

function GuildInfoTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function GuildInfoTemplate:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateGuildInfo, handler(self, self.UpdateGuildInfo)},
        {game.GuildEvent.UpdateAnnounce, handler(self, self.UpdateAnnounce)},
        {game.GuildEvent.UpdateGuildName, handler(self, self.UpdateGuildName)},
        {game.GuildEvent.UpdateMemberPos, handler(self, self.UpdateMemberPos)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function GuildInfoTemplate:Init()
    self.txt_name = self._layout_objs.txt_name
    self.txt_level = self._layout_objs.txt_level
    self.txt_num = self._layout_objs.txt_num
    self.txt_funds = self._layout_objs.txt_funds
    self.txt_defend = self._layout_objs.txt_defend
    self.txt_seven_live = self._layout_objs.txt_seven_live
    self.txt_war = self._layout_objs.txt_war
    self.txt_group = self._layout_objs.txt_group
    self.txt_announce = self._layout_objs.txt_announce

    self.btn_back = self._layout_objs.btn_back
    self.btn_back:AddClickCallBack(function()
        local scene_id = config.sys_config.guild_seat_scene.value
        game.Scene.instance:GetMainRole():GetOperateMgr():DoChangeScene(scene_id)
        game.GuildCtrl.instance:CloseView()
    end)

    self.btn_lobby = self._layout_objs.btn_lobby
    self.btn_lobby:AddClickCallBack(function()
        self.ctrl:OpenGuildLobbyView(1)
    end)

    self.btn_seven_live = self._layout_objs.btn_seven_live
    self.btn_seven_live:AddClickCallBack(function()
        self.ctrl:OpenGuildSevenLiveView()
    end)

    self.btn_defend = self._layout_objs.btn_defend
    self.btn_defend:AddClickCallBack(function()
        self.ctrl:OpenGuildMaintainView()
    end)

    self.btn_war = self._layout_objs.btn_war
    self.btn_war:AddClickCallBack(function()
        self.ctrl:OpenGuildWarView()
    end)

    self.btn_recruit = self._layout_objs.btn_recruit
    self.btn_recruit:AddClickCallBack(function()
        self.ctrl:OpenGuildRecruitView()
    end)

    self.btn_change_announce = self._layout_objs.btn_change_announce
    self.btn_change_announce:AddClickCallBack(function()
        self.ctrl:OpenGuildChangeAnnounceView()
    end)
    self.btn_change_announce:SetVisible(self.ctrl:CanChangeAnnounce())

    self._layout_objs.txt_group_label:SetVisible(false)
    self._layout_objs.n56:SetVisible(false)
    self._layout_objs.txt_group:SetVisible(false)
end

function GuildInfoTemplate:UpdateGuildInfo()
    local guild_info = self.ctrl:GetGuildInfo()
    
    self.txt_name:SetText(guild_info.name)
    self.txt_level:SetText(string.format(config.words[2314], guild_info.level))
    self.txt_announce:SetText(guild_info.announce)
    self.txt_seven_live:SetText(guild_info.recently_live)
    self.txt_war:SetText(guild_info.battle)

    self.btn_recruit:SetVisible(self.ctrl:CanRecruit(self.ctrl:GetGuildMemberPos()))
    
    self:SetMemberNumsText(guild_info)
    self:SetMaintainFundsText(guild_info)
    self:SetFundsText(guild_info)
end

function GuildInfoTemplate:UpdateGuildName(id, name)
    if id == self.ctrl:GetGuildId() then
        self.txt_name:SetText(name)
    end
end

function GuildInfoTemplate:SetMemberNumsText(guild_info)
    local online_num = self.ctrl:GetMemberOnlineNums()
    self.txt_num:SetText(string.format(config.words[2709], #guild_info.members, self.ctrl:GetGuildMaxMemberNum(), online_num))
end

function GuildInfoTemplate:SetFundsText(guild_info)
    self.txt_funds:SetText(guild_info.funds)    
end

function GuildInfoTemplate:SetMaintainFundsText(guild_info)
    local funds = 0
    if guild_info.denf_state == 0 then
        funds = self.ctrl:GetDenfFunds()
    else
        funds = self.ctrl:GetLowDenfFunds() .. config.words[2756]
    end
    self.txt_defend:SetText(funds)
end

function GuildInfoTemplate:UpdateMemberPos(role_id, pos)
    if game.RoleCtrl.instance:GetRoleId() == role_id then
        self.btn_recruit:SetVisible(self.ctrl:CanRecruit(pos))
        self.btn_change_announce:SetVisible(self.ctrl:CanChangeAnnounce())
    end
end

function GuildInfoTemplate:UpdateAnnounce(announce)
    self.txt_announce:SetText(announce)
end

return GuildInfoTemplate