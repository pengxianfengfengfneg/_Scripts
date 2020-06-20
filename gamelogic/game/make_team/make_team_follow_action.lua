local MakeTeamFollowAction = Class()

local _et = {}
local event_mgr = global.EventMgr

local UnitToLogicPos = game.UnitToLogicPos
local LogicToUnitPos = game.LogicToUnitPos

local FollowState = {
    None        = 0,
    Seek        = 1,    -- 寻找队长
    Follow      = 2,    -- 跟随队长
    ChangeScene = 3,
    Idle        = 4,
    CloseTo     = 5,
    Reset       = 6,
    GetLeaderPos = 7,
    WaitLeaderPos = 8,
    SeekJump = 9,
}

local StepDist = 1.2
local pDistanceSQ = cc.pDistanceSQ

local FollowLenSQ = 6
local NextFindWayTime = 0
local FindWayDelta = 0.3
local SeekLeaderUnitPos = {x=0,y=0}

local NextFollowTime = 0
local FollowDelta = 0.25

local NextCloseToTime = 0
local CloseToDelta = 0.5

function MakeTeamFollowAction:_init(ctrl)
    self.ctrl = ctrl

    self:Init()
end

function MakeTeamFollowAction:_delete()
    self:UnRegisterAllEvents()
end

function MakeTeamFollowAction:Init(obj)
    self.follow_state = FollowState.None

    self:RegisterAllEvents()
end

function MakeTeamFollowAction:RegisterAllEvents()
    self.bind_events = {
        event_mgr:Bind(game.GameEvent.StartPlay, function()
            self.cur_scene = game.Scene.instance
            self.main_role = self.cur_scene:GetMainRole()
            self.main_role_id = self.main_role:GetUniqueId()

            self.follow_state = FollowState.GetLeaderPos
        end),
        event_mgr:Bind(game.GameEvent.StopPlay, function()
            self.main_role = nil
        end),

        event_mgr:Bind(game.LoginEvent.LoginReconnectFinish, function()
            self.cur_scene = game.Scene.instance
            self.main_role = self.cur_scene:GetMainRole()
            self.main_role_id = self.main_role:GetUniqueId()

            self.follow_state = FollowState.GetLeaderPos
        end)
    }
end

function MakeTeamFollowAction:UnRegisterAllEvents()
    for _,v in ipairs(self.bind_events or _et) do
        event_mgr:UnBind(v)
    end
    self.bind_events = nil
end

function MakeTeamFollowAction:Update(now_time, elapse_time)
    if self.follow_state == FollowState.ChangeScene then
        return true
    end

    if self.follow_state == FollowState.WaitLeaderPos then
        return true
    end

    if not self.main_role then
        return false
    end

    self.main_role:GetOperateMgr():SetTeamPause(false)

    -- if self.follow_state == FollowState.GetLeaderPos then
    --     self.follow_state = FollowState.WaitLeaderPos
    --     self:SendGetLeaderPos(now_time)
    --     return
    -- end

    if self.follow_state == FollowState.Reset then
        self.follow_state = FollowState.Idle
        if self.main_role:CanDoIdle() then
            self.main_role:DoIdle()
        end
        return false
    end

    if self.main_role:IsDead() then
        self:DoReset()
        return false
    end

    if self.ctrl:IsFollowPause() then
        return true
    end

    if not self.ctrl:IsMemberFollow(self.main_role_id) then
        if self.follow_state == FollowState.Follow then
            self.follow_state = FollowState.Reset
        end
        return false
    end

    if self:UpdateSeekJumpState(now_time, elapse_time) then
        return true
    end

    local is_pre_leader_obj = (self.leader_obj~=nil)
    local is_team_follow = self.ctrl:IsTeamFollow()
    local leader_id = self.ctrl:GetLeaderId()
    self.leader_obj = self.cur_scene:GetObjByUniqID(leader_id)
    if self.leader_obj then
        -- 有目标
        if is_team_follow then
            -- 队伍处于跟随召集
            self.follow_state = FollowState.Follow
        else
            -- 非跟随召集，停止跟随
            self.follow_state = FollowState.CloseTo
        end

        self.ctrl:SetLeaderPos(self.leader_obj:GetLogicPosXY())
        local state = self.ctrl:GetMemberFollowState(leader_id)
        self.main_role:GetOperateMgr():SetTeamPause(state == game.TeamFollowState.Follow)
    else
        local offline = self.ctrl:GetMemberAttr(leader_id, 5)
        if offline > 0 then
            -- 队长离线
            self:DoReset()
            return false
        else
            -- if is_pre_leader_obj then
            --     -- 队长消失
            --     self:SendGetLeaderPos(now_time)
            --     return
            -- end

            self.follow_state = FollowState.Seek

            if is_pre_leader_obj then
                -- 队长消失
                --self:SendGetLeaderPos(now_time)

                self.follow_state = FollowState.GetLeaderPos
            end
        end
    end

    self:UpdateFollowState(now_time, elapse_time)
    self:UpdateSeekState(now_time, elapse_time)
    self:UpdateCloseToState(now_time, elapse_time)
    self:UpdateGetLeaderPos(now_time, elapse_time)

    return true
