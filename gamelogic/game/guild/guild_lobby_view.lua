local GuildLobbyView = Class(game.BaseView)

local PageIndex = {
    Lobby = 0,
    DeclareWar = 1,
    Hostile = 2,
}

function GuildLobbyView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_lobby_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildLobbyView:OpenViewCallBack(index)
    self:Init(index)
    self:InitBg()
    self:InitGuildList()
    self:RegisterAllEvents()
    self.ctrl:SendGuildList()
end

function GuildLobbyView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateGuildList, handler(self, self.UpdateGuildList)},
        {game.GuildEvent.ApproveResult, handler(self, self.OnApproveResult)},
        {game.GuildEvent.UpdateMemberPos, handler(self, self.SetPageIndex)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildLobbyView:Init(index)
    self.page_index = index and index-1 or 0

    self.btn_create = self._layout_objs.btn_create
    self.btn_create:AddClickCallBack(function()
        self.ctrl:OpenGuildCreateView()
    end)
    self.btn_create:SetEnable(not self.ctrl:IsGuildMember())

    self.txt_input = self._layout_objs.txt_input
    self.txt_input:SetText("")

    self.btn_look = self._layout_objs.btn_look
    self.btn_look:AddClickCallBack(handler(self, self.Search))

    self.btn_apply = self._layout_objs.btn_apply
    self.btn_apply:SetEnable(not self.ctrl:IsGuildMember())
    self.btn_apply:AddClickCallBack(function()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_guild/guild_lobby_view/btn_apply"})
        if self.ctrl:CanJoinGuild() then
            self.ctrl:SendGuildJoinReq(0)
        end
    end)

    self.btn_declare = self._layout_objs.btn_declare
    self.btn_declare:AddClickCallBack(function()
        if self.click_item_info then
            self.ctrl:SendGuildDeclare(self.click_item_info.id)
        end
    end)

    self.btn_hostile = self._layout_objs.btn_hostile
    self.btn_hostile:AddClickCallBack(function()
        if self.click_item_info then
            self.ctrl:SendGuildHostile(self.click_item_info.id)
        end
    end)

    self.ctrl_page = self:GetRoot():GetController("ctrl_page")
    self:SetPageIndex(self.page_index)

    self.ctrl_guild = self:GetRoot():GetController("ctrl_guild")

    self.click_item_info = nil
end

function GuildLobbyView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2300])
end

function GuildLobbyView:InitGuildList()
    self.list_guild = self:CreateList("list_guild", "game/guild/item/guild_lobby_item")
    self.list_guild:SetRefreshItemFunc(function(item, idx)
        local item_info = self.show_data[idx]
        item:SetItemInfo(item_info, idx)
        item:AddClickEvent(handler(self, self.OnGuildItemClick))
    end)
end

function GuildLobbyView:UpdateGuildList(guild_list_data)
    self.guild_list_data = guild_list_data
    self.show_data = {}

    local fliter = function(guild)
        if self.page_index == PageIndex.Lobby or guild.id ~= game.GuildCtrl.instance:GetGuildId() then
            return true
        end
        return false
    end

    for k, v in pairs(guild_list_data) do
        if fliter(v) then
            table.insert(self.show_data, v)
        end
    end

    table.sort(self.show_data, function(m, n)
        return m.num < n.num
    end)

    local item_num = #self.show_data
    self.list_guild:SetItemNum(item_num)
    self.ctrl_guild:SetPageCount(item_num)
end

function GuildLobbyView:OnApproveResult(guild_id, approve)
    if approve == 1 then
        self.ctrl:OpenGuildNewView()
        self:Close()
    end
end

function GuildLobbyView:Search()
    local text = self.txt_input:GetText()

    self.show_data = {}

    if text == "" then
        for k, v in pairs(self.guild_list_data) do
            table.insert(self.show_data, v)
        end
    
        table.sort(self.show_data, function(m, n)
            return m.num < n.num
        end)
    else
        local match_list = {}
        for k, v in pairs(self.guild_list_data or {}) do
            local weight = math.max(self:GetMatchWeight(v.num, text), self:GetMatchWeight(v.name, text))
            if weight > 0 then
                table.insert(match_list, {weight = weight, data = v})
            end
        end
        table.sort(match_list, function(m, n)
            return m.weight < n.weight
        end)
        for k, v in ipairs(match_list) do
            table.insert(self.show_data, v.data)
        end
    end

    local item_num = #self.show_data
    self.list_guild:SetItemNum(item_num)
    self.ctrl_guild:SetPageCount(item_num)
end

function GuildLobbyView:GetMatchWeight(str, pattern)
    local start_idx, end_idx = string.find(str, pattern)
    if not start_idx then
        return 0
    else
        return start_idx + string.len(str)-start_idx
    end
end

function GuildLobbyView:OnGuildItemClick(brief_info, sort_idx)
    if self.page_index == PageIndex.Lobby then
        self.ctrl:OpenGuildInfoView(brief_info)
    end
    self.click_item_info = brief_info
    self.ctrl_guild:SetSelectedIndexEx(sort_idx-1)
end

function GuildLobbyView:SetPageIndex(index)
    index = index or self.page_index
    self.ctrl_page:SetSelectedIndexEx(index)
    if index == PageIndex.Hostile then
        self.btn_hostile:SetEnable(self.ctrl:GetGuildMemberPos()>=game.GuildPos.ViceChief)
    end
end

return GuildLobbyView
