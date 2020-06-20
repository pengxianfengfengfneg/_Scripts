local titles = {
    -- 帮会称号
    [3000] = {
        name_func = function()
            return game.GuildCtrl.instance:GetGuildName()
        end,
    },
    -- 结拜称号
    [7000] = {
        name_func = function()
            return game.SwornCtrl.instance:GetTitle()
        end,
        quality_func = function()
            return game.SwornCtrl.instance:GetQuality()
        end,
    },
    -- 普通弟子
    [7004] = {
        name_func = function()
            local mentor_name = game.MentorCtrl.instance:GetMentorName()
            return string.format(config.words[6438], mentor_name)
        end,
    },
    -- 亲传弟子
    [7005] = {
        name_func = function()
            local mentor_name = game.MentorCtrl.instance:GetMentorName()
            return string.format(config.words[6439], mentor_name)
        end,
    },
    -- 结婚称号
    [8001] = {
        name_func = function()
            local marry_info = game.MarryCtrl.instance:GetMarryInfo()
			local gender = game.Scene.instance:GetMainRoleGender()
			local format_list = {config.words[2627], config.words[2628]}
            return string.format(format_list[gender], marry_info.mate_name)
        end,
    },
}

for k, v in pairs(config.title) do
    local cfg = titles[k]
    if cfg then
        v.name_func = cfg.name_func
        v.quality_func = cfg.quality_func
    end
end

return config