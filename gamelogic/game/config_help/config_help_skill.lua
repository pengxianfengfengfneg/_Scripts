local ConfigHelpSkill = {}

local config_skill = config.skill or {}
local config_hero_effect = config.hero_effect or {}
local max_role_lv = #config.level

function ConfigHelpSkill.GetSkillCfg(skill_id, skill_lv, hero, legend, key)
    local hero = hero or 0

    if hero > 0 then
        local cfg = config_hero_effect[hero][skill_id]
        if cfg then
            local legend = legend or 0
            local legend_cfg = cfg[legend]

            local idx = #legend_cfg
            if skill_lv < idx then
                idx = skill_lv
            end

            local cfg = legend_cfg[idx]

            local val = cfg[key]
            if val then
            	return val
            end
        end
    end

    if skill_lv <= 0 then
        skill_lv = 1
    end

    return config_skill[skill_id][skill_lv][key]
end

local mt = {__index = function(t, k)
	local val = t.hero_cfg[k]
	if not val then
		val = t.skill_cfg[k]
	end

	return val
end}

local tmp = {}
setmetatable(tmp, mt)

local empty = {}

function ConfigHelpSkill.GetSkillInfo(skill_id, skill_lv, hero, legend)
	local hero = hero or 0

	tmp.hero_cfg = empty
    if hero > 0 then
        local cfg = config_hero_effect[hero][skill_id]
        if cfg then
            local legend = legend or 0
            local legend_cfg = cfg[legend]

            local idx = #legend_cfg
            if skill_lv < idx then
                idx = skill_lv
            end

            local cfg = legend_cfg[idx]

            tmp.hero_cfg = cfg
        end
    end

    if skill_lv <= 0 then
        skill_lv = 1
    end

    skill_lv = math.min(skill_lv, max_role_lv)

    tmp.skill_cfg = empty
    local cfg = config_skill[skill_id]
    if cfg then
        tmp.skill_cfg = cfg[skill_lv]
    end

    return tmp
end

config_help.ConfigHelpSkill = ConfigHelpSkill

return ConfigHelpSkill