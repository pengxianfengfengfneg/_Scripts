local BtCondition = Class(bt.BtNode)

function BtCondition:_init()
	self._name = "BtCondition"
end

function BtCondition:Tick(now_time, elapse_time, black_board)
	return self:Check(now_time, elapse_time, black_board)	
end

function BtCondition:Check(now_time, elapse_time, black_board)
	return true
end

bt.BtCondition = BtCondition


