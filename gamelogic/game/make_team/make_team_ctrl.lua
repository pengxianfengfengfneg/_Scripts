local MakeTeamCtrl = Class(game.BaseCtrl)

local handler = handler
local global_time = global.Time

local config_team_robot = config.team_robot

local TeamTargetConfig = require("game/make_team/team_target_config")

function MakeTeamCtrl:_init()
    if MakeTeamCtrl.instance ~= nil then
        error("MakeTeamCtrl Init Twice!")
    end
    MakeTeamCtrl.instance = self

    self.data = require("game/make_team/make_team_data").New(self)
    self.team_view = require("game/make_team/make_team_view").New(self)
    self.platform_view = require("game/make_team/make_team_platform_view").New(self)
    self.apply_view = require("game/make_team/make_team_apply_view").New(self)
    self.invite_view = require("game/make_team/make_team_invite_view").New(self)
    self.target_view = require("game/make_team/make_team_target_view").New(self)
    self.side_info_view = require("game/make_team/make_team_side_info_view").New(self)
    self.team_state_view = require("game/make_team/make_team_state_view").New(self)

    self.follow_action = require("game/make_team/make_team_follow_action").New(self)

    self.is_login_succ = false
    self.next_update_pos_time = 0
    self.next_update_pos_delta_time = 3

    self.command_list = {}

    self:RegisterAllEvents() 
    self:RegisterAllProtocals()

    global.Runner:AddUpdateObj(self, 2)
end

function MakeTeamCtrl:_delete()
    global.Runner:RemoveUpdateObj(self)

    self.data:DeleteMe()

    self.team_view:DeleteMe()
    self.platform_view:DeleteMe()
    self.apply_view:DeleteMe()
    self.invite_view:DeleteMe()
    self.target_view:DeleteMe()
    self.side_info_view:DeleteMe()
    self.team_state_view:DeleteMe()

    self.follow_action:DeleteMe()

    self:CloseInviteTipsView()

    if self.notify_follow_view then
        self.notify_follow_view:DeleteMe()
        self.notify_follow_view = nil
    end
    
    MakeTeamCtrl.instance = nil
end

function MakeTeamCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.OnLoginSuccess)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MakeTeamCtrl:RegisterAllProtocals()
    self:RegisterProtocalCallback(42002, "OnTeamGetInfo")
    self:RegisterProtocalCallback(42004, "OnTeamGetNearby")
    self:RegisterProtocalCallback(42006, "OnTeamTargetList")
    self:RegisterProtocalCallback(42008, "OnTeamCreate")
    self:RegisterProtocalCallback(42010, "OnTeamApplyList")
    self:RegisterProtocalCallback(42012, "OnTeamMatch")
    self:RegisterProtocalCallback(42014, "OnTeamApplyFor")
    self:RegisterProtocalCallback(42016, "OnTeamAcceptApply")
    self:RegisterProtocalCallback(42017, "OnTeamNotifyApply")
    self:RegisterProtocalCallback(42018, "OnTeamApplyReject")    
    self:RegisterProtocalCallback(42019, "OnTeamNewMember")    
    self:RegisterProtocalCallback(42020, "OnTeamJoinNew")    
    self:RegisterProtocalCallback(42022, "OnTeamInviteJoin")    
    self:RegisterProtocalCallback(42024, "OnTeamAcceptInvite")
    self:RegisterProtocalCallback(42025, "OnTeamNewInvite")
    self:RegisterProtocalCallback(42026, "OnTeamInviteReject")
    self:RegisterProtocalCallback(42028, "OnTeamLeave")
    self:RegisterProtocalCallback(42030, "OnTeamKickOut")
    self:RegisterProtocalCallback(42031, "OnTeamMemberLeave")
    self:RegisterProtocalCallback(42032, "OnTeamNotifyKickOut")
    self:RegisterProtocalCallback(42034, "OnTeamRecruit")
    self:RegisterProtocalCallback(42036, "OnTeamSetTarget")
    self:RegisterProtocalCallback(42038, "OnTeamSetMatch")
    self:RegisterProtocalCallback(42040, "OnTeamDemiseLeader")
    self:RegisterProtocalCallback(42042, "OnTeamPromoteRequest")
    self:RegisterProtocalCallback(42044, "OnTeamAcceptPromote")
    self:RegisterProtocalCallback(42045, "OnTeamNotifyLeaderDemise")
    self:RegisterProtocalCallback(42046, "OnTeamNotifyPromoteRequest")
    self:RegisterProtocalCallback(42047, "OnTeamNotifyAcceptPromote")
    self:RegisterProtocalCallback(42050, "OnTeamFollow")
    self:RegisterProtocalCallback(42052, "OnTeamSyncState")
    self:RegisterProtocalCallback(42053, "OnTeamNotifyFollow")
    self:RegisterProtocalCallback(42054, "OnTeamNotifySyncState")
    self:RegisterProtocalCallback(42056, "OnTeamMemPos")
    self:RegisterProtocalCallback(42058, "OnTeamAssist")
    self:RegisterProtocalCallback(42059, "OnTeamMemberAttr")

    self:RegisterProtocalCallback(42062, "OnTeamCommand")
    self:RegisterProtocalCallback(42064, "OnTeamSetLevel")
    self:RegisterProtocalCallback(42065, "OnTeamSyncPos")
    

    self:RegisterProtocalCallback(42072, "OnKickRobot")
    self:RegisterProtocalCallback(42074, "OnAddRobot")

