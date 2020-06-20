
local OperateStop = Class(require("game/operate/operate_base"))

function OperateStop:_init()
	self.oper_type = game.OperateType.Stop
end

function OperateStop:_delete()

end

function OperateStop:Init(obj, keep_stop)
    OperateStop.super.Init(self, obj)
	self.keep_stop = keep_stop or false
end

function OperateStop:Start()
	return true
end

function OperateStop:Update(now_time, elapse_time)
	if self.obj:CanDoIdle() then
		self.obj:DoIdle()
		if not self.keep_stop then
			return true
		end
	end
end

return OperateStop