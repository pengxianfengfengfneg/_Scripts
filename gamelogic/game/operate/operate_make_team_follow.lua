local OperateMakeTeamFollow = Class(require("game/operate/operate_base"))

local _et = {}
local event_mgr = global.EventMgr

local FollowState = {
    None        = 0,
    Seek        = 1,    -- 寻找队长
    Follow      = 2,    -- 跟随队长
}

local StepDist = 2

function OperateMakeTeamFollow:_init()
    self.oper_type = game.OperateType.MakeTeamFollow
end

function OperateMakeTeamFollow:_delete()
    self:ClearCurOperate()
    self:UnRegisterAllEvents()
end

function OperateMakeTeamFollow:Reset()
    self.obj:SetFollowSpeed(nil)
    
    self:SendTeamSyncState(game.TeamFollowState.NoFollow)

    self:ClearCurOperate()
    self:UnRegisterAllEvents()

    OperateMakeTeamFollow.super.Reset(self)
end

function OperateMakeTeamFollow:Init(obj)
    OperateMakeTeamFollow.super.Init(self, obj)

    self.leader_id = nil
    self.is_start_follow = false
    self.follow_state = FollowState.None
    
end

function OperateMakeTeamFollow:RegisterAllEvents()
    self.bind_events = {
        event_mgr:Bind(game.MakeTeamEvent.OnTeamMemPos, function(data)
            self:OnTeamMemPos(data)
        end),
        event_mgr:Bind(game.MakeTeamEvent.ChangeLeader, function(leader_id)
            self:OnChangeLeader(leader_id)
        end),
    }
end

function OperateMakeTeamFollow:UnRegisterAllEvents()
    for _,v in ipairs(self.bind_events or _et) do
        event_mgr:UnBind(v)
    end
    self.bind_events = nil
end

function OperateMakeTeamFollow:Start()
    self.is_stop_follow = false
    self.ctrl = game.MakeTeamCtrl.instance

    if not self.ctrl:HasTeam() then
        return false
    end

    self.leader_scene = 0
    self.leader_pos = {x=0, y=0}

    self.leader_id = self.ctrl:GetLeaderId()
    self.ctrl:SendGetLeaderPos()

    self:RegisterAllEvents()

    return true
end

function OperateMakeTeamFollow:OnTeamMemPos(data)
    if data.role_id ~= self.leader_id then
        return
    end

    self.leader_pos.x,self.leader_pos.y = data.x,data.y

    self.leader_scene = data.scene_id

    self:StartFollow()
end

function OperateMakeTeamFollow:OnChangeLeader(leader_id)
    self.is_stop_follow = true
end

function OperateMakeTeamFollow:StartFollow()
    if self.is_start_follow then
        return
    end

    self.is_start_follow = true

    self:ClearCurOperate()

    self.follow_state = FollowState.Seek
end

function OperateMakeTeamFollow:Update(now_time, elapse_time)
    if self.is_stop_follow then
        return false
    end

    if not self.is_start_follow then
        return
    end    

    self:UpdateSeekState(now_time, elapse_time)
    self:UpdateFollowState(now_time, elapse_time)
end

local FollowLenSQ = 6
local pDistanceSQ = cc.pDistanceSQ
function OperateMakeTeamFollow:UpdateSeekState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Seek then
        return
    end

    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()

            self:CheckFollowState()
        end
    else
        -- local scene = self.obj:GetScene()
        -- local leader_obj = scene:GetObjByUniqID(self.leader_id)
        -- if not leader_obj then
        --     if self.ctrl:IsMemberOffline(self.leader_id) then
        --         -- 队长离线
        --         return
        --     end
        -- end

        local lx,ly = self.obj:GetLogicPosXY()
        if lx==self.leader_pos.x and ly==self.leader_pos.y then
            return
        end

        if self:CheckFollowState() then
            return
        end

        local cur_scene_id = self.obj:GetScene():GetSceneID()
        if cur_scene_id ~= self.leader_scene then
            -- 不同场景，切换
            local scene_logic = self.obj:GetScene():GetSceneLogic()
            if not scene_logic:CanChangeScene(self.leader_scene) then
                -- 队长进入不可直接传送场景
                return
            end
            self.cur_oper = self:CreateOperate(game.OperateType.ChangeScene, self.obj, self.leader_scene)
        else
            -- 同场景
            local leader_pos = self.leader_pos
            local my_pos = self.obj:GetLogicPos()

            local lenSQ = pDistanceSQ(leader_pos, my_pos)
            if lenSQ >= FollowLenSQ then
                local ux,uy = game.LogicToUnitPos(self.leader_pos.x, self.leader_pos.y)
                self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, ux, uy, 2)
            end
        end

        if self.cur_oper and not self.cur_oper:Start() then
            self:ClearCurOperate()
        end
    end
end

function OperateMakeTeamFollow:UpdateFollowState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Follow then
        return
    end

    local scene = self.obj:GetScene()
    local leader_obj  = scene:GetObjByUniqID(self.leader_id)
    if not leader_obj then
        -- 找不到队长 重新寻找
        self:ClearCurOperate()
        self.follow_state = FollowState.Seek
        return
    end

    self.leader_pos.x,self.leader_pos.y = leader_obj:GetLogicPosXY()

    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    else

        local lx,ly = self.obj:GetLogicPosXY()
        if lx==self.leader_pos.x and ly==self.leader_pos.y then
            return
        end

        local leader_pos = leader_obj:GetUnitPos()
        local my_pos = self.obj:GetUnitPos()

        local idx = self.ctrl:GetTeamMemFollowIndex(self.obj:GetUniqueId())  
        local follow_dist = (StepDist*idx + 1)
        local follow_dist_sq = follow_dist*follow_dist

        local lenSQ = pDistanceSQ(leader_pos, my_pos)
        if lenSQ > follow_dist_sq then
            -- 大于跟随距离的移动
            self.obj:SetFollowSpeed(leader_obj:GetSpeed()*0.95)
            self.obj:DoMove(leader_pos.x, leader_pos.y, false, follow_dist)
        end
    end

end

function OperateMakeTeamFollow:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateMakeTeamFollow:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateMakeTeamFollow:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type)
end

function OperateMakeTeamFollow:CheckFollowState()
    local scene = self.obj:GetScene()
    local leader_obj  = scene:GetObjByUniqID(self.leader_id)
    local team_follow_state = self.ctrl:GetTeamFollowState()
    if team_follow_state == 1 then
        -- 队伍处于召集跟随状态，队员才进入跟随
        if leader_obj then
            -- 进入跟随状态
            self:SendTeamSyncState(game.TeamFollowState.Follow)

            self.leader_pos.x,self.leader_pos.y = leader_obj:GetLogicPosXY()

            self:ClearCurOperate()
            self.follow_state = FollowState.Follow
            return true
        end
    else
        if leader_obj then
            -- 停止跟随
            self.is_stop_follow = true
        else
            self:SendTeamSyncState(game.TeamFollowState.CloseTo)
        end
    end
    return false
end

function OperateMakeTeamFollow:SendTeamSyncState(state)
    self.ctrl:SendTeamSyncState(state)
end

return OperateMakeTeamFollow
