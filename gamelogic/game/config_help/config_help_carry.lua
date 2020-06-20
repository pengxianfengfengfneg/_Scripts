local ConfigHelpCarry = {}

ConfigHelpCarry.GetCost = function(quality, lv)
	local cfg = config.carry_cost[quality]
	if cfg then
		for i=2,#cfg do
			if lv < cfg[i].level then
				return cfg[i-1].coin
			end
		end
	end
	return 0
end

config_help.ConfigHelpCarry = ConfigHelpCarry

return ConfigHelpCarry