end

function MakeTeamFollowAction:UpdateSeekState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Seek then
        return
    end

    local leader_pos = self.ctrl:GetLeaderPos()
    if not leader_pos then
        self.follow_state = FollowState.GetLeaderPos
        return
    end

    local leader_scene_id = leader_pos.scene_id
    local cur_scene_id = self.cur_scene:GetSceneID()
    local cur_server_line = self.cur_scene:GetServerLine()

    if leader_scene_id ~= cur_scene_id or cur_server_line~=leader_pos.line_id then
        self.follow_state = FollowState.ChangeScene

        -- 不同场景，切换
        local scene_logic = self.main_role:GetScene():GetSceneLogic()
        if not scene_logic:CanChangeScene(leader_scene_id) then
            -- 队长进入不可直接传送场景
            game.GameMsgCtrl.instance:PushMsg(config.words[5014])
            self:DoReset()
            return
        end

        --self.main_role:GetOperateMgr():DoChangeScene(leader_scene_id, true)
        self.cur_scene:SendChangeSceneReq(leader_scene_id, leader_pos.line_id)
        return
    end

    if now_time >= NextFindWayTime then
        NextFindWayTime = now_time + FindWayDelta

        local ux,uy = LogicToUnitPos(leader_pos.x, leader_pos.y)

        SeekLeaderUnitPos.x = ux
        SeekLeaderUnitPos.y = uy 
        local obj_pos = self.main_role:GetUnitPos()
        local lenSQ = pDistanceSQ(obj_pos, SeekLeaderUnitPos)
        if lenSQ <= 4 then
            --self.ctrl:SendGetLeaderPos()
            self.follow_state = FollowState.GetLeaderPos
        end

        if lenSQ > StepDist then
            self:DoFindWay(ux, uy, 0, nil, false, true, true)
        end
    end
end

function MakeTeamFollowAction:UpdateFollowState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Follow then
        return
    end

    if now_time >= NextFollowTime then
        NextFollowTime = now_time + FollowDelta

        local state = self.ctrl:GetMemberFollowState(self.main_role:GetUniqueId())
        if state ~= game.TeamFollowState.Follow then
            self:SendTeamSyncState(game.TeamFollowState.Follow)
        end

        local obj_pos = self.main_role:GetUnitPos()
        local leader_pos = self.leader_obj:GetUnitPos()

        local idx = self.ctrl:GetTeamMemFollowIndex(self.main_role_id)
        local follow_dist = (StepDist*idx)
        local follow_dist_sq = (follow_dist+1)*(follow_dist+1)

        local is_leader_move = (self.leader_obj:GetCurStateID()==game.ObjState.Move)
        local lenSQ = pDistanceSQ(leader_pos, obj_pos)
        if lenSQ > follow_dist_sq then
            self:DoFindWay(leader_pos.x, leader_pos.y, follow_dist, nil, is_leader_move, true, true)
        else
            if is_leader_move then
                self:DoFindWay(leader_pos.x, leader_pos.y, 0, nil, is_leader_move, true, true)
            else
                if self.main_role:CanDoIdle() then
                    self.main_role:DoIdle()
                end
            end
        end
    end
end

