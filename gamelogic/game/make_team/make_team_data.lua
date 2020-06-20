local MakeTeamData = Class(game.BaseData)

local _et = {}
local MaxMemberNum = 5
local config_team_robot = config.team_robot
local config_team_target = config.team_target

function MakeTeamData:_init(ctrl)
    self.ctrl = ctrl

    self:ResetData()
end

function MakeTeamData:ResetData()
    self.team_data = {
        id = 0,
        math = 0,
        target = 0,
        follow = 0,
        leader = 0,
        members = {},
    }

    if not self.team_member_flag_list then
        self.team_member_flag_list = {}
    end

    for k,v in pairs(self.team_member_flag_list) do
        self.team_member_flag_list[k] = 0
    end

    self.apply_list = {}

    self.team_member_attr = {}

    self.team_mem_pos = {}
end

function MakeTeamData:OnTeamGetInfo(data)
    --[[
        "team__U|CltTeam|",

        CltTeam
        "id__L",
        "match__C",
        "target__H",
        "follow__C",
        "leader__L",
        "members__T__member@U|CltTeamMember|",
        "robots__T__robot_cids@C",
        "match_beg__I",
    ]]
    self.team_data = data.team

    self:AddRobotMember(self.team_data.robots)

    self:DoSortMember()

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamGetNearby(data)
    --[[
        "teams__T__team@U|CltTeamBrief|",
    ]]
    
end

function MakeTeamData:OnTeamTargetList(data)
    --[[
        "target__H",
        "teams__T__team@U|CltTeamBrief|",
    ]]
    
end

function MakeTeamData:OnTeamCreate(data)
    --[[
        "team__U|CltTeam|",
    ]]
    self.team_data = data.team

    self:DoSortMember()

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamApplyList(data)
    --[[
        "roles__T__id@L##name@s##level@C##career@C",
    ]]
    
    self.apply_list = data.roles
end

function MakeTeamData:OnTeamMatch(data)
    --[[
        target
    ]]
    
    if data.target <= 0 then
        self.team_data.match = 0
    else
        self.team_data.match = 1
    end
end

function MakeTeamData:OnTeamApplyFor(data)
    --[[
        "team_id__L",
    ]]
    
end

function MakeTeamData:OnTeamAcceptApply(data)
    --[[
        "role_id__L",
        "accept__C",
    ]]
    
    if data.accept == 0 then
        -- 清空
        self.apply_list = {}
    else
        for k,v in ipairs(self.apply_list) do
            if v.id == data.role_id then
                table.remove(self.apply_list, k)
                break
            end
        end
    end

    self:FireEvent(game.MakeTeamEvent.UpdateAcceptApply, data)
end

function MakeTeamData:OnTeamNotifyApply(data)
    --[[
        "role_id__L",
        "role_name__s",
        "level__H",
        "career__C",
    ]]

    for _,v in ipairs(self.apply_list) do
        if v.id == data.id then
            return
        end
    end
    
    table.insert(self.apply_list, {
            id = data.role_id,
            name = data.role_name,
            level = data.level,
            career = data.career,
        })
end

function MakeTeamData:OnTeamApplyReject(data)
    --[[
        "team_id__L",
    ]]
    
end

function MakeTeamData:OnTeamNewMember(data)
    --[[
        "member__U|CltTeamMember|",
    ]]
    table.insert(self.team_data.members, data)

    self:DoSortMember()

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamJoinNew(data)
    --[[
        "team__U|CltTeam|",
    ]]
    
    self.team_data = data.team

    self:AddRobotMember(self.team_data.robots)

    self:DoSortMember()

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:DoSortMember()
    table.sort(self.team_data.members, function(v1,v2)
        local sort_1 = v1.member.id
        if self:IsLeader(sort_1) then
            sort_1 = 0
        end

        local sort_2 = v2.member.id
        if self:IsLeader(sort_2) then
            sort_2 = 0
        end

        return sort_1<sort_2
    end)
end

function MakeTeamData:OnTeamInviteJoin(data)
    --[[
        "target__L",
    ]]
    
end

function MakeTeamData:OnTeamAcceptInvite(data)
    --[[
        "team_id__L",
        "role_id__L",
        "accept__C",
    ]]
    
end

function MakeTeamData:OnTeamNewInvite(data)
    --[[
        "team_id__L",
        "role_id__L",
        "name__s",
    ]]
    
end

function MakeTeamData:OnTeamInviteReject(data)
    --[[
        "role_id__L",
    ]]
    
