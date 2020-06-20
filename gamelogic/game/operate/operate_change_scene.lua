local OperateChangeScene = Class(require("game/operate/operate_base"))

local TaskChangeSceneConfig = {
    [10001] = {
        to = 10002,
        task_id = 1009,
    },
    [10002] = {
        to = 10000,
        task_id = 1018,
    }
}

function OperateChangeScene:_init()
    self.oper_type = game.OperateType.ChangeScene
end

function OperateChangeScene:Init(obj, scene_id, line_id, is_follow)
    OperateChangeScene.super.Init(self, obj)

    self.scene_id = scene_id    
    self.line_id = line_id or self.obj:GetScene():GetServerLine()
    self.is_follow = is_follow or false
end

function OperateChangeScene:Reset()
    self:ClearCurOperate()

    OperateChangeScene.super.Reset(self)
end

function OperateChangeScene:Start()
    self.change_scene_state = nil
    
    local cur_scene = self.obj:GetScene()
    local cur_scene_id = cur_scene:GetSceneID()
    local cur_line_id = cur_scene:GetServerLine()
    if cur_scene_id == self.scene_id and (cur_line_id==self.line_id) then
        return false,true
    end

    self.is_task_change_scene = false
    if self:CheckTaskChangeScene(cur_scene_id, self.scene_id) then
        return true
    end

    if not cur_scene:GetSceneLogic():CanChangeScene(self.scene_id, true) then
        return false,true
    end

    self.change_scene_state = self.obj:DoChagneScene(self.scene_id, nil, self.line_id, self.is_follow)    
    return true
end

function OperateChangeScene:Update(now_time, elapse_time)
    if self.is_task_change_scene then
        self:UpdateCurOperate(now_time, elapse_time)

        return
    end

    if not self.change_scene_state then
        return false,true
    end
end

function OperateChangeScene:CheckTaskChangeScene(cur_scene_id, to_scene_id)
    local cfg = TaskChangeSceneConfig[cur_scene_id]
    if cfg and cfg.to==to_scene_id then
        local task_info = game.TaskCtrl.instance:GetTaskInfoById(cfg.task_id)
        if task_info then
            local cur_oper = self.obj:GetOperateMgr():GetCurOperate()
            if cur_oper ~= self then
                local door_cfg = nil
                local scene_cfg = game.Scene.instance:GetSceneConfig()
                for _,v in pairs(scene_cfg.door_list or {}) do
                    if v.scene_id == to_scene_id then
                        door_cfg = v
                        break
                    end
                end

                if door_cfg then
                    if self.obj:CanRideMount(1) then
                        self.obj:SetMountState(1)
                    end

                    self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, door_cfg.pos_x, door_cfg.pos_y)
                    if not self.cur_oper:Start() then
                        self:ClearCurOperate()
                        return false
                    end
                    
                    self.is_task_change_scene = true
                else
                    return false
                end

                return true
            end
        end
    end
    return false
end

function OperateChangeScene:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret,is_stop = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()            
        end
        return is_stop
    end
end

function OperateChangeScene:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateChangeScene
