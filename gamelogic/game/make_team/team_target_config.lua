local TeamTargetConfig = {
	-- 一条龙
	[1] = {
		click_func = function(cfg)	
			local task_npc = config.daily_thief.task_npc
			local npc_id = task_npc[4]
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
	},
	-- 夺宝马贼
	[2] = {
		click_func = function(cfg)	
			local task_npc = config.daily_thief.task_npc
			local npc_id = task_npc[4]
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
	},
	-- 老三环
	[3] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
	},
	-- 燕子坞
	[4] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
	},
	-- 四绝庄
	[5] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
	},
	-- 缥缈峰
	[6] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
	},
	-- 孵化
	[7] = {
		click_func = function(cfg)	

		end,
	},
	-- 野外
	[8] = {
		click_func = function(cfg)	
			game.LakeExpCtrl.instance:OpenView()
		end,
	},
	-- 燕王古墓
	[9] = {
		click_func = function(cfg)	
			game.LakeExpCtrl.instance:OpenView()
		end,
	},
	-- 秦王地宫
	[10] = {
		click_func = function(cfg)	
			game.LakeExpCtrl.instance:OpenView()
		end,
	},
	-- 英雄老三环
	[11] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
		check_func = function(cfg)
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(cfg.dun_id)
		end,
	},
	-- 英雄燕子坞
	[12] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
		check_func = function(cfg)
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(cfg.dun_id)
		end,
	},
	-- 英雄四绝庄
	[13] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
		check_func = function(cfg)
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(cfg.dun_id)
		end,
	},
	-- 英雄缥缈峰
	[14] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
		check_func = function(cfg)
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(cfg.dun_id)
		end,
	},
	-- 珍珑棋局
	[15] = {
		click_func = function(cfg)	
			local dun_id = cfg.dun_id
			local dun_cfg = config.dungeon[dun_id] or {}
			local npc_id = dun_cfg.npc
			if npc_id then
				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
		end,
	},
	[16] = {
		click_func = function(cfg)	

		end,
	},
	
}

local check_func = function()
	return true
end
for k,v in pairs(TeamTargetConfig) do
	v.check_func = v.check_func or check_func
end

return TeamTargetConfig