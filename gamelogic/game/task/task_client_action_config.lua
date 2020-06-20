local TaskClientActionConfig = {
	-- 武学考验
	[1005] = {
		check_func = function(cfg)
			local id = cfg[4]
		end,
		update_event = {

		},
	},
	-- 旷世之宝
	[1006] = {
		check_func = function(cfg)
			local item_id = cfg[4]
			local item_num = game.BagCtrl.instance:GetNumById(item_id)
			return (item_num>0)
		end,
		update_event = {
			game.BagEvent.BagItemChange
		},
		update_func = function(cfg)
			local npc_id = cfg[4]
			local npc_obj = game.Scene.instance:GetNpc(npc_id)
			if npc_obj then
				npc_obj:CheckTaskState()
			end
		end,
	},
	-- 珍禽异兽
	[1007] = {
		check_func = function(cfg)
			local pet_id = cfg[4]
			local pet_list = game.PetCtrl.instance:GetBaby(pet_id)
			return (#pet_list>0)
		end,
		update_event = {
			game.PetEvent.BagPetDelete
		},
		update_func = function(cfg)
			local npc_id = cfg[4]
			local npc_obj = game.Scene.instance:GetNpc(npc_id)
			if npc_obj then
				npc_obj:CheckTaskState()
			end
		end,
	},
}

local check_func = function()
	return true
end
local update_event = {}

local update_func = function()
	
end

for _,v in pairs(TaskClientActionConfig) do
	v.check_func = v.check_func or check_func
	v.update_event = v.update_event or update_event
	v.update_func = v.update_func or update_func
end

return TaskClientActionConfig