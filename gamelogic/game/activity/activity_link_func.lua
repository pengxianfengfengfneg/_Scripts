local function check_follow(cfg)
	if not cfg then
		return
	end

	local follow = cfg.follow or 0
	if follow ~= 1 then
		return
	end

	if game.MakeTeamCtrl.instance:IsSelfLeader() then
		game.MakeTeamCtrl.instance:SendTeamFollow(1)
	end
end

game.ActivityLinkFunc = {
	--武林盟主
	[1001] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.OverlordCtrl.instance:OpenView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--帮会行酒令
	[1003] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.GuildCtrl.instance:TryJoinInGuildWine()
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 世界BOSS
	[1004] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.WorldBossCtrl.instance:OpenView()
		end,
		check_func = function()
			return (not game.Scene.instance:IsWorldBossScene())
		end,
		visible_func = function()
			return true
		end,
	},
	-- 帮会守卫战
	[1005] = {
		click_func = function(cfg)
			check_follow(cfg)
			if not game.GuildCtrl.instance:IsGuildMember() then
				game.GameMsgCtrl.instance:PushMsgCode(7110)
				return
			end
			local npc_id = 2008
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 门派竞技
	[1006] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = 11
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
			end
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 镜湖剿匪
	[1007] = {
		click_func = function(cfg)
			check_follow(cfg)
			local scene_id = game.Scene.instance:GetSceneID()
			if scene_id ~= config.lake_bandits_info.scene then
				game.LakeBanditsCtrl.instance:OpenTipsView()
				game.ActivityMgrCtrl.instance:CloseActivityHallView()
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 帮会行酒令
	[1008] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.GuildCtrl.instance:TryJoinInGuildWine()
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--演武堂
	[1009] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.jousts_hall_info[20005].npc
			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
			end)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 领地战
	[1010] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.GuildCtrl.instance:OpenView(5, 2)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 帮会练功
	[1013] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			game.GuildCtrl.instance:TryJoinInPractice()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 珍珑棋局
	[1014] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			game.DailyTaskCtrl.instance:FindChessNpc()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 运镖
	[1015] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			local npc_id = config.carry_common.carry_npc
			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
			end)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 江湖历练
	[1016] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.OpenFuncCtrl.instance:OpenFuncView(game.OpenFuncId.LakeExp)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--宋辽大战
	[6001] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = 9
			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
			end)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
}

