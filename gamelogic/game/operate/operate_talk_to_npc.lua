local OperateTalkToNpc = Class(require("game/operate/operate_sequence"))

function OperateTalkToNpc:_init()
    self.oper_type = game.OperateType.TalkToNpc
end

function OperateTalkToNpc:Init(obj, task_id, dialog_id)
    OperateTalkToNpc.super.Init(self, obj)

    self.task_id = task_id
    self.dialog_id = dialog_id

    local dialog_cfg = config.task_dialog[dialog_id] or {{}}
    self.npc_id = dialog_cfg[1].npc_id
end

function OperateTalkToNpc:Start()
    if not self.npc_id then 
        return false
    end

    local pos_x = 0
    local pos_y = 0

    local cur_scene = game.Scene.instance
    local npc = cur_scene:GetNpc(self.npc_id)
    if npc then
        pos_x,pos_y = npc:GetUnitPosXY()
    else
        local npc_cfg = config.npc[self.npc_id]

        self:InsertToOperateSequence(game.OperateType.ChangeScene, self.obj, npc_cfg.scene) 

        local scene_id = npc_cfg.scene
        local scene_config_path = string.format("config/editor/scene/%d", scene_id)
        local scene_config = require(scene_config_path)
        package.loaded[scene_config_path] = nil

        local npc_list = scene_config.npc_list or game.EmptyTable
        for _,v in ipairs(npc_list) do
            if v.npc_id == self.npc_id then
                pos_x = v.x
                pos_y = v.y
                break
            end
        end
    end

    self:InsertToOperateSequence(game.OperateType.FindWay, self.obj, pos_x, pos_y, 2) 
    self:InsertToOperateSequence(game.OperateType.Talk, self.task_id, self.dialog_id, self.npc_id)
    
    return true
end

function OperateTalkToNpc:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type, self.task_id, self.dialog_id)
end

return OperateTalkToNpc
