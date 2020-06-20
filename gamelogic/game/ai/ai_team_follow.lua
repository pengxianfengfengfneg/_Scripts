local AiTeamFollow = Class(require("game/ai/ai_base"))

local _table_insert = table.insert
local handler = handler
local pDistanceSQ = cc.pDistanceSQ

local _et = {}
local event_mgr = global.EventMgr

local StepDist = 2

local FollowState = {
    None = 0,
    GetPos = 1,
    Seek = 2,
    ChangeScene = 3,
    Follow = 4,
    Seeking = 5,
    Following = 6
}

function AiTeamFollow:_init(mgr, obj, ai_type)
    self.follow_state = FollowState.None

    self:Start()

    self:RegisterAllEvents()
end

function AiTeamFollow:_delete()
    self:UnRegisterAllEvents()
end

function AiTeamFollow:RegisterAllEvents()
    self.bind_events = {
        event_mgr:Bind(game.MakeTeamEvent.ChangeLeader, function(leader_id)
            self:OnChangeLeader(leader_id)
        end),
    }
end

function AiTeamFollow:UnRegisterAllEvents()
    for _,v in ipairs(self.bind_events or _et) do
        event_mgr:UnBind(v)
    end
    self.bind_events = nil
end

function AiTeamFollow:Start()
    self.ctrl = game.MakeTeamCtrl.instance

    self.next_sync_time = 0

    self:DoSeek()
end

function AiTeamFollow:OnChangeLeader(leader_id)
    local role_id = self.ai_obj:GetUniqueId()
    if leader_id == role_id then
        -- 自己成为队长，停止跟随
        self.ai_obj:DelObjAi()
        return
    end
end

function AiTeamFollow:Update(now_time, elapse_time)    
    if not self.ctrl:HasTeam() then
        self:DoStopAi()
        return
    end

    self:UpdateChangeScene(now_time, elapse_time)
    self:UpdateSeekState(now_time, elapse_time)
    self:UpdateSeekingState(now_time, elapse_time)
    self:UpdateFollowState(now_time, elapse_time)
    self:UpdateFollowingState(now_time, elapse_time)

    self:UpdateSyncState(now_time, elapse_time)
end

function AiTeamFollow:UpdateChangeScene(now_time, elapse_time)
    if self.follow_state ~= FollowState.ChangeScene then
        return
    end

    local scene = self.ai_obj:GetScene()
    local cur_scene_id = scene:GetSceneID()
    local leader_pos = self.ctrl:GetLeaderPos()
    if not leader_pos then
        return
    end

    if leader_pos.scene_id ~= cur_scene_id then
        self.follow_state = FollowState.None
        scene:SendChangeSceneReq(leader_pos.scene_id)
    end
end

function AiTeamFollow:UpdateSeekState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Seek then
        return
    end

    local leader_pos = self.ctrl:GetLeaderPos()
    if not leader_pos then
        return
    end

    local scene = self.ai_obj:GetScene()
    local cur_scene_id = scene:GetSceneID()

    if leader_pos.scene_id == cur_scene_id then
        local leader_id = self.ctrl:GetLeaderId()
        local leader_obj = scene:GetObjByUniqID(leader_id)
        if leader_obj then
            -- aoi范围内，开始跟随
            self:DoFollow()
        else
            local idx = self.ctrl:GetTeamMemIndex(self.ai_obj:GetUniqueId())
            local leader_unit_pos_x,leader_unit_pos_y = game.LogicToUnitPos(leader_pos.x, leader_pos.y)
            self.ai_obj:GetOperateMgr():DoFindWay(leader_unit_pos_x, leader_unit_pos_y, StepDist*idx, handler(self,self.OnFindWayCallback), false, true)
            
            self:DoSeeking()
        end
    else
        -- 切换场景
        self:DoChangeScene()
    end
end

function AiTeamFollow:UpdateSeekingState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Seeking then
        return
    end

    local scene = self.ai_obj:GetScene()
    local leader_id = self.ctrl:GetLeaderId()
    local leader_obj = scene:GetObjByUniqID(leader_id)
    if leader_obj then
         local follow_unit_pos = leader_obj:GetUnitPos()
        local obj_unit_pos = self.ai_obj:GetUnitPos()
        local idx = self.ctrl:GetTeamMemIndex(self.ai_obj:GetUniqueId())  
        local follow_dist = StepDist*idx  
        local follow_dist_sq = (follow_dist+2)*(follow_dist+2)

        if pDistanceSQ(follow_unit_pos, obj_unit_pos) <= follow_dist_sq then
            self.ai_obj:DoIdle()
            
            self:DoFollow()
        end

    end
