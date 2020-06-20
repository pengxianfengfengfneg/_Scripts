local OperateTalk = Class(require("game/operate/operate_base"))


function OperateTalk:_init()
    self.oper_type = game.OperateType.Talk
end

function OperateTalk:Init(task_id, dialog_id, npc_id)
    self.task_id = task_id
    self.dialog_id = dialog_id 
    self.npc_id = npc_id
end

function OperateTalk:Start()
    if not self.dialog_id then
        return false
    end
    
    local npc = game.Scene.instance:GetNpc(self.npc_id)
    if npc then
        npc:ShowTaskTalk(self.task_id, self.dialog_id)
    else
        game.TaskCtrl.instance:OpenTaskDialogView(self.task_id, self.dialog_id, self.npc_id)
    end

    return true
end

function OperateTalk:Update(now_time, elapse_time)
    return true
end

return OperateTalk
