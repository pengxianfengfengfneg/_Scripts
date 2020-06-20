local OperateGoToMonsterPos = Class(require("game/operate/operate_sequence"))

function OperateGoToMonsterPos:_init()
    self.oper_type = game.OperateType.GoToMonsterPos
end

function OperateGoToMonsterPos:Init(obj, scene_id, monster_id)
    OperateGoToMonsterPos.super.Init(self, obj)

    self.scene_id = scene_id
    self.monster_id = monster_id
end

function OperateGoToMonsterPos:Start()
    --self:InsertToOperateSequence(game.OperateType.Stop, self.obj)
    
    local cur_scene = self.obj:GetScene()
    local cur_scene_id = cur_scene:GetSceneID()
    if cur_scene_id ~= self.scene_id then
        self:InsertToOperateSequence(game.OperateType.ChangeScene, self.obj, self.scene_id) 
    end

    local scene_config_path = string.format("config/editor/scene/%d", self.scene_id)
    local scene_config = require(scene_config_path)
    package.loaded[scene_config_path] = nil

    local monster_list = {}
    for _,v in pairs(scene_config.monster_list or {}) do
        for _,cv in ipairs(v) do
            if cv.monster_id == self.monster_id then
                table.insert(monster_list, cv)
            end
        end
    end

    if #monster_list <= 0 then
        return false
    end

    local random_target = monster_list[math.random(1,#monster_list)]
    local target_x,target_y = game.LogicToUnitPos(random_target.x, random_target.y)
    local main_role = game.Scene.instance:GetMainRole()

    self:InsertToOperateSequence(game.OperateType.FindWay, main_role, target_x, target_y, 3)

    return true
end

function OperateGoToMonsterPos:OnSaveOper()
    if self.obj.scene:GetSceneID() ~= self.scene_id then
        self.obj.scene:SetCrossOperate(self.oper_type, self.scene_id, self.monster_id)
    end
end

return OperateGoToMonsterPos
