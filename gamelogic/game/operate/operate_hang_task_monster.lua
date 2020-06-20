local OperateHangTaskMonster = Class(require("game/operate/operate_base"))

local pDistanceSQ = cc.pDistanceSQ

function OperateHangTaskMonster:_init()
    self.oper_type = game.OperateType.HangTaskMonster
end

function OperateHangTaskMonster:Reset()   
    self:ClearCurOperate()
    OperateHangTaskMonster.super.Reset(self)
end

function OperateHangTaskMonster:Init(obj, task_id, scene_id, monster_id, kill_num, x, y)
    OperateHangTaskMonster.super.Init(self, obj)

    self.task_id = task_id

    self.scene_id = scene_id
    self.monster_id = monster_id
    self.kill_num = kill_num or 0

    self.x = x
    self.y = y

    return true
end

function OperateHangTaskMonster:Start()
    self.task_ctrl = game.TaskCtrl.instance

    local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
    if not task_info then
        return false
    end

    local ret = false
    local info = task_info.masks[1]
    if info then
        ret = (info.current<info.total)
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

    local scene_cfg = self.obj:GetScene():GetSceneConfig()
    local monster_list = nil

    if self.monster_id <= 0 then
        local len_sq = 1000000
        local unit_pos = self.obj:GetUnitPos()
        for _,v in pairs(scene_cfg.monster_list or {}) do
            for _,cv in pairs(v or {}) do
                local len = pDistanceSQ(cv, unit_pos)
                if len < len_sq then
                    len_sq = len
                    monster_list = v
                    break
                end
            end
        end
    else
        for _,v in pairs(scene_cfg.monster_list or {}) do
            for _,cv in pairs(v or {}) do
                if cv.monster_id == self.monster_id then
                    monster_list = v
                    break
                end
            end
        end
    end

    self.target_x,self.target_y = 0,0
    if monster_list then
        local monster_num = 0
        local tx,ty = 0,0
        for _,v in pairs(monster_list) do
            tx = tx + v.x
            ty = ty + v.y

            monster_num = monster_num + 1

            self.monster_id = v.monster_id
        end

        if monster_num > 0 then
            self.target_x,self.target_y = game.LogicToUnitPos(math.floor(tx/monster_num), math.floor(ty/monster_num))
        end
    end

    self.obj:SetSearchFliterFunc(function(obj)
        if obj:GetObjType() == game.ObjType.Monster then
            return (obj:GetMonsterId() == self.monster_id)
        end
        return false
    end)

    return ret
end

function OperateHangTaskMonster:Update(now_time, elapse_time)
    self:UpdateCurOperate(now_time, elapse_time)

    if not self.cur_oper then
        -- 寻找怪物
        local target = self.obj:SearchEnemy()
        if target then
            -- 挂机
            self.cur_oper = self:CreateOperate(game.OperateType.HangStay, self.obj)
        else
            -- 寻路
            self.cur_oper = self:CreateOperate(game.OperateType.FindWay, self.obj, self.target_x, self.target_y)
        end
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
        self.cur_oper:OnStart()
    else
        local task_info = self.task_ctrl:GetTaskInfoById(self.task_id)
        if task_info then
            local info = task_info.masks[1]
            if info then
                if info.current >= info.total then
                    return false
                else
                    if self.cur_oper:GetOperateType() == game.OperateType.FindWay then
                        local target = self.obj:SearchEnemy()
                        if target then
                            self:ClearCurOperate()
                        end
                    end
                end
            end
        else
            return false
        end
    end
end

function OperateHangTaskMonster:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangTaskMonster:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

return OperateHangTaskMonster