end

function MakeTeamData:OnTeamLeave(data)
    self:ResetData()

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamKickOut(data)
    --[[
        "target__L",
    ]]
    for k,v in ipairs(self.team_data.members) do
        if v.member.id == data.target then
            table.remove(self.team_data.members, k)
            break
        end
    end

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamMemberLeave(data)
    --[[
        "role_id__L",
    ]]    
    for k,v in ipairs(self.team_data.members) do
        if v.member.id == data.role_id then
            table.remove(self.team_data.members, k)
            break
        end
    end

    self.team_member_attr[data.role_id] = nil

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamNotifyKickOut(data)
    --[[
        
    ]]
    self:ResetData()

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamRecruit(data)
    --[[
        
    ]]
    
end

--团队更改目标副本后清除所有机器人
function MakeTeamData:OnTeamSetTarget(data)
    --[[
        "target__H",
    ]]
    
    self.team_data.target = data.target
    self.team_data.min_lv = data.min
    self.team_data.max_lv = data.max

    local cfg = config_team_target[data.target]
    self:ClearAllRobots()

    --if cfg then
    --    if cfg.robot ~= 1 then
    --        self:ClearAllRobots()
    --    end
    --end
end

function MakeTeamData:OnTeamSetLevel(data)
    self.team_data.min_lv = data.min
    self.team_data.max_lv = data.max
end

function MakeTeamData:OnTeamSyncPos(data)
    local pos = self.team_mem_pos[data.role_id]
    if pos then
        pos.x = data.x
        pos.y = data.y
    else
        self.team_mem_pos[data.role_id] = data
    end
end

function MakeTeamData:OnTeamSetMatch(data)
    --[[
        "match__C",
        "match_beg__I",
    ]]
    
    self.team_data.match = data.match
    self.team_data.match_beg = data.match_beg
end

function MakeTeamData:OnTeamDemiseLeader(data)
    --[[
        "target__L",
    ]]
    self.team_data.leader = data.target

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamPromoteRequest(data)
    --[[
        
    ]]
    
end

function MakeTeamData:OnTeamAcceptPromote(data)
    --[[
        "role_id__L",
        "opt__C",
    ]]
    if data.opt == 1 then
        self.team_data.leader = data.role_id
    end

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamNotifyLeaderDemise(data)
    --[[
        "leader__L",
    ]]
    local role_id = game.Scene.instance:GetMainRoleID()
    if self:IsLeader(role_id) then
        local data = {
            accept = 0,
            role_id = 0,
        }
        self:OnTeamAcceptApply(data)
    end

    self.team_data.leader = data.leader

    self:UpdateTeamMemberFlag()

    return self:IsLeader(role_id)
end

function MakeTeamData:OnTeamNotifyPromoteRequest(data)
    --[[
        "role_id__L",
        "name__s",
    ]]
    
end

function MakeTeamData:OnTeamNotifyAcceptPromote(data)
    --[[
        "role_id__L",
        "name__s",
        "opt__C",
    ]]
    if data.opt == 1 then
        self.team_data.leader = data.leader
    end

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:OnTeamFollow(data)
    --[[
        "opt__C",
    ]]
   
    self.team_data.follow = data.opt 
end

function MakeTeamData:OnTeamSyncState(data)
    --[[
        "state__C",
    ]]

end

function MakeTeamData:OnTeamNotifyFollow(data)
    --[[
        "opt__C",
    ]]
    self.team_data.follow = data.opt

    if data.opt == 0 then
        local members = self:GetTeamMembers()
        for _,v in ipairs(members) do
            v.member.state = game.TeamFollowState.NoFollow
        end

        self:UpdateTeamMemberFlag()
    end
end

function MakeTeamData:OnTeamNotifySyncState(data)
    --[[
        "role_id__L",
        "state__C",
    ]]

    local members = self:GetTeamMembers()
    for _,v in ipairs(members) do
        if v.member.id == data.role_id then
            v.member.state = data.state
            break
        end
    end

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:GetTeamMemSyncState(role_id)
    local members = self:GetTeamMembers()
    for _,v in ipairs(members) do
        if v.member.id == role_id then
            return v.member.state
        end
    end
    return 0
end

function MakeTeamData:OnTeamMemPos(data)
    --[[
        "role_id__L",
        "scene_id__I",
        "x__H",
        "y__H",
    ]]
    self.team_mem_pos[data.role_id] = data
end

function MakeTeamData:OnTeamTransferTo(data)
    --[[
        "type__C",
        "code__I",
    ]]
    
