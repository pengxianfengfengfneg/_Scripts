local IdleState = Class()

function IdleState:_init(obj)
	self.obj = obj
end

function IdleState:_delete()

end

function IdleState:StateEnter(is_empty)
	self.is_empty = is_empty

	if not self.is_empty then
		self.is_move_attack = self.obj:IsMoveAttack()
		if not self.is_move_attack then
			self.obj:PlayStateAnim()
		end
	end
end

function IdleState:StateUpdate(now_time, elapse_time)
	if self.is_empty then
		return
	end

	if self.is_move_attack then
		if not self.obj:IsMoveAttack() then
			self.obj:PlayStateAnim()
			self.is_move_attack = false
		end
	end
end

function IdleState:StateQuit()
	
end

return IdleState