end

function MakeTeamCtrl:OnLoginSuccess()
    self.is_login_succ = true
end

function MakeTeamCtrl:OpenView(target)
    if self:HasTeam() then
        self:OpenTeamView()
        return
    end
    self:OpenPlatformView(target)
end

function MakeTeamCtrl:CloseView()
    self.team_view:Close()
    self.platform_view:Close()
end

function MakeTeamCtrl:OpenTeamView(target)
    self.team_view:Open(target)
end

function MakeTeamCtrl:OpenPlatformView(target, auto_match)
    self.platform_view:Open(target, auto_match)
end

function MakeTeamCtrl:OpenApplyView()
    self.apply_view:Open()
end

function MakeTeamCtrl:OpenInviteView()
    self.invite_view:Open()
end

function MakeTeamCtrl:OpenTargetView()
    self.target_view:Open()
end

function MakeTeamCtrl:OpenSideInfoView()
    self.side_info_view:Open()
end

function MakeTeamCtrl:OpenInviteTipsView(data)
    if not self.invite_tips_view then
        local title = config.words[4981]
        local content = string.format(config.words[4982], data.name)
        self.invite_tips_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content, 10)
        self.invite_tips_view:SetOkBtn(function()
            self:SendTeamAcceptInvite(data.team_id, data.role_id, 1)

            self:CloseInviteTipsView()
        end, config.words[5010])
        self.invite_tips_view:SetCancelBtn(function()
            self:SendTeamAcceptInvite(data.team_id, data.role_id, 2)

            self:CloseInviteTipsView()
        end, config.words[5011], true)
        self.invite_tips_view:Open()
    end
end

function MakeTeamCtrl:CloseInviteTipsView()
    if self.invite_tips_view then
        self.invite_tips_view:DeleteMe()
        self.invite_tips_view = nil
    end
end

function MakeTeamCtrl:OpenTeamStateView()
    self.team_state_view:Open()
end


function MakeTeamCtrl:HasTeam()
    return self.data:HasTeam()
end

function MakeTeamCtrl:GetTeamMemberNums()
    return self.data:GetTeamMemberNums()
end

function MakeTeamCtrl:GetTeamMembers()
    return self.data:GetTeamMembers()
end

function MakeTeamCtrl:IsLeader(role_id)
    return self.data:IsLeader(role_id)
end

function MakeTeamCtrl:GetTeamId()
    return self.data:GetTeamId()
end

function MakeTeamCtrl:GetTeamData()
    return self.data:GetTeamData()
end

function MakeTeamCtrl:GetTeamTarget()
    return self.data:GetTeamTarget()
end

function MakeTeamCtrl:GetTeamTargetLv()
    return self.data:GetTeamTargetLv()
end

function MakeTeamCtrl:IsTeamMember(role_id)
    return self.data:IsTeamMember(role_id)
end

function MakeTeamCtrl:CheckApplyRedPoint()
    return self.data:CheckApplyRedPoint()
end

function MakeTeamCtrl:IsTeamMatching()
    return self.data:IsTeamMatching()
end

function MakeTeamCtrl:GetMatchBeginTime()
    return self.data:GetMatchBeginTime()
end

function MakeTeamCtrl:GetTeamFollowState()
    return self.data:GetTeamFollowState()
end

function MakeTeamCtrl:SendGetLeaderPos(is_force)
    if self:HasTeam() then
        local leader_id = self:GetLeaderId()
        self:SendTeamMemPos(leader_id)
    end
end

function MakeTeamCtrl:GetLeaderId()
    return self.data:GetLeaderId()
end

function MakeTeamCtrl:IsSelfLeader()
    local role_id = game.Scene.instance:GetMainRoleID()
    return self.data:IsLeader(role_id)
end



function MakeTeamCtrl:SendTeamGetInfo()
    local proto = {

    }
    self:SendProtocal(42001, proto)
end

