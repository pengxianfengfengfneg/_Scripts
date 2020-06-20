local config = {
    [1] = {
        index = 0,
        title = config.words[2737],
        content = config.words[2738],
        btn_cfg = {
            [1] = {
                name = config.words[100],
                func = function(view)
                    view:Close()
                end,
            },
        },
    },
    [2] = {
        index = 1,
        title = config.words[102],
        content = {
            text = config.words[2763],
            font_size = 30,
            horizontal_align = 1,
            vertical_align = 1,
        },
        btn_cfg = {
            [1] = {
                name = config.words[101],
                func = function(view)
                    view:Close()
                end,
            },
            [2] = {
                name = config.words[100],
                func = function(view)
                    game.GuildCtrl.instance:SendGuildLeave()
                    view:Close()
                end,
            },
        },
    },
    [3] = {
        index = 1,
        title = config.words[102],
        content = {
            text = config.words[4764],
            vertical_align = 1,
        },
        btn_cfg = {
            [1] = {
                name = config.words[101],
                func = function(view)
                    view:Close()
                end,
            },
            [2] = {
                name = config.words[100],
                func = function(view)
                    game.GuildCtrl.instance:SendGuildSendTeamInvite()
                    view:Close()
                end,
            },
        },
    },
    [4] = {
        index = 1,
        title = config.words[102],
        content = {
            text = string.format(config.words[4789], config.guild_metall.big_ratio),
            vertical_align = 1,
        },
        btn_cfg = {
            [1] = {
                name = config.words[101],
                func = function(view)
                    view:Close()
                end,
            },
            [2] = {
                name = config.words[100],
                func = function(view)
                    game.GuildCtrl.instance:SendGuildMetallTask(39)
                    view:Close()
                end,
            },
        },
    },
    [5] = {
        index = 1,
        title = config.words[102],
        btn_cfg = {
            [1] = {
                name = config.words[101],
                func = function(view)
                    view:Close()
                end,
            },
            [2] = {
                name = config.words[100],
                func = function(view, id, name, cost)
                    game.GuildCtrl.instance:SendGuildBless(id)
                    view:Close()
                end,
            },
        },
        init_func = function(view, id, name, cost)
            local content = {
                text = string.format(config.words[4790], cost, name),
                vertical_align = 1,
            }
            view:SetContentText(content)
        end,
    },
}

return config