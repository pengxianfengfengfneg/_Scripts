config.territory = {
	[1] = {
		id = 1,
		name = "洛陽",
		quality = 3,
		scene = 40010,
		icon = "db_001",
	},
	[2] = {
		id = 2,
		name = "大名府",
		quality = 2,
		scene = 40010,
		icon = "db_002",
	},
	[3] = {
		id = 3,
		name = "應天府",
		quality = 2,
		scene = 40010,
		icon = "db_003",
	},
	[4] = {
		id = 4,
		name = "雁北郡",
		quality = 1,
		scene = 40010,
		icon = "db_004",
	},
	[5] = {
		id = 5,
		name = "敦煌郡",
		quality = 1,
		scene = 40010,
		icon = "db_005",
	},
	[6] = {
		id = 6,
		name = "龍泉郡",
		quality = 1,
		scene = 40010,
		icon = "db_006",
	},
	[7] = {
		id = 7,
		name = "南海郡",
		quality = 1,
		scene = 40010,
		icon = "db_007",
	},
}

local territory_scene = {}
for _,v in pairs(config.territory) do
	territory_scene[v.scene] = v
end
config.territory_scene = territory_scene