function MakeTeamCtrl:OnTeamGetInfo(data)
    --[[
        "team__U|CltTeam|",
    ]]
    --[[
        proto.CltTeam = {
            "id__L",
            "match__C",
            "target__H",
            "follow__C",
            "leader__L",
            "members__T__member@U|CltTeamMember|",
            "robots__T__robot_cids@C",
            "match_beg__I",
    }
    ]]
    --PrintTable(data)
    self.data:OnTeamGetInfo(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamGetInfo)

    if self:HasTeam() and self:IsSelfLeader() then
        if not self.is_require_apply_list then
            self.is_require_apply_list = true
            self:SendTeamApplyList()
        end
    end
end

function MakeTeamCtrl:SendTeamGetNearby()
    local proto = {

    }
    self:SendProtocal(42003, proto)
end

function MakeTeamCtrl:OnTeamGetNearby(data)
    --[[
        "teams__T__team@U|CltTeamBrief|",
    ]]
    --PrintTable(data)

    self.data:OnTeamGetNearby(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamGetNearby, data)
end

function MakeTeamCtrl:SendTeamTargetList(target)
    local proto = {
        target = target
    }
    self:SendProtocal(42005, proto)
end

function MakeTeamCtrl:OnTeamTargetList(data)
    --[[
        "target__H",
        "teams__T__team@U|CltTeamBrief|",
    ]]
    --PrintTable(data)

    self:FireEvent(game.MakeTeamEvent.UpdateTargetList, data)
end

function MakeTeamCtrl:SendTeamCreate(target)
    local proto = {
        target = target
    }
    self:SendProtocal(42007, proto)
end

function MakeTeamCtrl:OnTeamCreate(data)
    --[[
        "team__U|CltTeam|",
    ]]
    --PrintTable(data)

    self.data:OnTeamCreate(data)

    if self.to_invite_role_id then
        local role_id = self.to_invite_role_id
        self.to_invite_role_id = nil
        self:DoTeamInviteJoin(role_id)
    else
        local team_target = self:GetTeamTarget()
        if config.team_target[team_target] then
            self:SendTeamSetMatch(1)
        end
        self:OpenView()
    end

    self:FireEvent(game.MakeTeamEvent.UpdateTeamCreate)
end

function MakeTeamCtrl:SendTeamApplyList()
    local proto = {
        
    }
    self:SendProtocal(42009, proto)
end

function MakeTeamCtrl:OnTeamApplyList(data)
    --[[
        "roles__T__id@L##name@s##level@C##career@C",
    ]]
    --PrintTable(data)

    self.data:OnTeamApplyList(data)

    self:FireEvent(game.MakeTeamEvent.UpdateApplyList, data.roles)
end

function MakeTeamCtrl:SendTeamMatch(target)
    local proto = {
        target = target
    }
    self:SendProtocal(42011, proto)

    --PrintTable(proto)
end

function MakeTeamCtrl:OnTeamMatch(data)
    --[[
        target
    ]]
    --PrintTable(data)

    self.data:OnTeamMatch(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamMatch, data.target)
end

function MakeTeamCtrl:SendTeamApplyFor(team_id)
    local proto = {
        team_id = team_id
    }
    self:SendProtocal(42013, proto)
end

function MakeTeamCtrl:OnTeamApplyFor(data)
    --[[
        "team_id__L",
    ]]
    --PrintTable(data)

    game.GameMsgCtrl.instance:PushMsg(config.words[5006])
end

function MakeTeamCtrl:SendTeamAcceptApply(role_id, accept)
    local proto = {
        role_id = role_id,
        accept = accept
    }
    self:SendProtocal(42015, proto)
end

function MakeTeamCtrl:OnTeamAcceptApply(data)
    --[[
        "role_id__L",
        "accept__C",
    ]]
    --PrintTable(data)

    self.data:OnTeamAcceptApply(data)
end

function MakeTeamCtrl:OnTeamNotifyApply(data)
    --[[
        "role_id__L",
        "role_name__s",
    ]]
    --PrintTable(data)

    self.data:OnTeamNotifyApply(data)

    self:FireEvent(game.MakeTeamEvent.TeamNotifyApply, data.role_id)
end

function MakeTeamCtrl:OnTeamApplyReject(data)
    --[[
        "team_id__L",
    ]]
    --PrintTable(data)

    -- 提醒申请被拒绝

end

function MakeTeamCtrl:OnTeamNewMember(data)
    --[[
        "member__U|CltTeamMember|",
    ]]
    --PrintTable(data)

    self.data:OnTeamNewMember(data)

    self:FireEvent(game.MakeTeamEvent.UpdateTeamNewMember, data)

    if self:IsFullMember() then
        -- 满队员
        if self:IsSelfLeader() then
            self:SendTeamSetMatch(0)
            self:ShowFullMemberTips()
        end
    end
end

