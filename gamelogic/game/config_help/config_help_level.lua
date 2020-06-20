local ConfigHelpLevel = {}

local _pioneer_lv_list = nil
local _init_pioneer_lv_list = function()
	if not _pioneer_lv_list then
		_pioneer_lv_list = {}

		local sort_func = function(a, b)
			return a.diff < b.diff
		end

		local pioneer_lv_map = {}
		for k,v in pairs(config.pioneer_lv_add) do
			local lv_map = pioneer_lv_map[k]
			if not lv_map then
				lv_map = {}
				pioneer_lv_map[k] = lv_map
			end

			for k1,v1 in pairs(v) do
				table.insert(lv_map, {diff = k1, ratio = v1.ratio})
			end

			table.sort(lv_map, sort_func)
		end

		for k,v in pairs(pioneer_lv_map) do
			table.insert(_pioneer_lv_list, {lv = k, info = v})
		end
		table.sort(_pioneer_lv_list, function(a, b)
			return a.lv < b.lv
		end)
	end
end

local _wolrd_lv_list = nil
local _init_wolrd_lv_list = function()
	if not _wolrd_lv_list then
		_wolrd_lv_list = {}

		local sort_func = function(a, b)
			return a.diff < b.diff
		end

		for k,v in pairs(config.world_lv_decay) do
			table.insert(_wolrd_lv_list, {diff = k, ratio = v.ratio})
		end
		table.sort(_wolrd_lv_list, sort_func)
	end
end

ConfigHelpLevel.GetPioneerLvRatio = function(lv, pioneer_lv)
	_init_pioneer_lv_list()

	local ls
	for i,v in ipairs(_pioneer_lv_list) do
		if lv <= v.lv then
			ls = v.info
			break
		end
	end

	if ls then
		local ratio = 0
		local delta_lv = pioneer_lv - lv
		for i,v in ipairs(ls) do
			if delta_lv >= v.diff then
				ratio = v.ratio
			else
				break
			end
		end
		return ratio
	end

	return 0
end

ConfigHelpLevel.GetWorldLvRatio = function(lv, world_lv)
	_init_wolrd_lv_list()

	local delta_lv = lv - world_lv
	if delta_lv < 0 then
		return 0
	end
	
	local ratio = 0
	for k,v in ipairs(_wolrd_lv_list) do
		if delta_lv <= v.diff then
			ratio = v.ratio
			break
		end
	end

	return ratio
end

ConfigHelpLevel.GetNextWorldLvDay = function(cur_day)
	local next_day = 9999
	local next_lv = 0
	for k,v in pairs(config.world_lv) do
		if k > cur_day and k < next_day then
			next_day = k
			next_lv = v.level
		end
	end
	return next_day, next_lv
end

ConfigHelpLevel.HasPioneerLvAdd = function(lv, pioneer_lv)
	local cfg_lv
	local cfg_diff = 999
	local cur_diff = pioneer_lv - lv
	for k,v in pairs(config.pioneer_lv) do
		if lv <= k and (not cfg_lv or k < cfg_lv) then
			cfg_lv = k
			cfg_diff = v.diff
		end
	end

	if cur_diff >= cfg_diff then
		return true
	else
		return false
	end
end

config_help.ConfigHelpLevel = ConfigHelpLevel

return ConfigHelpLevel