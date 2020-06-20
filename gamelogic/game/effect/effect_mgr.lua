local EffectMgr = Class()

local _table_insert = table.insert

function EffectMgr:_init()
    if EffectMgr.instance ~= nil then
        error("[EffectMgr] init twice")
    end
    EffectMgr.instance = self

    self.effect_id = 0
    self.effect_list = {}
    self.effect_type_map = {[1] = 0, [2] = 0, [3] = 0}
    self.next_unload_time = 0

    local effect_base_cls = require("game/effect/effect_base") 
    self.effect_base_pool = global.CollectPool.New(function()
        return effect_base_cls.New()
    end, function(item)
        item:DeleteMe()
    end, function(item)
        item:Reset()
    end)

    global.Runner:AddUpdateObj(self, 2)
end

function EffectMgr:_delete()
    global.Runner:RemoveUpdateObj(self)

    self:ClearAllEffect()

    EffectMgr.instance = nil
end

function EffectMgr:Update(now_time, elapse_time)
    if now_time > self.next_unload_time then
        self.next_unload_time = now_time + 0.08
        for k,v in pairs(self.effect_list) do
            if v:IsPlayEnd(now_time) then
                self:StopEffect(v)
                break
            end
        end
    end
end

function EffectMgr:CreateEffect(path, over_time)
    self.effect_id = self.effect_id + 1

    local eff = self.effect_base_pool:Create()
    eff:Init(self.effect_id, path, over_time)
    self.effect_list[self.effect_id] = eff

    return eff
end

function EffectMgr:StopEffect(eff)
    if not eff then
        return
    end

    self:StopEffectByID(eff._eff_id)
end

function EffectMgr:StopEffectByID(id)
    local eff = self.effect_list[id]
    if not eff then
        return
    end

    if eff.type then
        self.effect_type_map[eff.type] = self.effect_type_map[eff.type] - 1
    end

    self.effect_base_pool:Free(eff)
    self.effect_list[id] = nil
end

function EffectMgr:CreateObjEffect(path, obj_id, eff_type, over_time)
    local effect = self:CreateEffect(path, over_time)
    effect:BindObjID(obj_id)
    effect:SetType(eff_type)
    if eff_type then
        self.effect_type_map[eff_type] = self.effect_type_map[eff_type] + 1
    end
    return effect
end

function EffectMgr:GetEffectByID(eff_id)
    return self.effect_list[eff_id]
end

function EffectMgr:ClearAllEffect()
    for k,v in pairs(self.effect_list) do
        self.effect_base_pool:Free(v)
    end
    self.effect_list = nil

    self.effect_base_pool:DeleteMe()
    self.effect_base_pool = nil
end

function EffectMgr:ClearEffectByTag(tag)
    for k,v in pairs(self.effect_list) do
        if v.tag == tag then
            v:SetPlayEnd()
        end
    end
end

function EffectMgr:GetEffectNumByType(type)
    return self.effect_type_map[type] or 0
end

function EffectMgr:Debug()
    for k,v in pairs(self.effect_list) do
        print("DDD", v._eff_path, v.type, self:GetEffectNumByType(v.type))
    end
end

game.EffectMgr = EffectMgr

return EffectMgr