function MakeTeamCtrl:OnTeamJoinNew(data)
    --[[
        "team__U|CltTeam|",
    ]]
    --PrintTable(data)

    self.data:OnTeamJoinNew(data)

    self.invite_view:Close()

    if self.platform_view:IsOpen() then
        self:OpenView()
    end

    self:FireEvent(game.MakeTeamEvent.UpdateJoinTeam)
end

function MakeTeamCtrl:SendTeamInviteJoin(target)
    local proto = {
        target = target,
    }
    self:SendProtocal(42021, proto)
end

function MakeTeamCtrl:OnTeamInviteJoin(data)
    --[[
        "target__L",
    ]]
    --PrintTable(data)

    -- 提示等待接受

    self:FireEvent(game.MakeTeamEvent.InviteJoinCallback, data.target)
end

function MakeTeamCtrl:SendTeamAcceptInvite(team_id, role_id, accept)
    local proto = {
        team_id = team_id,
        role_id = role_id,
        accept = accept,
    }
    self:SendProtocal(42023, proto)
end

function MakeTeamCtrl:OnTeamAcceptInvite(data)
    --[[
        "team_id__L",
        "role_id__L",
        "accept__C",
    ]]
    --PrintTable(data)
end

function MakeTeamCtrl:OnTeamNewInvite(data)
    --[[
        "team_id__L",
        "role_id__L",
        "name__s",
    ]]
    --PrintTable(data)

    self:OpenInviteTipsView(data)

    self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, game.MsgNoticeId.TeamInvite, data.name)
end

function MakeTeamCtrl:OnTeamInviteReject(data)
    --[[
        "role_id__L",
    ]]
    --PrintTable(data)

    -- 拒绝邀请
    -- 需要返回名字
    game.GameMsgCtrl.instance:PushMsg(string.format(config.words[4985], data.name or ""))
end

function MakeTeamCtrl:SendTeamLeave()
    local proto = {

    }
    self:SendProtocal(42027, proto)
end

function MakeTeamCtrl:OnTeamLeave(data)
    self.data:OnTeamLeave(data)

    self:DoFollow(0)

    self:FireEvent(game.MakeTeamEvent.TeamLeave)
end

function MakeTeamCtrl:SendTeamKickOut(target)
    local proto = {
        target = target
    }
    self:SendProtocal(42029, proto)
end

function MakeTeamCtrl:OnTeamKickOut(data)
    --[[
        "target__L",
    ]]
    --PrintTable(data)

    self.data:OnTeamKickOut(data)

    self:FireEvent(game.MakeTeamEvent.UpdateKickOut, data.target)
end

function MakeTeamCtrl:OnTeamMemberLeave(data)
    --[[
        "role_id__L",
    ]]
    --PrintTable(data)

    self.data:OnTeamMemberLeave(data)

    self:FireEvent(game.MakeTeamEvent.TeamMemberLeave, data.role_id)
end

function MakeTeamCtrl:OnTeamNotifyKickOut(data)
    --[[
        
    ]]
    --PrintTable(data)

    self.data:OnTeamNotifyKickOut()

    self:DoFollow(0)
    
    self:FireEvent(game.MakeTeamEvent.NotifyKickOut)
end

function MakeTeamCtrl:SendTeamRecruit()
    local proto = {

    }
    self:SendProtocal(42033, proto)
end

function MakeTeamCtrl:OnTeamRecruit(data)
    --[[
        
    ]]
    --PrintTable(data)
end

function MakeTeamCtrl:SendTeamSetTarget(target, min_lv, max_lv)
    local proto = {
        target = target,
        min = min_lv or 1,
        max = max_lv or 99,
    }
    self:SendProtocal(42035, proto)
end

function MakeTeamCtrl:OnTeamSetTarget(data)
    --[[
        "target__H",
        "min__H",
        "max__H",
    ]]
    --PrintTable(data)

    self.data:OnTeamSetTarget(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamSetTarget, data.target, data.min, data.max)
end

function MakeTeamCtrl:SendTeamSetMatch(match)
    local proto = {
        match = match
    }
    self:SendProtocal(42037, proto)
end

function MakeTeamCtrl:OnTeamSetMatch(data)
    --[[
        "match__C",
    ]]
   -- PrintTable(data)

    self.data:OnTeamSetMatch(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamSetMatch, data.match)
end

function MakeTeamCtrl:SendTeamDemiseLeader(target)
    local proto = {
        target = target
    }
    self:SendProtocal(42039, proto)
end

function MakeTeamCtrl:OnTeamDemiseLeader(data)
    --[[
        "target__L",
    ]]
    --PrintTable(data)

    self.data:OnTeamDemiseLeader(data)

    --self:FireEvent(game.MakeTeamEvent.ChangeLeader, data.target)
end

function MakeTeamCtrl:SendTeamPromoteRequest()
    local proto = {

    }
    self:SendProtocal(42041, proto)
end

