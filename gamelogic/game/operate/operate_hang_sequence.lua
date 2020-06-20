local OperateHangSequence = Class(require("game/operate/operate_sequence"))

function OperateHangSequence:_init()
	self.oper_type = game.OperateType.HangSequence
end

function OperateHangSequence:Reset()
    self.operate_list = nil
    OperateHangSequence.super.Reset(self)
end

function OperateHangSequence:Init(obj, operate_list)
	OperateHangSequence.super.Init(obj, self)

	self.operate_list = operate_list
end

function OperateHangSequence:Start()
	if not self.operate_list then
		return false
	end

	self._operate_sequence = self.operate_list

	return true
end

return OperateHangSequence