game.ActivityHallTypeOneLink = {
	--老三环
	[1001] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1001].npc_id
			if npc_id > 0 then
				game.ActivityMgrCtrl.instance:CloseActivityHallView()

				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--燕子坞
	[1002] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1002].npc_id
			if npc_id > 0 then
				game.ActivityMgrCtrl.instance:CloseActivityHallView()

				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--四绝庄
	[1003] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1003].npc_id
			if npc_id > 0 then
				game.ActivityMgrCtrl.instance:CloseActivityHallView()

				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--缥缈峰
	[1004] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1004].npc_id
			if npc_id > 0 then
				game.ActivityMgrCtrl.instance:CloseActivityHallView()

				local main_role = game.Scene.instance:GetMainRole()
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--帮会任务
	[1005] = {
		click_func = function(cfg)
			check_follow(cfg)
			local role_level = game.RoleCtrl.instance:GetRoleLevel()
			local open_lv = config.guild_task_info.open_lv
			if role_level < open_lv then
				game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1953], open_lv))
				return
			elseif not game.GuildCtrl.instance:IsGuildMember() then
				game.GameMsgCtrl.instance:PushMsg(config.words[4772])
				return
			end
			game.ActivityMgrCtrl.instance:CloseActivityHallView()

			local guild_task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
			if guild_task_info and guild_task_info.flag==1 then
				local main_role = game.Scene.instance:GetMainRole()
				if main_role then
					main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.GuildTask)
				end
			else
				game.GuildTaskCtrl.instance:OpenView()
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--科举考试
	[1006] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			local npc_id = config.activity_hall_ex[1006].npc_id
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--惩凶打图
	[1007] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()

			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.RobberTask)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--分金定穴
	[1008] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()

			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.TreasureTask)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--江湖历练
	[1009] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			game.LakeExpCtrl.instance:OpenView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--英雄试炼
	[1010] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()

			local npc_id = config.activity_hall_ex[1010].npc_id
			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
			end)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--夺宝马贼
	[1011] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			
			local npc_id = config.activity_hall_ex[1011].npc_id
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--每日任务
	[1012] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()

			local main_role = game.Scene.instance:GetMainRole()
			if not main_role then
				return
			end
			local task_info = game.DailyTaskCtrl.instance:GetDailyTaskInfo()
			if task_info.task_id ~= 0 then
				main_role:GetOperateMgr():DoHangTask(task_info.task_id)
			else
				local npc_id = config.activity_hall_ex[1012].npc_id
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 武林悬赏令
	[1013] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			game.WulinRewardCtrl.instance:OpenView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			local lv = game.Scene.instance:GetMainRoleLevel()
			local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
			if pioneer_lv >= config.sys_config["prize_task_level_limit"].value then
				return config_help.ConfigHelpLevel.HasPioneerLvAdd(lv, pioneer_lv)
			else
				return false
			end
		end,
	},
	-- 帮会炼金
	[1014] = {
		click_func = function(cfg)
			check_follow(cfg)
			if not game.GuildCtrl.instance:IsGuildMember() then
				game.GameMsgCtrl.instance:PushMsgCode(3401)
				return
			end

			game.ActivityMgrCtrl.instance:CloseActivityHallView()

			local main_role = game.Scene.instance:GetMainRole()
			if not main_role then
				return
			end
			local task_id = game.GuildCtrl.instance:GetMetallTaskId()
			if task_id ~= 0 then
				main_role:GetOperateMgr():DoHangTask(task_id)
			else
				local npc_id = config.activity_hall_ex[1014].npc_id
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--少室山
	[1015] = {
		click_func = function(cfg)
			check_follow(cfg)
			if not game.GuildCtrl.instance:IsGuildMember() then
				game.GameMsgCtrl.instance:PushMsg(config.words[4772])
				return
			end
			game.ActivityMgrCtrl.instance:CloseActivityHallView()
			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				local npc_id = config.activity_hall_ex[1015].npc_id
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 跑环任务
	[1016] = {
		click_func = function(cfg)
			check_follow(cfg)
			local main_role = game.Scene.instance:GetMainRole()
			local task_id = game.TaskCtrl.instance:GetCircleTaskId()
			if task_id then
				main_role:GetOperateMgr():DoHangTask(task_id)
			else
				local npc_id = config.activity_hall_ex[1016].npc_id
				main_role:GetOperateMgr():DoGoToTalkNpc(npc_id, function()
				end)
			end
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	-- 众里寻卿
	[1017] = {
		click_func = function(cfg)
			check_follow(cfg)
			game.VowCtrl.instance:OpenView()
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return true
		end,
	},
	--英雄老三环
	[1018] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1018].npc_id
			game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(1800)
		end,
	},
	-- 英雄燕子坞
	[1019] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1019].npc_id
			game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(1900)
		end,
	},
	-- --英雄四绝庄
	[1020] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1020].npc_id
			game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(2000)
		end,
	},
	--英雄缥缈峰
	[1021] = {
		click_func = function(cfg)
			check_follow(cfg)
			local npc_id = config.activity_hall_ex[1021].npc_id
			game.Scene.instance:GetMainRole():GetOperateMgr():DoGoToTalkNpc(npc_id)
		end,
		check_func = function()
			return true
		end,
		visible_func = function()
			return game.CarbonCtrl.instance:CheckHeroDungeVisible(2100)
		end,
	},
}