function MakeTeamCtrl:OnTeamPromoteRequest(data)
    --[[
        
    ]]
    --PrintTable(data)
end

function MakeTeamCtrl:SendTeamAcceptPromote(role_id, opt)
    local proto = {
        role_id = role_id,
        opt = opt
    }
    self:SendProtocal(42043, proto)
end

function MakeTeamCtrl:OnTeamAcceptPromote(data)
    --[[
        "role_id__L",
        "opt__C",
    ]]
    --PrintTable(data)
    self.data:OnTeamAcceptPromote(data)

    -- if data.opt == 1 then
    --     -- 同意申请队长
    --     self:FireEvent(game.MakeTeamEvent.ChangeLeader, data.role_id)
    -- end
end

function MakeTeamCtrl:OnTeamNotifyLeaderDemise(data)
    --[[
        "leader__L",
    ]]
    --PrintTable(data)

    local is_self_leader = self.data:OnTeamNotifyLeaderDemise(data)

    if is_self_leader then
        self:SendTeamApplyList()
    end

    self:FireEvent(game.MakeTeamEvent.ChangeLeader, data.leader)
end

function MakeTeamCtrl:OnTeamNotifyPromoteRequest(data)
    --[[
        "role_id__L",
        "name__s",
    ]]
    --PrintTable(data)

    -- 队员申请队长弹窗
    if not self.promote_leader_view then
        local title = config.words[4998]
        local content = string.format(config.words[5004], data.name)
        self.promote_leader_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content, 10)
        self.promote_leader_view:SetOkBtn(function()
            self:SendTeamAcceptPromote(data.role_id, 1)

            self.promote_leader_view:DeleteMe()
            self.promote_leader_view = nil
        end, config.words[5010], true)
        self.promote_leader_view:SetCancelBtn(function()
            self:SendTeamAcceptPromote(data.role_id, 0)

            self.promote_leader_view:DeleteMe()
            self.promote_leader_view = nil
        end, config.words[5011])
        self.promote_leader_view:Open()
    end    
end

function MakeTeamCtrl:OnTeamNotifyAcceptPromote(data)
    --[[
        "role_id__L",
        "name__s",
        "opt__C",
    ]]
    --PrintTable(data)
end

function MakeTeamCtrl:SendTeamFollow(opt)
    if not self:IsSelfLeader() then
        return false
    end

    if opt == 1 then
        if self:GetTeamMemberNums() <= 1 then
            game.GameMsgCtrl.instance:PushMsg(config.words[5013])
            return false
        end
    end

    local proto = {
        opt = opt
    }
    self:SendProtocal(42049, proto)

    return true
end

function MakeTeamCtrl:OnTeamFollow(data)
    --[[
        "opt__C",
    ]]
    --PrintTable(data)

    self.data:OnTeamFollow(data)

    self:FireEvent(game.MakeTeamEvent.CallTeamFollow, data.opt)
end

function MakeTeamCtrl:SendTeamSyncState(state)
    local role_id = game.Scene.instance:GetMainRoleID()
    local cur_state = self:GetMemberFollowState(role_id)

    if cur_state == state then
        return
    end

    local proto = {
        state = state
    }
    self:SendProtocal(42051, proto)
end

function MakeTeamCtrl:OnTeamSyncState(data)
    --[[
        "state__C",
    ]]

    --PrintTable(data)

    local role_id = game.Scene.instance:GetMainRoleID()
    data.role_id = role_id

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        --main_role:GetOperateMgr():SetTeamPause(data.state==game.TeamFollowState.Follow)
    end

    self:OnTeamNotifySyncState(data)
end

function MakeTeamCtrl:OnTeamNotifyFollow(data)
    --[[
        "opt__C",
    ]]
    --PrintTable(data)

    self.data:OnTeamNotifyFollow(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamNotifyFollow, data.opt)

    -- 询问是否跟随
    if data.opt == 1 then
        local role_id = game.Scene.instance:GetMainRoleID()
        local cur_state = self:GetMemberFollowState(role_id)
        if cur_state > game.TeamFollowState.NoFollow then
            return
        end

        local leader_id = self:GetLeaderId()
        local leader_obj = game.Scene.instance:GetObjByUniqID(leader_id)
        if leader_obj then
            -- 如果在队长附近，直接同意跟随
            self:DoFollow(1)
            return
        end

        if not self.notify_follow_view then
            local title = config.words[5002]
            local content = config.words[5003]
            self.notify_follow_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content, 10)
            self.notify_follow_view:SetOkBtn(function()
                local main_role = game.Scene.instance:GetMainRole()
                if not game.RoleCtrl.instance:CanTransformChangeScene(main_role, true) then
                    self:DoFollow(0)
                else
                    self:DoFollow(1)
                end

                self.notify_follow_view:DeleteMe()
                self.notify_follow_view = nil
            end, config.words[100], true)
            self.notify_follow_view:SetCancelBtn(function()
                self:DoFollow(0)

                self.notify_follow_view:DeleteMe()
                self.notify_follow_view = nil
            end)
            self.notify_follow_view:Open()
        end    
    else
        if self.notify_follow_view then
            self.notify_follow_view:DeleteMe()
            self.notify_follow_view = nil
        end

        self:DoFollow(0)
    end
