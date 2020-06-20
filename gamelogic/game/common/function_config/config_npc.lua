local npc_cfg = {
    
}

-- 大师兄雕像
for _, id in pairs(config.career_battle_info.statue_list or game.EmptyTable) do
    npc_cfg[id] = {}
    npc_cfg[id].name_func = function()
        return game.CareerBattleCtrl.instance:GetStatueHeaderName(id)
    end
    npc_cfg[id].tips_func = function()
        return game.CareerBattleCtrl.instance:GetStatueHeaderFuncName(id)
    end
end

local et = {}
for k, v in pairs(config.npc) do
    local cfg = npc_cfg[k] or et
    v.name_func = cfg.name_func
    v.tips_func = cfg.tips_func
end