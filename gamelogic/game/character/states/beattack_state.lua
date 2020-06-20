local BeattackState = Class()

function BeattackState:_init(obj)
	self.obj = obj
end

function BeattackState:_delete()
end

function BeattackState:StateEnter(attacker, skill_id, skill_lv)
    if self.obj:IsClientObj() then
        self.obj:SetMountState(0)
    end

	self.obj:PlayStateAnim()
    self.end_time = global.Time.now_time + self.obj:GetAnimTime(game.ObjAnimName.Beattack)
end

function BeattackState:StateUpdate(now_time, elapse_time)
    if now_time > self.end_time then
        self.obj:DoIdle()
    end
end

function BeattackState:StateQuit()
end

return BeattackState