end

function MakeTeamCtrl:OnTeamNotifySyncState(data)
    --[[
        "role_id__L",
        "state__C",
    ]]
    --PrintTable(data)

    self.data:OnTeamNotifySyncState(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamNotifySyncState, data)
end

function MakeTeamCtrl:SendTeamMemPos(role_id)
    local proto = {
        role_id = role_id
    }
    self:SendProtocal(42055, proto)
end

function MakeTeamCtrl:OnTeamMemPos(data)
    --[[
        "role_id__L",
        "scene_id__I",
        "x__H",
        "y__H",
    ]]
    ----PrintTable(data)

    self.data:OnTeamMemPos(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamMemPos, data)

    self.follow_action:OnTeamMemPos(data)
end

function MakeTeamCtrl:GetTeamMemPos(role_id)
    return self.data:GetTeamMemPos(role_id)
end

function MakeTeamCtrl:SetTeamMemPos(role_id, key, val)
    self.data:SetTeamMemPos(role_id, key, val)
end

function MakeTeamCtrl:GetLeaderPos()
    local leader_id = self:GetLeaderId()
    return self:GetTeamMemPos(leader_id)
end

function MakeTeamCtrl:SetLeaderPos(x, y)
    self.data:SetLeaderPos(x, y)
end

function MakeTeamCtrl:SetLeaderScene(scene_id)
    local leader_id = self:GetLeaderId()
    self:SetTeamMemPos(leader_id, game.TeamMemAttrTypes.Scene, scene_id)
end

function MakeTeamCtrl:GetLeaderScene()
    local pos = self:GetLeaderPos()
    return pos.scene_id
end

function MakeTeamCtrl:SendTeamAssist(assist)
    local proto = {
        assist = assist
    }
    self:SendProtocal(42057, proto)
end

function MakeTeamCtrl:OnTeamAssist(data)
    --[[
        "role_id__L",
        "assist__C",
    ]]
   -- PrintTable(data)
    self.data:OnTeamAssist(data)

    self:FireEvent(game.MakeTeamEvent.OnUpdateAssist, data.role_id, data.assist)
end

function MakeTeamCtrl:OnTeamMemberAttr(data)
    --[[
        "role_id__L",
        "list__T__type@C##value@I",

        1-血量变化
        2-血量上限变化
        3-等级变化
        4-职业变化
        5-离线时间变化
        6-场景变化
    ]]
    --PrintTable(data)
    self.data:OnTeamMemberAttr(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamMemberAttr, data.role_id, data.list)

    if data.role_id == self:GetLeaderId() then
        local leader_scene = self:GetMemberAttr(data.role_id, game.TeamMemAttrTypes.Scene)
        self:SetLeaderScene(leader_scene)

        self:SendGetLeaderPos()
    end
end

function MakeTeamCtrl:SendTeamCommand(command)
    local proto = {
        command = command   
    }
    self:SendProtocal(42061, proto)
end

function MakeTeamCtrl:OnTeamCommand(data)
    --[[
        "command__s",
    ]]
    --PrintTable(data)

    if not self:IsSelfLeader() then
        table.insert(self.command_list, data.command)
    end
end

function MakeTeamCtrl:SendTeamSetLevel(min_lv, max_lv)
    local proto = {
        min = min_lv,
        max = max_lv,   
    }
    self:SendProtocal(42063, proto)
end

function MakeTeamCtrl:OnTeamSetLevel(data)
    --[[
        "min__H",
        "max__H",
    ]]
    --PrintTable(data)

    self.data:OnTeamSetLevel(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamSetLevel, data.min, data.max)
end

function MakeTeamCtrl:OnTeamSyncPos(data)
    --[[
        "role_id__L",
        "x__H",
        "y__H",
    ]]
   -- PrintTable(data)

    self.data:OnTeamSyncPos(data)

    self:FireEvent(game.MakeTeamEvent.OnTeamSyncPos, data)
end

--发送队伍踢机器人
function MakeTeamCtrl:SendKickRobot(robot_cid)
    local proto = {
        robot_cid = robot_cid   
    }
    self:SendProtocal(42071, proto)
end

function MakeTeamCtrl:OnKickRobot(data)
    --[[
        "robot_cid__C",
    ]]

    --PrintTable(data)

    data.target = data.robot_cid

    self.data:OnKickRobot(data)

    self:FireEvent(game.MakeTeamEvent.UpdateKickOut, data.target)