end

local AttrTypes = game.TeamMemAttrTypes
local AttrKeys = {
    [AttrTypes.Hp] = "hp",
    [AttrTypes.MaxHp] = "hp_lim",
    [AttrTypes.Lv] = "level",
    [AttrTypes.Career] = "career",
    [AttrTypes.Offline] = "offline",
    [AttrTypes.Scene] = "scene",
    [AttrTypes.Line] = "line",
}
function MakeTeamData:OnTeamMemberAttr(data)
    --[[
        "role_id__L",
        "list__T__type@C##value@I",
    ]]
    
    local info = self.team_member_attr[data.role_id]
    if not info then
        info = {}
        self.team_member_attr[data.role_id] = info
    end

    local member = self:GetTeamMemberById(data.role_id)
    for _,v in ipairs(data.list) do
        info[v.type] = v.value

        if v.type == AttrTypes.Scene then
            local pos = self.team_mem_pos[data.role_id]
            if pos then
                pos.scene = v.value
            end
        end

        if v.type == AttrTypes.Line then
            local pos = self.team_mem_pos[data.role_id]
            if pos then
                pos.line = v.value
            end
        end

        if member then
            local key = AttrKeys[v.type]
            member[key] = v.value
        end
    end
end

function MakeTeamData:GetMemberAttr(role_id, attr_type)
    local info = self.team_member_attr[role_id] or game.EmptyTable
    return info[attr_type] or 0
end

function MakeTeamData:GetMemberAttrList(role_id)
    return self.team_member_attr[role_id]
end

function MakeTeamData:TeamChange(data)
    --[[
        "role_id__L",
        "team_id__L",
    ]]
    
end

function MakeTeamData:HasTeam()
    local team_id = self.team_data.id or 0
    return (team_id>0)
end

function MakeTeamData:GetTeamMemberNums()
    return #(self.team_data.members or game.EmptyTable)
end

function MakeTeamData:GetTeamMembers()
    return self.team_data.members or game.EmptyTable
end

function MakeTeamData:GetTeamMemberById(role_id)
    for _,v in ipairs(self.team_data.members) do
        if v.member.id == role_id then
            return v.member
        end
    end
end

function MakeTeamData:GetTeamMemberLine(role_id)
    local info = self:GetTeamMemberById(role_id)
    if info then
        return info.line
    end
    return 0
end

function MakeTeamData:IsLeader(role_id)
    return (role_id>0 and self.team_data.leader==role_id)
end

function MakeTeamData:GetTeamId()
    return self.team_data.id
end

function MakeTeamData:GetTeamData()
    return self.team_data
end

function MakeTeamData:GetTeamTarget()
    return self.team_data.target
end

function MakeTeamData:GetTeamTargetLv()
    return self.team_data.min_lv,self.team_data.max_lv
end

function MakeTeamData:IsTeamMember(role_id)
    for _,v in ipairs(self.team_data.members) do
        if v.member.id == role_id then
            return true
        end
    end
    return false
end

