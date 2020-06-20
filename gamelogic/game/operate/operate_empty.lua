local OperateEmpty = Class(require("game/operate/operate_base"))

function OperateEmpty:_init()
	self.oper_type = game.OperateType.Empty
end

function OperateEmpty:Start()
	
	return true
end

function OperateEmpty:Update(now_time, elapse_time)
	return true,true
end

return OperateEmpty
