local MakeTeamStateView = Class(game.BaseView)

local _et = {}
local handler = handler

function MakeTeamStateView:_init(ctrl)
    self._package_name = "ui_make_team"
    self._com_name = "make_team_state_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self.ctrl = ctrl
end

function MakeTeamStateView:OpenViewCallBack()
    self:Init()
    self:InitBg()

    self:RegisterAllEvents()
end

function MakeTeamStateView:CloseViewCallBack()

end

function MakeTeamStateView:RegisterAllEvents()
    local events = {
        {game.MakeTeamEvent.TeamMemberLeave, handler(self, self.UpdateList)},
        {game.MakeTeamEvent.UpdateTeamNewMember, handler(self, self.UpdateList)},
        {game.MakeTeamEvent.NotifyKickOut, handler(self, self.OnNotifyKickOut)},

        {game.CarbonEvent.UpdateDunTeamState, handler(self, self.OnUpdateDunTeamState)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamStateView:Init()
    self:InitMembers()
end

function MakeTeamStateView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5016])
end

function MakeTeamStateView:InitMembers()
    self.ui_list = self:CreateList("list_item", "game/make_team/make_team_state_item")
    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetItemData(idx)
        item:UpdateData(data, idx)
    end)

    self:UpdateList()
end

function MakeTeamStateView:GetItemData(idx)
    return self.item_data[idx]
end

local RobotInfos = {}
for i=1,4 do
    RobotInfos[i] = {
        online = 1,
        distance = 1,
        level = 1,
        alive = 1,
        times = 1,
        assist = 1,
        role_id = 1,
    }
end

function MakeTeamStateView:UpdateList()
    self.item_data = {}

    local data = game.CarbonCtrl.instance:GetDunTeamStateData()
    if data then
        for _,v in ipairs(data.status) do
            table.insert(self.item_data, v)
        end
    end

    local idx = 0
    local team_members = game.MakeTeamCtrl.instance:GetTeamMembers()
    for _,v in ipairs(team_members) do
        if v.member.is_robot then
            idx = idx + 1
            local info = RobotInfos[idx]
            info.name = v.member.name
            table.insert(self.item_data, info)
        end
    end

    local item_num = #self.item_data
    self.ui_list:SetItemNum(item_num)
end

function MakeTeamStateView:OnNotifyKickOut()
    self:Close()
end

function MakeTeamStateView:OnUpdateDunTeamState()
    self:UpdateList()
end

function MakeTeamStateView:OnEmptyClick()
    self:Close()
end

return MakeTeamStateView