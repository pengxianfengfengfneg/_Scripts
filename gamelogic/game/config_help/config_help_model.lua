local ConfigHelpModel = {}

local _config_fashion_color = config.fashion_color
local _career_init = config.career_init
local _config_weapon_avatar = config.weapon_avatar 

ConfigHelpModel.GetBodyID = function(career, fashion_id)
	if not fashion_id or fashion_id == 0 then
		local fashion = _career_init[career].fashion
		if _config_fashion_color[fashion] then
			return _config_fashion_color[fashion][career][1].fashion_id
		end
	else
		local fashion, color = game.FashionCtrl.instance:ParseFashionValue(fashion_id)
		if _config_fashion_color[fashion] then
			return _config_fashion_color[fashion][career][color].fashion_id
		end
	end
end

ConfigHelpModel.GetWeaponID = function(career, id)
	if not id or id == 0 then
		id = career * 100
	end
	local cfg = _config_weapon_avatar[id]
	if cfg then
		return cfg.model, cfg.two_hand == 1
	end
end

local _config_hair_style = config.hair_style
ConfigHelpModel.GetHairID = function(career, hair)
	if hair then
		local hair_id = hair>>24
		local cfg = _config_hair_style[hair_id]
		if cfg then
			for i,v in ipairs(cfg.model_id) do
				if v[1] == career then
					return v[2]
				end
			end
		end
	end
	return career * 10000 + 1001
end

local _hair_color_mask = 0xff
ConfigHelpModel.GetHairColor = function(hair)
	local b = hair & _hair_color_mask
	local g = (hair >> 8) & _hair_color_mask
	local r = (hair >> 16) & _hair_color_mask
	return r,g,b
end

local _config_exterior_mount = config.exterior_mount
ConfigHelpModel.GetWingID = function(id)
	local cfg = _config_exterior_mount[id]
	if cfg then
		if cfg.is_wing == 1 then
			return cfg.model_id, cfg.ani
		end
	end
end

ConfigHelpModel.GetMountID = function(id)
	local cfg = _config_exterior_mount[id]
	if cfg then
		if cfg.is_wing == 0 then
			return cfg.model_id, cfg.ani
		end
	end
end

local _mount_idle_name = {
	[0] = "ride_idle",
	[1] = "ride_idle1",
	[2] = "ride_idle2",
	[3] = "ride_idle3",
	[4] = "ride_idle4",
	[5] = "ride_idle5",
	[6] = "ride_idle6",
	[7] = "ride_idle7",
	[8] = "ride_idle8",
	[9] = "ride_idle9",
}

local _mount_run_name = {
	[0] = "ride_run",
	[1] = "ride_run1",
	[2] = "ride_run2",
	[3] = "ride_run3",
	[4] = "ride_run4",
	[5] = "ride_run5",
	[6] = "ride_run6",
	[7] = "ride_run7",
	[8] = "ride_run8",
	[9] = "ride_run9",
}

ConfigHelpModel.GetMountIdleAnimName = function(anim_id)
	return _mount_idle_name[anim_id]
end

ConfigHelpModel.GetMountRunAnimName = function(anim_id)
	return _mount_run_name[anim_id]
end

config_help.ConfigHelpModel = ConfigHelpModel

return ConfigHelpModel