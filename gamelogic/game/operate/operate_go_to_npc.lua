local OperateGoToNpc = Class(require("game/operate/operate_sequence"))

function OperateGoToNpc:_init()
    self.oper_type = game.OperateType.GoToNpc
end

function OperateGoToNpc:Init(obj, npc_id, callback)
    OperateGoToNpc.super.Init(self, obj)

    self.npc_id = npc_id
    self.oper_callback = callback
end

function OperateGoToNpc:Start()
    if not self.npc_id then 
        return false
    end

    --self:InsertToOperateSequence(game.OperateType.Stop, self.obj)
    
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
    self:InsertToOperateSequence(game.OperateType.Callback, self.oper_callback)

    return true
end

function OperateGoToNpc:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type, self.npc_id, self.oper_callback)
end

return OperateGoToNpc