end

--发送添加机器人
function MakeTeamCtrl:SendAddRobot()
    local proto = {

    }
    self:SendProtocal(42073, proto)
end

function MakeTeamCtrl:OnAddRobot(data)
    --[[
        "ids__T__robot_cid@C",
    ]]

    --[[
        proto.CltTeamMember = {
        "id__L",
        "name__s",
        "hp__I",
        "hp_lim__I",
        "level__H",
        "state__C",
        "scene__I",
        "career__C",
        "gender__C",
        "offline__I",
        "icon__H",
        "frame__H",
        "assist__C",
}
    ]]

   -- PrintTable(data)

    self.data:OnAddRobot(data)

    if self:IsFullMember() then
        -- 满队员
        if self:IsSelfLeader() then
            self:SendTeamSetMatch(0)
            self:ShowFullMemberTips()
        end
    end
end

function MakeTeamCtrl:DoFollow(opt)
    local state = game.TeamFollowState.NoFollow
    if opt == 1 then
        state = game.TeamFollowState.CloseTo
    else
        state = game.TeamFollowState.NoFollow
    end

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        local main_ui_ctrl = game.MainUICtrl.instance
        if main_ui_ctrl:IsHanging() then
            main_ui_ctrl:SetFollowHanging(true)
        end

        self:SetMemberFollowState(main_role:GetUniqueId(), state)
    end

    self:SendTeamSyncState(state)
end

function MakeTeamCtrl:IsTeamFollow()
    return self.data:IsTeamFollow()
end

function MakeTeamCtrl:GetMemberFollowState(role_id)
    return self.data:GetMemberFollowState(role_id)
end

function MakeTeamCtrl:SetMemberFollowState(role_id, state)
    self.data:SetMemberFollowState(role_id, state)
end

function MakeTeamCtrl:GetMemberAttr(role_id, attr_type)
    return self.data:GetMemberAttr(role_id, attr_type)
end

function MakeTeamCtrl:IsFullMember()
    return self.data:IsFullMember()
end

function MakeTeamCtrl:GetApplyList()
    return self.data:GetApplyList()
end

function MakeTeamCtrl:GetMemberAttrList(role_id)
    return self.data:GetMemberAttrList(role_id)
end

function MakeTeamCtrl:GetTeamMemberById(role_id)
    return self.data:GetTeamMemberById(role_id)
end

function MakeTeamCtrl:GetTeamMemberLine(role_id)
    return self.data:GetTeamMemberLine(role_id)
end

function MakeTeamCtrl:Update(now_time, elapse_time)
    if not self.is_login_succ then
        return
    end

    if not self:HasTeam() then
        return
    end

    local command = self.command_list[1]
    if command then
        table.remove(self.command_list, 1)
        self:OnLakeExpCommand(command)
        self:OnCxdtCommand(command)
        self:OnDbmzCommand(command)
    end

    if self:IsSelfLeader() then
        if not self:IsTeamFollow() then
            local main_ui_ctrl = game.MainUICtrl.instance
            local is_follow_hanging = main_ui_ctrl:IsFollowHanging()
            if is_follow_hanging then
                local main_role = game.Scene.instance:GetMainRole()
                if main_role then
                    local cur_oper = main_role:GetOperateMgr():GetCurOperate()
                    if not cur_oper or (cur_oper:GetOperateType()~=game.OperateType.Hang) then
                        main_role:GetOperateMgr():DoHang()
                    end
                    main_ui_ctrl:SetFollowHanging(false)
                end
            end
        end
        return
    end

    -- if now_time >= self.next_update_pos_time then
    --     self:SendGetLeaderPos()
    -- end

    local following = self.follow_action:Update(now_time, elapse_time)

    if self.is_doing_follow and (not following) then
        game.MainUICtrl.instance:SetGestureCallBack(nil)
    end

    self.is_doing_follow = following

    if self.is_doing_follow then
        if not self.gesture_callback then
            self.gesture_callback = function()
                local role_id = game.Scene.instance:GetMainRoleID()
                local follow_state = self:GetMemberFollowState(role_id)
                if follow_state == game.TeamFollowState.CloseTo then
                    -- 取消跟随
                    self:SendTeamSyncState(game.TeamFollowState.NoFollow)
                    self:SetMemberFollowState(role_id, game.TeamFollowState.NoFollow)

                    return true
                end

                return not (follow_state == game.TeamFollowState.Follow)
            end
            game.MainUICtrl.instance:SetGestureCallBack(self.gesture_callback)
        end
    else
        self.gesture_callback = nil

        local is_follow_hanging = game.MainUICtrl.instance:IsFollowHanging()
        if is_follow_hanging then
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                local cur_oper = main_role:GetOperateMgr():GetCurOperate()
                if not cur_oper or (cur_oper:GetOperateType()~=game.OperateType.Hang) then
                    main_role:GetOperateMgr():DoHang()
                end
                --self:SetFollowHanging(false)
            end
        end
    end
