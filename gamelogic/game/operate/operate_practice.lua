local OperatePractice = Class(require("game/operate/operate_base"))

function OperatePractice:_init()
	self.oper_type = game.OperateType.Practice
end

function OperatePractice:_delete()

end

function OperatePractice:Init(obj)
    OperatePractice.super.Init(self, obj)
end

function OperatePractice:Start()
	if self.obj:GetCurStateID() == game.ObjState.Practice then
        return false
    end

    self.obj:DoPractice()
	return true
end

function OperatePractice:Update(now_time, elapse_time)
    if self.obj:GetCurStateID() ~= game.ObjState.Practice then
        return true
    end
end

return OperatePractice