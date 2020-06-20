local BtNode = Class()

function BtNode:_init()
	self._name = "BtNode"

	-- debug
	-- local tick_func = self.Tick
	-- self.Tick = function(obj, now_time, elapse_time, black_board)
	-- 	print("Tick", obj._name)
	-- 	return tick_func(obj, now_time, elapse_time, black_board)
	-- end
end

function BtNode:SetName(name)
	self._name = name
end

function BtNode:GetName()
	return self._name
end

function BtNode:Init()
end

function BtNode:Reset()

end

function BtNode:Tick(now_time, elapse_time, black_board)
	
end

function BtNode:Clear()

end

bt.BtNode = BtNode
