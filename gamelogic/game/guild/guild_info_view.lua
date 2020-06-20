local GuildInfoView = Class(game.BaseView)

function GuildInfoView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_info_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third
end

function GuildInfoView:OpenViewCallBack(brief_info)
    self:Init(brief_info)
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendGuildGetDetail(brief_info.id)
end

function GuildInfoView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.OnGuildGetDetail, handler(self, self.OnGuildGetDetail)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildInfoView:Init(brief_info)
    self.brief_info = brief_info
    self.id = brief_info.id

    self.ctrl_tab = self:GetRoot():AddControllerCallback("ctrl_tab", function(idx)
        self:OnTabClick(idx+1)
    end)

    self.list_admin = self:CreateList("list_admin", "game/guild/item/guild_info_item")
    self.list_admin:SetRefreshItemFunc(function(item, idx)
        local item_info = self.admin_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)

    self.btn_apply = self._layout_objs.btn_apply
    self.btn_apply:AddClickCallBack(function()
        self:JoinGuild()
    end)
    self.btn_apply:SetEnable(not self.ctrl:IsGuildMember())

    self.txt_announce = self._layout_objs.txt_announce

    self:SetJoinText()
end

function GuildInfoView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName("")
end

function GuildInfoView:OnTabClick(idx)

end

function GuildInfoView:GetAdminList(members)
    local admin_list = {}
    for k, v in pairs(members) do
        local mem = v.mem
        if mem.pos >= game.GuildPos.ViceChief then
            table.insert(admin_list, mem)
        end
    end
    table.sort(admin_list, function(m, n)
        return m.pos < n.pos
    end)
    return admin_list
end

function GuildInfoView:UpdateResearchList(info)
    local bound = 2000
    local product_list = {}
    local military_list = {}

    for k, v in ipairs(info.study) do
        if v.id < bound then
            table.insert(product_list, v)
        else
            table.insert(military_list, v)
        end
    end
    table.sort(product_list, function(m, n)
        return m.id < n.id
    end)
    table.sort(military_list, function(m, n)
        return m.id < n.id
    end)

    for i=1, 20 do
        local item = self:GetTemplate("game/guild/item/guild_research_item", "research_item_"..i)
        item:ShowCircle(false)
        local item_info = (i <= 10) and product_list[i] or military_list[i-10]
        local cfg = config.guild_research_info[item_info.id]
        item:SetItemInfo(item_info)
        item:SetLock(self.ctrl:GetResearchBuildLevel(info.build) < cfg.need_lv)
        item:SetSelect(false)
    end
end

function GuildInfoView:JoinGuild()
    if self.ctrl:CanJoinGuild()then
        self.brief_info.apply = 1
        self.ctrl:SendGuildJoinReq(self.id)
    end
    self:SetJoinText()
end

function GuildInfoView:SetJoinText()
    if self.btn_apply then
        self.btn_apply:SetText(self.brief_info.apply == 1 and config.words[2778] or config.words[6004])
    end
end

function GuildInfoView:OnGuildGetDetail(info)
    if info.id == self.id then
        self.info = info

        self.admin_list_data = self:GetAdminList(info.members)
        self.list_admin:SetItemNum(#self.admin_list_data)
        self.txt_announce:SetText(info.announce)

        self:GetBgTemplate("common_bg"):SetTitleName(info.name)
        self:UpdateResearchList(info)
    end
end 

return GuildInfoView
