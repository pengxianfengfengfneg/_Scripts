local OperateClickNpc = Class(require("game/operate/operate_sequence"))

function OperateClickNpc:_init()
    self.oper_type = game.OperateType.ClickNpc
end

function OperateClickNpc:Init(obj, npc_id)
    OperateClickNpc.super.Init(self, obj)

    self.npc_id = npc_id
end

function OperateClickNpc:Start()
    if not self.npc_id then 
        return false
    end

    local npc = self.obj:GetScene():GetNpc(self.npc_id)
    if not npc then
        return false
    end

    local npc_x,npc_y = npc:GetUnitPosXY()
    local obj_x,obj_y = self.obj:GetUnitPosXY()

    local len_sq = (npc_x-obj_x)*(npc_x-obj_x) + (npc_y-obj_y)*(npc_y-obj_y)
    if len_sq > 3 then
        self:InsertToOperateSequence(game.OperateType.FindWay, self.obj, npc_x, npc_y, 2)   
    end

    local on_task_id = npc:GetOnTaskInfo()
    if on_task_id then
        self:InsertToOperateSequence(game.OperateType.Callback, function()
            npc:ShowTaskTalk()
        end)
    else
        self:InsertToOperateSequence(game.OperateType.Callback, function()
            npc:ShowTalk()
        end)
    end

    return true
end

return OperateClickNpc