end

function MakeTeamCtrl:GetTeamMemFollowIndex(role_id)
    return self.data:GetTeamMemFollowIndex(role_id)
end

function MakeTeamCtrl:GetTeamMemIndex(role_id)
    return self.data:GetTeamMemIndex(role_id)
end

function MakeTeamCtrl:GetTeamMemSyncState(role_id)
    return self.data:GetTeamMemSyncState(role_id)
end

function MakeTeamCtrl:IsMemberFollow(role_id)
    return self.data:IsMemberFollow(role_id)
end

function MakeTeamCtrl:IsMemberOffline(role_id)
    return self.data:IsMemberOffline(role_id)
end

function MakeTeamCtrl:DoTeamInviteJoin(role_id)
    if not self:HasTeam() then
        -- 没有队伍，创建
        self:SendTeamCreate(0)

        self.to_invite_role_id = role_id
        return
    end

    self:SendTeamInviteJoin(role_id)
end

function MakeTeamCtrl:SetFollowPause(val)
    self.follow_pause = val
end

function MakeTeamCtrl:IsFollowPause()
    return self.follow_pause
end

function MakeTeamCtrl:DoFollowStart()
    if self:HasTeam() then
        self.follow_action:DoStart()
    end
end

function MakeTeamCtrl:DoFollowReset()
    if self:HasTeam() then
        if self:IsSelfLeader() then
            self:SendTeamFollow(0)
        else
            self.follow_action:DoReset()
        end
    end
end

function MakeTeamCtrl:IsDoingFollow()
    if self:IsSelfLeader() then
        return self:IsTeamFollow()
    end

    return self.is_doing_follow
end

function MakeTeamCtrl:GetMemberAssist(role_id)
    local member_info = self:GetTeamMemberById(role_id)
    if member_info then
        return member_info.assist
    end
    return 0
end

function MakeTeamCtrl:GetSelfAssist()
    local role_id = game.Scene.instance:GetMainRoleID()
    return self:GetMemberAssist(role_id)
end

function MakeTeamCtrl:ShowFullMemberTips()
    local target = self:GetTeamTarget()
    local target_cfg = config.team_target[target]
    if target_cfg then
        local title = nil
        local content = config.words[5025]
        local msg_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content)
        msg_view:SetOkBtn(function()
            self.apply_view:Close()
            self.invite_view:Close()

            self:CloseView()
            self:SendTeamFollow(1)

            local cfg = TeamTargetConfig[target]
            if cfg then
                cfg.click_func(target_cfg)
            end
        end)

        msg_view:SetCancelBtn(function()
            
        end)
        msg_view:Open()
    end
end

function MakeTeamCtrl:GotoTeamTarget()
    local team_target = self:GetTeamTarget()
    local cfg = config.team_target[team_target]
    if cfg and cfg.dun_id>0 then
        local dun_cfg = config.dungeon[cfg.dun_id]
        local npc_id = dun_cfg.npc

        local main_role = game.Scene.instance:GetMainRole()
        main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, nil)
    end
end

function MakeTeamCtrl:OnLakeExpCommand(command)
    if command ~= game.MakeTeamCommand.LakeExp then
        return
    end

    local main_role = game.Scene.instance:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoSceneHang()
    end
end

function MakeTeamCtrl:OnCxdtCommand(command)
    if command ~= game.MakeTeamCommand.Cxdt then
        return
    end

    game.MainUICtrl.instance:ShowTask(game.DailyTaskId.RobberTask)
end

function MakeTeamCtrl:OnDbmzCommand(command)
    if command ~= game.MakeTeamCommand.Dbmz then
        return
    end

    game.MainUICtrl.instance:ShowTask(game.DailyTaskId.BanditTask)
end

--更新团队成员标志
function MakeTeamCtrl:OnUpdateTeamMemberFlag()
    local scene = game.Scene.instance
    --获取团队成员标志列表
    local flag_list = self.data:GetTeamMemberFlagList()
    for k,v in pairs(flag_list) do
        local obj = scene:GetObjByUniqID(k)
        if obj then
            obj:SetTeamFlag(v)
        end
    end
end

--获取团队成员标志
function MakeTeamCtrl:GetTeamMemberFlag(role_id)
    return self.data:GetTeamMemberFlag(role_id)
end

function MakeTeamCtrl:QuickMakeTeam(target)
    if self:HasTeam() then
        self:OpenTeamView(target)
    else
        local cate = config.team_target[target].cate
        self:OpenPlatformView(cate, true)
    end
end

game.MakeTeamCtrl = MakeTeamCtrl

return MakeTeamCtrl
