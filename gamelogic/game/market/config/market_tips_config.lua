local config = {
    [1] = {
        index = 1,
        title = config.words[102],
        content = {
            text = "",
            font_size = 28,
            horizontal_align = 0,
            vertical_align = 1,
        },
        btn_cfg = {
            [1] = {
                name = config.words[100],
                func = function(view)
                    game.MarketCtrl.instance:SendMarketResale(0)
                    view:Close()
                end,
            },
            [2] = {
                name = config.words[101],
                func = function(view)
                    view:Close()
                end,
            },
        },
        init_func = function(view)
            view.txt_content:SetText(game.MarketCtrl.instance:GetResaleTipsStr())
        end,
    },
}

return config