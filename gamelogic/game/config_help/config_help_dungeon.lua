local ConfigHelpDungeon = {}


--[[
	副本对应场景
]]
local dungeon_scene = {}
for k,v in pairs(config.dungeon_lv) do
	for _,cv in pairs(v) do
		dungeon_scene[k] = cv.scene_id
		break
	end
end
config.dungeon_scene = dungeon_scene

--[[
	场景对应副本
]]
local scene_dungeon = {}
for k,v in pairs(dungeon_scene) do
	scene_dungeon[v] = k
end
config.scene_dungeon = scene_dungeon

ConfigHelpDungeon.GetSceneForDun = function(dun_id)
	return dungeon_scene[dun_id]
end

ConfigHelpDungeon.GetDunForScene = function(scene_id)
	return scene_dungeon[scene_id]
end

config_help.ConfigHelpDungeon = ConfigHelpDungeon

return ConfigHelpDungeon