end

function AiTeamFollow:OnFindWayCallback(is_done)
    if is_done then
        local scene = self.ai_obj:GetScene()
        local leader_id = self.ctrl:GetLeaderId()
        local leader_obj = scene:GetObjByUniqID(leader_id)
        if leader_obj then
            self:DoFollow()
        else        
            self:DoSeek()
        end
    else
        local role_id = self.ai_obj:GetUniqueId()
        local state = self.ctrl:GetMemberFollowState(role_id)
        if state == 1 then
            self:DoStopFollow()
        end
    end
end

function AiTeamFollow:UpdateFollowState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Follow then
        return
    end

    local scene = self.ai_obj:GetScene()
    local leader_id = self.ctrl:GetLeaderId()
    local leader_obj = scene:GetObjByUniqID(leader_id)
    if not leader_obj then
        -- 丢失队长，重新寻找        
        self:DoSeek()
        return
    end

    local follow_unit_pos = leader_obj:GetUnitPos()
    local obj_unit_pos = self.ai_obj:GetUnitPos()
    
    local idx = self.ctrl:GetTeamMemIndex(self.ai_obj:GetUniqueId())  
    local follow_dist = StepDist*idx  
    local follow_dist_sq = (follow_dist+2)*(follow_dist+2)

    if pDistanceSQ(follow_unit_pos, obj_unit_pos) >= follow_dist_sq then
        self:SetSpeed(leader_obj:GetSpeed()*0.95)
        
        self.ai_obj:GetOperateMgr():DoFindWay(follow_unit_pos.x, follow_unit_pos.y, follow_dist, handler(self, self.OnFollowCallback), true, true)
        
        self:DoFollowing()
    end
end

function AiTeamFollow:UpdateFollowingState(now_time, elapse_time)
    if self.follow_state ~= FollowState.Following then
        return
    end

    local leader_id = self.ctrl:GetLeaderId()
    local leader_obj = self.ai_obj:GetScene():GetObjByUniqID(leader_id)
    if not leader_obj then        
        self:DoSeek()
    end
end

function AiTeamFollow:OnFollowCallback()
    local leader_id = self.ctrl:GetLeaderId()
    local leader_obj = self.ai_obj:GetScene():GetObjByUniqID(leader_id)
    if not leader_obj then
        self:DoSeek()
        return
    end

    self:DoFollow()
    
    local follow_unit_pos = leader_obj:GetUnitPos()
    local obj_unit_pos = self.ai_obj:GetUnitPos()
    local idx = self.ctrl:GetTeamMemIndex(self.ai_obj:GetUniqueId())  
    local follow_dist = StepDist*idx  
    local follow_dist_sq = (follow_dist+2)*(follow_dist+2)

    if pDistanceSQ(follow_unit_pos, obj_unit_pos) > follow_dist_sq then
        
    else
        self.ai_obj:DoIdle()
    end
end

function AiTeamFollow:DoSeek()
    self.follow_state = FollowState.Seek

    self.send_sync_state = 1
end

function AiTeamFollow:DoSeeking()
    self.follow_state = FollowState.Seeking
end

function AiTeamFollow:DoFollow()
    self.follow_state = FollowState.Follow

    self.send_sync_state = 2
end

function AiTeamFollow:DoFollowing()
    self.follow_state = FollowState.Following
end

function AiTeamFollow:DoChangeScene()
    self.follow_state = FollowState.ChangeScene
end

function AiTeamFollow:DoStopFollow()
    self.follow_state = FollowState.None

    self.send_sync_state = 0
end

function AiTeamFollow:UpdateSyncState(now_time, elapse_time)
    if now_time >= self.next_sync_time then
        if self.send_sync_state then
            self.next_sync_time = now_time + 0.5

            self.ctrl:SendTeamSyncState(self.send_sync_state)

            if self.send_sync_state == 0 then
                self.ai_obj:FreeObjAi()
            end
            self.send_sync_state = nil
        end
    end
end

function AiTeamFollow:DoStopAi()
    self.ai_obj:FreeObjAi()
end

return AiTeamFollow
