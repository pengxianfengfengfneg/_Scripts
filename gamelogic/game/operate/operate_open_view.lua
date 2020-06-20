local OperateOpenView = Class(require("game/operate/operate_base"))

function OperateOpenView:_init()
    self.oper_type = game.OperateType.OpenView
    
end

function OperateOpenView:Reset()
	self.params = nil

	OperateOpenView.super.Reset(self)
end

function OperateOpenView:Init(obj, ctrl_name, func_name, ...)
    OperateOpenView.super.Init(self, obj)

    self.ctrl_name = ctrl_name
    self.func_name = func_name

    self.params = table.pack(...)
end

function OperateOpenView:Start()
    local ctrl = game[self.ctrl_name]
    if not ctrl then
    	return false
    end

    local func = ctrl.instance[self.func_name]
    if not func then
    	return false
    end

    func(ctrl.instance, table.unpack(self.params))

    return true
end

function OperateOpenView:Update(now_time, elapse_time)
    return true
end

return OperateOpenView
