local MakeTeamInviteView = Class(game.BaseView)

local handler = handler
local string_gsub = string.gsub
local string_format = string.format

function MakeTeamInviteView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_invite_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function MakeTeamInviteView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitListItem()

    self:RegisterAllEvents()
end

function MakeTeamInviteView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end

    self.ctrl:OpenView()
end

function MakeTeamInviteView:RegisterAllEvents()
    local events = {
        {game.MakeTeamEvent.UpdateTeamNewMember, handler(self, self.OnUpdateTeamNewMember)},
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamInviteView:Init()
    self.txt_target = self._layout_objs["txt_target"]

    self:InitListItem()
    self:InitBtns()
end

function MakeTeamInviteView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1671]):HideBtnBack()
end

function MakeTeamInviteView:InitBtns()
    self.btn_friend = self._layout_objs["btn_friend"]
    self.btn_friend:AddClickCallBack(function()
        self:ShowFriend()
    end)

    self.btn_guild = self._layout_objs["btn_guild"]
    self.btn_guild:AddClickCallBack(function()
        self:ShowGuild()
    end)

    self.btn_near = self._layout_objs["btn_near"]
    self.btn_near:AddClickCallBack(function()
        self:ShowNear()
    end)
    
    self:ShowFriend()
end

function MakeTeamInviteView:InitListItem()
    self.list_item = self._layout_objs["list_item"]

    self.ui_list = game.UIList.New(self.list_item)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/make_team/make_team_invite_item").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetItemData(idx)
        item:UpdateData(data)
    end)
end

function MakeTeamInviteView:ShowFriend()
    self:ClearList()

    local friend_ctrl = game.FriendCtrl.instance
    local friend_list = friend_ctrl:GetData():GetFriendList()

    self.item_data = {}
    for _,v in ipairs(friend_list) do
        local role_info = friend_ctrl:GetData():GetRoleInfoById(v.roleId)
        if role_info and role_info.unit.offline==0 and (not self.ctrl:IsTeamMember(role_info.unit.id)) then
            table.insert(self.item_data, role_info.unit)
        end
    end

    self.ui_list:SetItemNum(#self.item_data)
    --self.ui_list:RefreshVirtualList()
end

function MakeTeamInviteView:ShowGuild()
    self:ClearList()

    local guild_members = game.GuildCtrl.instance:GetGuildMembers()
    local online_members = {}
    for k, v in pairs(guild_members or {}) do
        if v.mem.offline == 0 and not self.ctrl:IsTeamMember(v.mem.id) then
            table.insert(online_members, v.mem)
        end
    end

    self.item_data = online_members

    self.ui_list:SetItemNum(#online_members)
    self.ui_list:RefreshVirtualList()
end

function MakeTeamInviteView:ShowNear()
    self:ClearList()

    local scene = game.Scene.instance
    local obj_list = scene:GetObjByType(game.ObjType.Role, function(obj)
        if self.ctrl:IsTeamMember(obj:GetUniqueId()) then
            return false
        end

        return (not scene:IsSelfEnemy(obj))
    end)

    self.item_data = {}
    for _,v in ipairs(obj_list) do
        table.insert(self.item_data, {
            id = v:GetUniqueId(),
            name = v:GetName(),
            career = v:GetCareer(),
            level = v:GetLevel(),
        })
    end

    self.ui_list:SetItemNum(#obj_list)
    self.ui_list:RefreshVirtualList()
end

function MakeTeamInviteView:GetItemData(idx)
    return self.item_data[idx]
end

function MakeTeamInviteView:ClearList()
    self.ui_list:ClearList()
end

function MakeTeamInviteView:OnUpdateTeamNewMember(data)
    local item_data = self.item_data or game.EmptyTable
    for k,v in ipairs(item_data ) do
        if v.id == data.member.id then
            table.remove(self.item_data, k)
            break
        end
    end

    self:ClearList()
    
    self.ui_list:SetItemNum(#item_data)
    self.ui_list:RefreshVirtualList()
end

return MakeTeamInviteView

