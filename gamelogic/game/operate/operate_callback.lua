local OperateCallback = Class(require("game/operate/operate_base"))

function OperateCallback:_init()
    self.oper_type = game.OperateType.Callback
    
end

function OperateCallback:Init(callback)
    OperateCallback.super.Init(self)

    self.callback_func = callback
end

function OperateCallback:_delete()
end

function OperateCallback:Start()
    if self.callback_func then
        self.callback_func()
    end

    return true
end

function OperateCallback:Update(now_time, elapse_time)
    return true
end

return OperateCallback
