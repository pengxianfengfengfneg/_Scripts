local metall_npc_id = config.guild_metall.npc_id

local config = {
    [metall_npc_id] = {
        content_func = function()
            local npc_cfg = config.npc[metall_npc_id]
            local lively = game.GuildCtrl.instance:GetMetallLively()
            return string.format(npc_cfg.talk_content, lively)
        end,
    }
}

return config