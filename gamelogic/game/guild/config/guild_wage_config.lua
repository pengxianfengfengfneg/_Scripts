local WageMap = {
    Meal = 1001,
    Wine = 1002,
    BattleField = 1003,
    Defend = 1004,
    Banquet = 1005,
    GuildTask = 1006,
    Metall = 1007,
    Practice = 1008,
    Carry = 1009,
}

local config = {
    [WageMap.Meal] = function()

    end,
    [WageMap.Wine] = function()
        game.GuildCtrl.instance:TryJoinInGuildWine()
        game.GuildCtrl.instance:CloseView()
    end,
    [WageMap.BattleField] = function()
        game.GuildCtrl.instance:OpenView(5, 2)
        game.GuildCtrl.instance:CloseGuildWageView()
    end,
    [WageMap.Defend] = function()
        local npc_id = 2008
        game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
        game.GuildCtrl.instance:CloseView()
    end,
    [WageMap.Banquet] = function()
        game.GuildCtrl.instance:OpenGuildBanquetView()
    end,
    [WageMap.GuildTask] = function()
        game.GuildTaskCtrl.instance:OpenView()
    end,
    [WageMap.Metall] = function()
        local npc_id = config.activity_hall_ex[1014].npc_id
        game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
        game.GuildCtrl.instance:CloseView()
    end,
    [WageMap.Practice] = function()
        game.GuildCtrl.instance:TryJoinInPractice()
        game.GuildCtrl.instance:CloseView()
    end,
    [WageMap.Carry] = function()
        local npc_id = config.carry_common.carry_npc
        game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
        game.GuildCtrl.instance:CloseView()
    end,
}

return config