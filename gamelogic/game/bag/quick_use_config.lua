local config = {
    -- 天灵丹
    [config.kill_mon_exp_info.item_id] = {
        check_func = function()
            return game.LakeExpCtrl.instance:GetKeepExpUseTimes() > 0
        end,
    },
}

return config