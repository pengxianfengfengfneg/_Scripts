local OperateHangTaskCatchPet = Class(require("game/operate/operate_base"))

function OperateHangTaskCatchPet:_init()
    self.oper_type = game.OperateType.HangTaskCatchPet
end

function OperateHangTaskCatchPet:Reset()
    
    self:ClearCurOperate()
    OperateHangTaskCatchPet.super.Reset(self)
end

function OperateHangTaskCatchPet:Init(obj, task_id, gather_id, monster_id, scene_id)
    OperateHangTaskCatchPet.super.Init(self, obj)

    self.task_id = task_id
    self.gather_id = gather_id
    self.monster_id = monster_id
    self.scene_id = scene_id

    return true
end

function OperateHangTaskCatchPet:Start()
    self.task_ctrl = game.TaskCtrl.instance

    local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
    if not task_info then
        return false
    end

    local info = task_info.masks[1]
    if info then
        if info.current>=info.total then
            return false
        end
    end

    if not self.obj:GetScene():GetSceneLogic():CanDoGather() then
        return false,true
    end

    local cur_scene_id = self.obj:GetScene():GetSceneID()
    if cur_scene_id ~= self.scene_id then
        self.cur_oper = self:CreateOperate(game.OperateType.ChangeScene, self.obj, self.scene_id)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
        return true
    end

    return true
end

function OperateHangTaskCatchPet:Update(now_time, elapse_time)
    if not self.obj:GetScene():GetSceneLogic():CanDoGather() then
        self:ClearCurOperate()
        return false,true
    end

    self:UpdateCurOperate(now_time, elapse_time)

    if not self.cur_oper then
        self.cur_oper = self:CreateOperate(game.OperateType.HangCatchPet, self.obj, self.gather_id, self.monster_id)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
    else
        local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
        if task_info then
            local info = task_info.masks[1]
            if info then
                if info.current >= info.total then
                    return false
                end
            end
        else
            return false
        end
    end
end

function OperateHangTaskCatchPet:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskCatchPet:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangTaskCatchPet
