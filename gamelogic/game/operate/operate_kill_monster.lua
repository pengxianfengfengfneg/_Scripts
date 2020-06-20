local OperateKillMonster = Class(require("game/operate/operate_hang_attack"))

function OperateKillMonster:_init()
    self.oper_type = game.OperateType.KillMonster
end

function OperateKillMonster:_delete()
    self:UnRegisterAllEvents()
end

function OperateKillMonster:Init(obj, monster_id, kill_num)
    OperateKillMonster.super.Init(self, obj)

    self.monster_id = monster_id
    self.kill_num = kill_num or 0

    self:RegisterAllEvents()
end

function OperateKillMonster:RegisterAllEvents()
    local events = {
        {game.SceneEvent.MonsterDie, handler(self,self.OnMonsterDie)},
    }
    self.ev_list = {}
    for _,v in ipairs(events) do
        local ev = global.EventMgr:Bind(v[1],v[2])
        table.insert(self.ev_list, ev)
    end
end

function OperateKillMonster:UnRegisterAllEvents()
    for _,v in ipairs(self.ev_list or {}) do
        global.EventMgr:UnBind(v)
    end
    self.ev_list = nil
end

function OperateKillMonster:Reset()
    self.obj:SetSearchFliterFunc(nil)
    self:UnRegisterAllEvents()

    OperateKillMonster.super.Reset(self)
end

function OperateKillMonster:Start()
    local ret = OperateKillMonster.super.Start(self)
    if not ret then
        return false
    end

    self.obj:SetSearchFliterFunc(function(obj)
        if obj:GetObjType() == game.ObjType.Monster then
            return (obj:GetMonsterId() == self.monster_id)
        end
        return false
    end)
    return true
end

function OperateKillMonster:Update(now_time, elapse_time)
    if self.kill_num <= 0 then
        return true
    end

    return OperateKillMonster.super.Update(self, now_time, elapse_time)
end

function OperateKillMonster:UpdateCurOperate(now_time, elapse_time)
    if self.cur_oper then
        local ret = self.cur_oper:Update(now_time, elapse_time)
        if ret ~= nil then
            self:ClearCurOperate()
        end
    end
end

function OperateKillMonster:OnMonsterDie(monster_id)
    if self.monster_id == monster_id then
        self.kill_num = self.kill_num - 1
    end
end

return OperateKillMonster
