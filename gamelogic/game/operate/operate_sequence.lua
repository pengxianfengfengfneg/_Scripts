local OperateSequence = Class(require("game/operate/operate_base"))

local table_insert = table.insert
local table_remove = table.remove

function OperateSequence:_init()
    self.oper_type = game.OperateType.Sequence
end

function OperateSequence:Init(obj)
    OperateSequence.super.Init(self, obj)
    self._operate_sequence = {}
    self._cur_operate = nil
end

function OperateSequence:Reset()
    if self._operate_sequence then
        for i,v in ipairs(self._operate_sequence) do
            self:FreeOperate(v)
        end
        self._operate_sequence = nil
    end
    self:ClearCurOperate()
    OperateSequence.super.Reset(self, obj)
end

function OperateSequence:Start()
    local main_role = game.Scene.instance:GetMainRole()
    if not main_role then
        return false
    end
    
    if #self._operate_sequence <= 0 then
        return false
    end
    return true
end

function OperateSequence:Update(now_time, elapse_time)
    if self._cur_operate then
        local ret,is_stop = self._cur_operate:Update(now_time, elapse_time)
        if ret == true then
            self:ClearCurOperate()
            return nil,is_stop
        elseif ret == false then
            self:ClearCurOperate()
            return false,is_stop
        end
    else
        self._cur_operate = self:PopOperate()
        if not self._cur_operate then
            return true
        end

        local ret,is_stop = self._cur_operate:Start()
        if ret then
            return nil,is_stop
        else 
            self:ClearCurOperate()
            return false,is_stop
        end
    end
end

function OperateSequence:InsertToOperateSequence(oper_type, ...)
    local oper = self:CreateOperate(oper_type, ...)
    table_insert(self._operate_sequence, oper)
end

function OperateSequence:SetObj(obj)
    self.obj = obj
    for _,v in ipairs(self._operate_sequence or {}) do
        v:SetObj(obj)
    end
end

function OperateSequence:GetOperateSequence()
    return self._operate_sequence
end

function OperateSequence:ClearCurOperate()
    if self._cur_operate then
        self:FreeOperate(self._cur_operate)
        self._cur_operate = nil
    end
end

function OperateSequence:PopOperate()
    local operate = self._operate_sequence[1]
    if operate then
        table_remove(self._operate_sequence,1)
    end
    return operate
end

function OperateSequence:GetCurOperate()
    return self._cur_operate
end

return OperateSequence
