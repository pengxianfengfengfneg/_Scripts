local OperateHangMonster = Class(require("game/operate/operate_base"))

function OperateHangMonster:_init()
    self.oper_type = game.OperateType.HangMonster
end

function OperateHangMonster:_delete()
    self:UnRegisterAllEvents()
end

function OperateHangMonster:Reset()   
    self:ClearCurOperate()
    self:UnRegisterAllEvents()

    OperateHangMonster.super.Reset(self)
end

function OperateHangMonster:Init(obj, scene_id, monster_id, kill_num, x, y, uniq_id)
    OperateHangMonster.super.Init(self, obj)

    self.scene_id = scene_id
    self.monster_id = monster_id
    self.kill_num = kill_num or 999999

    self.x = x
    self.y = y
    self.uniq_id = uniq_id

    if self.kill_num <= 1000 then
        self:RegisterAllEvents()
    end

    self.hang_state = 0

    return true
end


function OperateHangMonster:RegisterAllEvents()
    local events = {
        {game.SceneEvent.MonsterDie, handler(self,self.OnMonsterDie)},
    }
    self.ev_list = {}
    for _,v in ipairs(events) do
        local ev = global.EventMgr:Bind(v[1],v[2])
        table.insert(self.ev_list, ev)
    end
end

function OperateHangMonster:UnRegisterAllEvents()
    for _,v in ipairs(self.ev_list or {}) do
        global.EventMgr:UnBind(v)
    end
    self.ev_list = nil
end

function OperateHangMonster:Start()
    local cur_scene_id = self.obj:GetScene():GetSceneID()
    if cur_scene_id ~= self.scene_id then
        self.cur_oper = self:CreateOperate(game.OperateType.ChangeScene, self.obj, self.scene_id)
        if not self.cur_oper:Start() then
            self:ClearCurOperate()
            return false
        end
        return true
    end

    self.target_x,self.target_y = 0,0

    if self.x and self.y then
        self.target_x,self.target_y = game.LogicToUnitPos(self.x,self.y)
    else
        local scene_cfg = self.obj:GetScene():GetSceneConfig()
        local monster_list = nil
        for _,v in pairs(scene_cfg.monster_list or {}) do
            for _,cv in pairs(v or {}) do
                if cv.monster_id == self.monster_id then
                    monster_list = v
                    break
                end
            end
        end

        if monster_list then
            local monster_num = 0
            local tx,ty = 0,0
            for _,v in pairs(monster_list) do
                tx = tx + v.x
                ty = ty + v.y
    
                monster_num = monster_num + 1
            end
    
            if monster_num > 0 then
                self.target_x,self.target_y = game.LogicToUnitPos(math.floor(tx/monster_num), math.floor(ty/monster_num))
            end
        end
    end

    self.obj:SetSearchFliterFunc(function(obj)
        if obj:GetObjType() == game.ObjType.Monster then
            if self.uniq_id then
                return (obj:GetUniqueId() == self.uniq_id)
            else
                return (obj:GetMonsterId() == self.monster_id)
            end
        end
        return false
    end)

    return true
end

function OperateHangMonster:Update(now_time, elapse_time)
    if self.kill_num <= 0 then
        return true
    end

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
        if self.cur_oper:GetOperateType() == game.OperateType.FindWay then
            local target = self.obj:SearchEnemy()
            if target then
                self:ClearCurOperate()
            end
        end
    end
end

function OperateHangMonster:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateHangMonster:ClearCurOperate()
    if self.cur_oper then
        self:FreeOperate(self.cur_oper)
        self.cur_oper = nil
    end
end

function OperateHangMonster:OnSaveOper()
    self.obj.scene:SetCrossOperate(self.oper_type, self.scene_id, self.monster_id, self.kill_num, self.x, self.y, self.uniq_id)
end

function OperateHangMonster:OnMonsterDie(monster_id)
    if self.monster_id == monster_id then
        self.kill_num = self.kill_num - 1
    end
end

function OperateHangMonster:GetHangState()
    return self.hang_state
end

return OperateHangMonster
