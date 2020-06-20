local ConfigHelpAttr = {}

local _et = {}

local config_combat_power = config.combat_power or {}
local config_combat_power_battle = config.combat_power_battle or {}
local config_combat_power_base = config.combat_power_base or {}
local config_attr_convert = config.attr_convert or {}

local attr_sort_list = {}
for k,v in ipairs(config_combat_power_battle) do
	table.insert(attr_sort_list, {seq=v.seq, id=k, sign=v.sign, word=v.attr_name})
end
table.sort(attr_sort_list, function(v1, v2)
	return v1.seq<v2.seq
end)

local attr_name_to_id = {}
local attr_name_to_word = {}

for k,v in pairs(config_combat_power_battle) do
	attr_name_to_id[v.sign] = k
	attr_name_to_word[v.sign] = v.attr_name
end

ConfigHelpAttr.GetAttrId = function(attr_name)
	return attr_name_to_id[attr_name]
end

ConfigHelpAttr.GetAttrWord = function(attr_name)
	return attr_name_to_word[attr_name]
end

ConfigHelpAttr.GetAttrSortList = function()
	return attr_sort_list
end

ConfigHelpAttr.GetAttrName = function(attr_type)
	local cfg = config_combat_power_battle[attr_type] or _et
	if attr_type > 100 then
		cfg = config_combat_power_base[attr_type-100] or _et
	end
	return cfg.name or ""
end

ConfigHelpAttr.CalcCombatPower = function(attr_map)
	local power = 0
	for k,v in pairs(attr_map) do
		if k > 100 then
			if config_combat_power_base[k - 100] then
				power = power + config_combat_power_base[k - 100].value * v
			end
		else
			if config_combat_power_battle[k] then
				power = power + config_combat_power_battle[k].value * v
			end
		end
	end
	return math.floor(power)
end

ConfigHelpAttr.CalcCombatPower2 = function(attr_map)
	local power = 0
	for k,v in pairs(attr_map) do
		if v.id > 100 then
			if config_combat_power_base[v.id - 100] then
				power = power + config_combat_power_base[v.id - 100].value * v.value
			end
		else
			if config_combat_power_battle[v.id] then
				power = power + config_combat_power_battle[v.id].value * v.value
			end
		end
	end
	return math.floor(power)
end

config_help.ConfigHelpAttr = ConfigHelpAttr

return ConfigHelpAttr