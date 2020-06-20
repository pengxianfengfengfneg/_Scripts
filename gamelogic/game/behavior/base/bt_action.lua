local BtAction = Class(bt.BtNode)

local BtActionState = {
	Ready = 1,
	Running = 2,
}

function BtAction:_init()
	self._name = "BtAction"
	self._state = BtActionState.Ready
end

function BtAction:Reset()
	self._state = BtActionState.Ready
end

function BtAction:Tick(now_time, elapse_time, black_board)
	if self._state == BtActionState.Ready then
		self:OnEnter(now_time, elapse_time, black_board)
		self._state = BtActionState.Running
	end
	if self._state == BtActionState.Running then
		local ret = self:OnUpdate(now_time, elapse_time, black_board)
		if ret ~= nil then
			self:OnExit(now_time, elapse_time, black_board)
			self._state = BtActionState.Ready
		end
		return ret
	end
end

function BtAction:Clear()
	if self._state ~= BtActionState.Ready then
		self:OnExit()
		self._state = BtActionState.Ready
	end
end

function BtAction:OnEnter(now_time, elapse_time, black_board)

end

function BtAction:OnUpdate(now_time, elapse_time, black_board)

end

function BtAction:OnExit(now_time, elapse_time, black_board)
	
end

bt.BtAction = BtAction