function MakeTeamData:CheckApplyRedPoint()
    return (#self.apply_list>0)
end

function MakeTeamData:IsTeamMatching()
    return (self.team_data.match==1)
end

function MakeTeamData:GetMatchBeginTime()
    return self.team_data.match_beg
end

function MakeTeamData:GetTeamFollowState()
    -- 0-非跟随 1-跟随
    return self.team_data.follow
end

function MakeTeamData:GetLeaderId()
    return self.team_data.leader
end

function MakeTeamData:IsTeamFollow()
    return (self.team_data.follow==1)
end

function MakeTeamData:GetMemberFollowState(role_id)
    local members = self:GetTeamMembers()
    for _,v in ipairs(members) do
        if v.member.id == role_id then
            return v.member.state
        end
    end
    return game.TeamFollowState.None
end

function MakeTeamData:SetMemberFollowState(role_id, state)
    local members = self:GetTeamMembers()
    for _,v in ipairs(members) do
        if v.member.id == role_id then
            v.member.state = state
            break
        end
    end

    self:UpdateTeamMemberFlag()
end

function MakeTeamData:IsFullMember()
    return (self:GetTeamMemberNums()>=MaxMemberNum)
end

function MakeTeamData:GetApplyList()
    return self.apply_list
end

function MakeTeamData:GetTeamMemPos(role_id)
    return self.team_mem_pos[role_id]
end

function MakeTeamData:SetLeaderPos(x, y)
    local leader_id = self:GetLeaderId()
    local leader_pos = self.team_mem_pos[leader_id]
    if leader_pos then
        leader_pos.x = x
        leader_pos.y = y
    end
end

function MakeTeamData:SetTeamMemPos(role_id, key, val)
    local info = self.team_mem_pos[role_id]
    if info then
        info[AttrKeys[key]] = val
    end
end

function MakeTeamData:GetTeamMemIndex(role_id)
    local idx = 1
    local leader_id = self:GetLeaderId()
    local members = self:GetTeamMembers()
    for k,v in ipairs(members) do
        local id = v.member.id
        if id ~= leader_id then
            if id == role_id then
                break
            end
            idx = idx + 1
        end
    end
    return idx
end

function MakeTeamData:GetTeamMemFollowIndex(role_id)
    local idx = 1
    local leader_id = self:GetLeaderId()
    local members = self:GetTeamMembers()
    for k,v in ipairs(members) do
        local id = v.member.id
        if id ~= leader_id and v.member.state==game.TeamFollowState.Follow then
            if id == role_id then
                break
            end
            idx = idx + 1
        end
    end
    return idx
end

function MakeTeamData:IsMemberFollow(role_id)
    local state = self:GetMemberFollowState(role_id)
    return (state>game.TeamFollowState.NoFollow)
end

function MakeTeamData:IsMemberOffline(role_id)
    local member = self:GetTeamMemberById(role_id)
    return member.offline>0
end

function MakeTeamData:OnTeamAssist(data)
    local member_info = self:GetTeamMemberById(data.role_id)
    if member_info then
        member_info.assist = data.assist
    end
end

function MakeTeamData:OnKickRobot(data)
    --[[
        "robot_cid__C",
    ]]

    data.target = data.robot_cid

    -- 删除对应机器人
    for k,v in ipairs(self.team_data.robots) do
        if v.robot_cids == data.robot_cid then
            table.remove(self.team_data.robots, k)
            break
        end
    end

    self:OnTeamKickOut(data)
end

function MakeTeamData:OnAddRobot(data)
    for _,v in ipairs(data.ids) do
        local is_update = false
        for _,cv in ipairs(self.team_data.robots) do
            if v.robot_cid == cv.robot_cids then
                is_update = true

                break
            end
        end

        if not is_update then
            table.insert(self.team_data.robots, v)
        end
    end

    self:AddRobotMember(data.ids)
end

function MakeTeamData:AddRobotMember(robots)
    for _,v in ipairs(robots or _et) do
        local cid = v.robot_cid or v.robot_cids
        local cfg = config_team_robot[cid]
        if cfg then
            cfg.hp = 100
            cfg.hp_lim = 100
            cfg.offline = 0
            cfg.is_robot = true

            local data = {
                member = cfg
            }
            self:OnTeamNewMember(data)

            self:FireEvent(game.MakeTeamEvent.UpdateTeamNewMember, data)
        end
    end
end

--清除所有机器人
function MakeTeamData:ClearAllRobots()
    local has_robot = false
    for _,v in ipairs(self.team_data.members) do
        if v.member.is_robot then
            has_robot = true
            break
        end
    end

    if has_robot then
        local new_members = {}
        for _,v in ipairs(self.team_data.members) do
            if not v.member.is_robot then
                table.insert(new_members, v)
            end
        end
        self.team_data.members = new_members

        self:FireEvent(game.MakeTeamEvent.TeamMemberLeave)
    end
end

function MakeTeamData:UpdateTeamMemberFlag()
    for k,v in pairs(self.team_member_flag_list) do
        self.team_member_flag_list[k] = 0
    end

    for _,v in ipairs(self:GetTeamMembers()) do
        local info = v.member
        local flag = 2
        if self:IsLeader(info.id) then
            flag = 1
        else
            if info.state == game.TeamFollowState.Follow then
                flag = 3
            end
        end
        self.team_member_flag_list[info.id] = flag
    end

    self.ctrl:OnUpdateTeamMemberFlag()

    self:ClearTeamMemberFlag()
end

function MakeTeamData:ClearTeamMemberFlag()
    for k,v in pairs(self.team_member_flag_list) do
        if v == 0 then
            self.team_member_flag_list[k] = nil
        end
    end
end

function MakeTeamData:GetTeamMemberFlagList()
    return self.team_member_flag_list
end

function MakeTeamData:GetTeamMemberFlag(role_id)
    return self.team_member_flag_list[role_id]
end

return MakeTeamData
