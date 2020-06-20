local DieState = Class()

function DieState:_init(obj)
	self.obj = obj
	if obj.obj_type == game.ObjType.Role then
		self.is_role = true
	end
	if obj.obj_type == game.ObjType.Monster then
		self.is_monster = true
	end
end

function DieState:_delete()
end

function DieState:StateEnter()
	self.obj:UnRegisterAoiWatcher()
	self.obj:UnRegisterAoiObj()

	self.obj:SetMountState(0)
	self.obj:PlayStateAnim()
	self.end_time = global.Time.now_time + self.obj:GetAnimTime(game.ObjAnimName.Die)
end

function DieState:StateUpdate(now_time, elapse_time)
	if self.is_monster then
		if self.end_time and now_time > self.end_time then
			self.obj.real_dead = true
	   		self.obj.scene:DeleteObj(self.obj.obj_id, true)
	   		self.end_time = nil
		end
	end
end

function DieState:StateQuit()

end

return DieState
