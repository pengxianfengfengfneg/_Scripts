
local StateMachine = global.StateMachine or Class()

function StateMachine:_init()
	self.state_map = {}
	self.cur_state = nil
	self.cur_state_id = -1
end

function StateMachine:_delete()
	for k,v in pairs(self.state_map) do
		v:DeleteMe()
	end
	self.state_map = nil
end

function StateMachine:GetCurStateID()
	return self.cur_state_id
end

function StateMachine:AddState(id, state)
	if self.state_map[id] then
		error("StateMachine:AddState State Already Exist", id)
	end
	self.state_map[id] = state
end

function StateMachine:ChangeState(id, ...)
	local new_state = self.state_map[id]
	if new_state then
		if self.cur_state then
			self.cur_state:StateQuit(id)
		end

		self.cur_state_id = id
		self.cur_state = new_state
		new_state:StateEnter(...)
	else
		error("Invalid State", id)
	end

	return new_state
end

function StateMachine:Update(now_time, elapse_time)
	if self.cur_state then
		self.cur_state:StateUpdate(now_time, elapse_time)
	end
end

function StateMachine:GetState(id)
    return self.state_map[id]
end

function StateMachine:QuitCurState()
	if self.cur_state then
		self.cur_state:StateQuit(id)
	end
	self.cur_state = nil
end

global.StateMachine = StateMachine