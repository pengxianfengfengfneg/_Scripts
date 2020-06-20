local OperateGoToScenePos = Class(require("game/operate/operate_sequence"))

function OperateGoToScenePos:_init()
    self.oper_type = game.OperateType.GoToScenePos
end

function OperateGoToScenePos:Init(obj, scene_id, x, y, callback, offset)
    OperateGoToScenePos.super.Init(self, obj)

    self.scene_id = scene_id
    self.target_x = x
    self.target_y = y
    self.oper_callback = callback
    self.offset = offset or 3
end

function OperateGoToScenePos:Start()
    --self:InsertToOperateSequence(game.OperateType.Stop, self.obj)
    
    local cur_scene = self.obj:GetScene()
    local cur_scene_id = cur_scene:GetSceneID()
    if cur_scene_id ~= self.scene_id then
        self:InsertToOperateSequence(game.OperateType.ChangeScene, self.obj, self.scene_id) 
    end

    self:InsertToOperateSequence(game.OperateType.FindWay, self.obj, self.target_x, self.target_y, self.offset)   
    self:InsertToOperateSequence(game.OperateType.Callback, self.oper_callback)

    return true
end

function OperateGoToScenePos:OnSaveOper()
    if self.obj.scene:GetSceneID() ~= self.scene_id then
        self.obj.scene:SetCrossOperate(self.oper_type, self.scene_id, self.target_x, self.target_y, self.oper_callback, self.offset)
    end
end

return OperateGoToScenePos