function MakeTeamFollowAction:UpdateCloseToState(now_time, elapse_time)
    if self.follow_state ~= FollowState.CloseTo then
        return
    end

    if now_time >= NextCloseToTime then
        NextCloseToTime = now_time + CloseToDelta

        local leader_pos = self.leader_obj:GetUnitPos()
        local obj_pos = self.main_role:GetUnitPos()
        local lenSQ = pDistanceSQ(leader_pos, obj_pos)

        if lenSQ > 12 then
            self:DoFindWay(leader_pos.x, leader_pos.y, 2, nil, false, true, true)
        else
            self:DoReset()
        end
    end
end

function MakeTeamFollowAction:SendTeamSyncState(state)
    self.ctrl:SendTeamSyncState(state)
end

function MakeTeamFollowAction:DoStart()
    self.leader_obj = nil
    self.seek_jump_pos = nil
    self.follow_state = FollowState.GetLeaderPos
end

function MakeTeamFollowAction:DoReset()
    self.follow_state = FollowState.Reset

    local main_role_id = game.Scene.instance:GetMainRoleID()
    self:SendTeamSyncState(game.TeamFollowState.NoFollow)
    self.ctrl:SetMemberFollowState(main_role_id, game.TeamFollowState.NoFollow)
end

function MakeTeamFollowAction:DoFindWay(ux, uy, offset_dist, callback, keep_move, is_force, not_effect)
    if self.main_role:CanDoMove() then
        self.main_role:GetOperateMgr():DoFindWay(ux, uy, offset_dist, callback, keep_move, is_force, not_effect)
    end
end

local NextGetLeaderPosTime = 0
local NextGetLeaderPosDelta = 0.5
function MakeTeamFollowAction:OnTeamMemPos(data)
    --[[
        "role_id__L",
        "scene_id__I",
        "x__H",
        "y__H",
    ]]
    --PrintTable(data)

    if self:IsJumpPos(data) then
        self.seek_jump_pos = {
            x = data.x,
            y = data.y,
            is_find_way = false,
        }
    end

    if self.follow_state == FollowState.WaitLeaderPos then
        self.follow_state = FollowState.Seek
    end
end

function MakeTeamFollowAction:SendGetLeaderPos(now_time)
    if now_time >= NextGetLeaderPosTime then
        NextGetLeaderPosTime = now_time + NextGetLeaderPosDelta
        self.ctrl:SendGetLeaderPos()
    end
end

local et = {}
function MakeTeamFollowAction:IsJumpPos(pos)
    if not self.cur_scene then
        return false
    end

    local scene_cfg = self.cur_scene:GetSceneConfig()
    local jump_list = scene_cfg.jump_list or et
    for _,v in ipairs(jump_list) do
        local fx,fy = UnitToLogicPos(v.from.x, v.from.z)
        if fx==pos.x and fy==pos.y then
            return true
        end

        local tx,ty = UnitToLogicPos(v.to.x, v.to.z)
        if tx==pos.x and ty==pos.y then
            return true
        end
    end
    return false
end

function MakeTeamFollowAction:UpdateGetLeaderPos(now_time, elapse_time)
    if self.follow_state ~= FollowState.GetLeaderPos then
        return
    end

    if now_time >= NextGetLeaderPosTime then
        NextGetLeaderPosTime = now_time + NextGetLeaderPosDelta
        self.ctrl:SendGetLeaderPos()

        self.follow_state = FollowState.WaitLeaderPos
    end
end

function MakeTeamFollowAction:UpdateSeekJumpState(now_time, elapse_time)
    if not self.seek_jump_pos then
        return false
    end

    if not self.seek_jump_pos.is_find_way then
        self.seek_jump_pos.is_find_way = true

        local ux,uy = LogicToUnitPos(self.seek_jump_pos.x, self.seek_jump_pos.y)

        self:DoFindWay(ux, uy, 0, nil, false, true, true)
    else
        local lx,ly = self.main_role:GetLogicPosXY()
        if lx==self.seek_jump_pos.x and ly==self.seek_jump_pos.y then
            self.seek_jump_pos = nil
            self.follow_state = FollowState.GetLeaderPos
        end
    end

    return true
end

return MakeTeamFollowAction
