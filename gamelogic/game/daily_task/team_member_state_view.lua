local TeamMemberStateView = Class(game.BaseView)

local _et = {}

function TeamMemberStateView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_state_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function TeamMemberStateView:OpenViewCallBack(dist)
    self.dist = dist or 1
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function TeamMemberStateView:CloseViewCallBack()

end

function TeamMemberStateView:RegisterAllEvents()
    local events = {

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function TeamMemberStateView:Init()
    self:InitMembers()
end

function TeamMemberStateView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5016])
end

function TeamMemberStateView:InitMembers()
    self.ui_list = self:CreateList("list_item", "game/make_team/make_team_state_item")
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetItemData(idx)
        item:UpdateData(data, idx)
    end)

    self:UpdateList()
end

function TeamMemberStateView:GetItemData(idx)
    return self.item_data[idx]
end

function TeamMemberStateView:UpdateList()
    self.item_data = {}

    local team_members = game.MakeTeamCtrl.instance:GetTeamMembers()
    for _,v in ipairs(team_members) do
        local mem_info = v.member
        if not mem_info.is_robot then
            local info = {
                level = 1,
                alive = 1,
                times = 1,
                assist = 0,
                role_id = 1,
                name = mem_info.name,
            }
            info.distance = self:CheckDistance(mem_info) and 1 or 0
            info.online = (mem_info.offline == 0) and 1 or 0

            table.insert(self.item_data, info)
        end
    end

    local item_num = #self.item_data
    self.ui_list:SetItemNum(item_num)
end

function TeamMemberStateView:CheckDistance(mem_info)
    local main_role = game.Scene.instance:GetMainRole()
    local self_info = game.RoleCtrl.instance:GetRoleInfo()
    if self_info.role_id == mem_info.id then
        return true
    end
    local role = game.Scene.instance:GetObjByUniqID(mem_info.id)
    if role and role.obj_type == game.ObjType.Role then
        local logic_pos = role:GetLogicPos()
        local self_pos = main_role:GetLogicPos()
        if cc.pDistanceSQ(logic_pos, self_pos) <= self.dist*self.dist then
            return true
        end
    end
    return false
end

return TeamMemberStateView