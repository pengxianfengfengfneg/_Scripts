local PracticeState = Class()

function PracticeState:_init(obj)
	self.obj = obj
end

function PracticeState:_delete()
	if self.effect then
		game.EffectMgr.instance:StopEffect(self.effect)
        self.effect = nil
	end
end

function PracticeState:StateEnter()
    self.wait_fire_gather_change = false

    local state_params = self.obj:GetStateParams()
    local duration = nil

    if #state_params ~= 0 then
        local info = state_params[1].param 
        local x, y = self.obj:GetLogicPosXY()
    
        duration = info.end_time - global.Time:GetServerTime()
        local tar_x = info.center_x ~= 0 and info.center_x or x
        local tar_y = info.center_y ~= 0 and info.center_y or y
    
        local logic_x, logic_y = self.obj:GetLogicPosXY()
        if tar_x and tar_y then
            local tar_x, tar_y = game.LogicToUnitPos(tar_x, tar_y)
            self.obj:SetDirForce(tar_x - self.obj.unit_pos.x, tar_y - self.obj.unit_pos.y)
        end
    end

    if self.obj:IsMainRole() then
        if duration and duration > 0 then
            if game.MainUICtrl.instance:IsViewOpen() then
                global.EventMgr:Fire(game.SceneEvent.GatherChange, true, config.words[4766], duration)
            else
                self.wait_fire_gather_change = true
            end
        end

        if game.MakeTeamCtrl.instance:HasTeam() and not game.MakeTeamCtrl.instance:IsLeader(game.RoleCtrl.instance:GetRoleId()) then
            game.MakeTeamCtrl.instance:DoFollowReset()
        end
        game.GameMsgCtrl.instance:PushMsg(config.words[4767])
    end

    self.obj:SetMountState(0)
    self.obj:PlayStateAnim()

    self.effect = game.EffectMgr.instance:CreateEffect(string.format("effect/scene/%s.ab", "dazuo"), 10)
    self.effect:SetLoop(true)
    self.effect:SetParent(self.obj:GetRoot())

    if duration then
        self.end_time = global.Time.now_time + duration
    end
    self.duration = duration
end

function PracticeState:StateUpdate(now_time, elapse_time)
    if self.wait_fire_gather_change and self.end_time then
        if game.MainUICtrl.instance:IsViewOpen() then
            local duration = self.end_time - now_time
            global.EventMgr:Fire(game.SceneEvent.GatherChange, true, config.words[4766], duration)
            self.wait_fire_gather_change = false
        end
    end
end

function PracticeState:StateQuit()
    if self.effect then
		game.EffectMgr.instance:StopEffect(self.effect)
        self.effect = nil
    end
    
    if self.obj:IsMainRole() then
        global.EventMgr:Fire(game.SceneEvent.GatherChange, false)
        game.GameMsgCtrl.instance:PushMsg(config.words[4768])
    end
end

return PracticeState