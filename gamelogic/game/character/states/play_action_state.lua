local PlayActionState = Class()

function PlayActionState:_init(obj)
    self.obj = obj
end

function PlayActionState:_delete()

end

function PlayActionState:StateEnter(anim, type, partner_id)
    self.type = type
    self.partner_id = partner_id
    self.obj:PlayAnim(anim)
    local duration = self.obj:GetAnimTime(anim)
    self.end_time = global.Time.now_time + duration
end

function PlayActionState:StateUpdate(now_time)
    if now_time > self.end_time and self.type ~= 2 then
        self.obj:DoIdle()
    end
end

function PlayActionState:StateQuit()
    if self.type == 2 then
        self.type = nil
        local partner = game.Scene.instance:GetObjByUniqID(self.partner_id)
        if partner and partner:GetCurStateID() == game.ObjState.PlayAction then
            partner:DoIdle()
        end
    end
end

return PlayActionState