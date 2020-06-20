local check_open_func = function()
    return not game.GuildCtrl.instance:IsDenfState()
end

local not_use_func = function()
    game.GameMsgCtrl.instance:PushMsg(config.words[4733])
end

local config = {
    [1] = {
        func = function(view)
            if check_open_func() then
                local open_lv = config.sys_config.guild_practice_open_lv.value
                local role_lv = game.RoleCtrl.instance:GetRoleLevel()
                if role_lv >= open_lv then
                    game.SkillCtrl.instance:OpenView(2)
                else
                    game.GameMsgCtrl.instance:PushMsg(open_lv .. config.words[2101])
                end
            else
                not_use_func()
            end
        end,
    },
    [2] = {
        func = function(view)
            if check_open_func() then
                game.GuildCtrl.instance:OpenGuildBanquetView()
            else
                not_use_func()
            end
        end,
    },
    [3] = {
        func = function(view)
            if check_open_func() then
                game.GuildCtrl.instance:OpenGuildBonusView()
            else
                not_use_func()
            end
        end,
    },
    [4] = {
        func = function(view)
            if check_open_func() then
                game.GuildCtrl.instance:OpenGuildBlessView()
            else
                not_use_func()
            end
        end,
    },
    [5] = {
        func = function(view)
            if check_open_func() then
                game.GuildCtrl.instance:OpenGuildWageView()
            else
                not_use_func()
            end
        end,
    },
    [6] = {
        func = function(view)
            if check_open_func() then
                game.GuildCtrl.instance:OpenGuildResearchView()
            else
                not_use_func()
            end
        end,
    },
    [7] = {
        func = function(view)
            game.ShopCtrl.instance:OpenView(1115)
        end,
    }
}

return config