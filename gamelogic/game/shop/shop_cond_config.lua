local config = {
    [1] = {
        --挑战副本次数 {1, 副本类型, 次数}
        check_func = function(cond)
            return game.CarbonCtrl.instance:CheckChanTimesByType(cond[2], cond[3])
        end,
        desc_func = function(cond)
            return string.format(config.words[1607], config.dungeon_type[cond[2]].name, cond[3])
        end,
    },
    [2] = {
        --挑战副本波数 {2, 副本ID, 关数，波数}
        check_func = function(cond)
            return game.CarbonCtrl.instance:CheckLvWave(cond[2], cond[3], cond[4])
        end,
        desc_func = function(cond)
            return string.format(config.words[1608], config.dungeon[cond[2]].name, cond[3], cond[4])
        end,
    },
    [3] = { 
        --帮会达到X级  {3, 帮会等级}
        check_func = function(cond)
            return game.GuildCtrl.instance:GetGuildLevel() >= cond[2]
        end,
        desc_func = function(cond)
            return string.format(config.words[1612], cond[2])
        end,
    },
    [4] = {
        --竞技场排名N名内 {4,排名}
        check_func = function(cond)
            return true
        end,
        desc_func = function(cond)
            return string.format(config.words[1611], cond[2])
        end,
    },
    [5] = {
        --挑战夺宝奇兵次数 {5,次数}
        check_func = function(cond)
            return true
        end,
        desc_func = function(cond)
            return string.format(config.words[1610], cond[2])
        end,
    },
    [6] = {
        --藏宝阁等级 {6, 等级}
        check_func = function(cond)
            return game.GuildCtrl.instance:GetPavilionBuildLevel() >= cond[2]
        end,
        desc_func = function(cond)
            return string.format(config.words[1615], cond[2])
        end,
    },
    [7] = {
        --累计货币 {7, 金钱类型，金钱}
        check_func = function(cond)
            return game.BagCtrl.instance:GetHistoryMoneyByType(cond[2]) >= cond[3]
        end,
        desc_func = function(cond)
            return string.format(config.words[1617], cond[3], config.money_type[cond[2]].name)
        end,
    },
    [9] = {
        --师徒学业成绩 {9，学业成绩}
        check_func = function(cond, role_id)
            return game.MentorCtrl.instance:GetPrenticeMark(role_id) >= cond[2]
        end,
        desc_func = function(cond)
            return ""
        end,
    },
}

local default = {
    check_func = function() return true end,
    desc_func = function() return "" end,
}

setmetatable(config, {
    __index = default
})

return config
