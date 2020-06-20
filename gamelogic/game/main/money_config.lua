local config_money_type = config.money_type

local MoneyConfig = {
    [game.MoneyType.Copper] = {
        is_add = true,
        click_func = function()
            game.MainUICtrl.instance:OpenMoneyExchangeView(3)
        end,
    },
    [game.MoneyType.Gold] = {
        is_add = false,
        click_func = function()
            game.RechargeCtrl.instance:OpenView()
        end,
        click_left = function(item)
            local gold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.Gold)
            local backup_gold = game.BagCtrl.instance:GetMoneyByType(game.MoneyType.BackupGold)

            local gold_cfg = config.money_type[game.MoneyType.Gold]
            local backup_gold_cfg = config.money_type[game.MoneyType.BackupGold]

            local str_txt = string.format(config.words[125], gold_cfg.name, gold, backup_gold_cfg.name, backup_gold)
            item:ShowTips(str_txt)
        end,
    },
    [game.MoneyType.BindGold] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.Friend] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.GuildCont] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.Prestige] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.GuildGold] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.ForgeScore] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.Essence] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.XiaYi] = {
        is_add = false,
        click_func = function()

        end,
    },
    [game.MoneyType.Silver] = {
        is_add = true,
        click_func = function()
            game.MainUICtrl.instance:OpenMoneyExchangeView(1)
        end,
    },
}

for k,v in pairs(MoneyConfig) do
    local cfg = config_money_type[k]
    v.icon = cfg.icon or ""
end

return MoneyConfig