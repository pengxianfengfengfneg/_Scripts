local GuildTaskTypeConfig = {
	[game.GuildTaskType.Collection] = {
		desc_func = function(task_cfg, is_detail)
			local task_scene_info = task_cfg.task_scene_info
			local scene_id = task_scene_info[1]
			local gather_id = task_cfg.obj_id

			local scene_cfg = config.scene[scene_id]
			local gather_cfg = config.gather[gather_id]

			local desc = task_cfg.desc
			if is_detail then
				desc = task_cfg.desc2
			end
			return string.format(desc, scene_cfg.name, gather_cfg.name)
		end,
	},
	[game.GuildTaskType.FightCrime] = {
		desc_func = function(task_cfg, is_detail)
			local task_scene_info = task_cfg.task_scene_info
			local scene_id = task_scene_info[1]
			local monster_id = task_cfg.obj_id

			local scene_cfg = config.scene[scene_id]
			local monster_cfg = config.monster[monster_id]

			local desc = task_cfg.desc
			if is_detail then
				desc = task_cfg.desc2
			end
			return string.format(desc, scene_cfg.name, monster_cfg.name)
		end,
	},
	[game.GuildTaskType.VisitFamous] = {
		desc_func = function(task_cfg, is_detail)
			local npc_id = game.DailyTaskCtrl.instance:GetGuildTaskNpcId()
			local npc_cfg = config.npc[npc_id]
			local scene_id = npc_cfg.scene

			local scene_cfg = config.scene[scene_id]

			local desc = task_cfg.desc
			if is_detail then
				desc = task_cfg.desc2
			end
			return string.format(desc, scene_cfg.name, npc_cfg.name)
		end,
	},
	[game.GuildTaskType.HuntPet] = {
		desc_func = function(task_cfg, is_detail)
			local npc_id = game.DailyTaskCtrl.instance:GetGuildTaskNpcId()
			local pet_id = task_cfg.obj_id

			local npc_cfg = config.npc[npc_id]
			local pet_cfg = config.pet[pet_id]

			local desc = task_cfg.desc
			if is_detail then
				desc = task_cfg.desc2
			end

			local baby_list = game.PetCtrl.instance:GetBaby(pet_id)
			return string.format(desc, npc_cfg.name, pet_cfg.name),#baby_list
		end,
	},
	[game.GuildTaskType.RareTreasure] = {
		desc_func = function(task_cfg, is_detail)
			local goods_id = task_cfg.obj_id
			local npc_id = game.DailyTaskCtrl.instance:GetGuildTaskNpcId()

			local goods_cfg = config.goods[goods_id]
			local npc_cfg = config.npc[npc_id]

			local desc = task_cfg.desc
			if is_detail then
				desc = task_cfg.desc2
			end
			return string.format(desc, goods_cfg.name, npc_cfg.name)
		end,
	},
}

local DailyTaskConfig = {
	[game.DailyTaskId.GuildTask] = {
		-- 帮会任务
		id = game.DailyTaskId.GuildTask,
		cate = game.TaskCate.Daily,
		type = game.TaskType.GuildTask,
		name_func = function(not_times)
			local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
			if not task_info then
				return ""
			end

			local type_name = game.TaskTypeName[game.TaskType.GuildTask]

			local task_type = task_info.type
			local task_id = task_info.id

			local task_cfg = config.guild_task[task_type][task_id]
			if not task_cfg then
				return ""
			end
			
			local name = type_name .. task_cfg.name
			if not not_times then
				local daily_max_times = config.guild_task_info.daily_max_times
				name = string.format("%s<font color='#5fc934'>(%s/%s)</font>", name, task_info.daily_times+1, daily_max_times)
			end
			return name
		end,
		desc_func = function(no_times)
			local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
			if not task_info then
				return ""
			end

			local task_type = task_info.type
			local task_id = task_info.id			

			local task_cfg = config.guild_task[task_type][task_id]
			if not task_cfg then
				return ""
			end		

			local cfg = GuildTaskTypeConfig[task_type]
			local desc,progress = cfg.desc_func(task_cfg)	

			if not no_times then
				if not progress then
					progress = task_info.finish_times
				end
				desc = string.format("%s<font color='#5fc934'>(%s/%s)</font>", desc, math.min(progress,task_cfg.obj_num), task_cfg.obj_num)
			end
			return desc
		end,
		desc_func2 = function(cfg)
			local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
			if not task_info then
				return ""
			end

			local task_type = task_info.type
			local task_id = task_info.id

			local task_cfg = config.guild_task[task_type][task_id]

			local cfg = GuildTaskTypeConfig[task_type]
			local desc = cfg.desc_func(task_cfg, true)	

			return desc
		end,
		click_func = function()
			local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
			if not task_info then
				return
			end

			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				main_role:GetOperateMgr():DoHangTask(game.DailyTaskId.GuildTask)
			end
		end,
		check_func = function()
			local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
			if not task_info then
				return false
			end
			return (task_info.flag==1)
		end,
		abandon_func = function(is_do)
			if is_do then
				game.DailyTaskCtrl.instance:OpenTipsView(4)
			end
			return true
		end,
		update_event = {
			game.DailyTaskEvent.GuildTaskInfo,
			game.PetEvent.PetAdd,
			game.PetEvent.PetChange,
		},
	},

	[game.DailyTaskId.BanditTask] = {
		-- 马贼
		id = game.DailyTaskId.BanditTask,
		cate = game.TaskCate.Daily,
		type = game.TaskType.BanditTask,
		name_func = function()
			local thief_info = game.DailyTaskCtrl.instance:GetThiefInfo()
			local daily_times = thief_info.daily_times
			local times = thief_info.times
			local one_round_times = config.daily_thief.one_round_times
			if not (thief_info.state == 3 and times == one_round_times) then
				daily_times = daily_times + 1
			end

			return string.format(config.words[2165], daily_times, times, one_round_times)
		end,
		desc_func = function()
			local thief_info = game.DailyTaskCtrl.instance:GetThiefInfo()

			local state = thief_info.state
			if state==0 or state==3 then
				local task_npc = config.daily_thief.task_npc
				local npc_id = task_npc[4]
				local npc_cfg = config.npc[npc_id]

				return string.format(config.words[2168], npc_cfg.name)
			end

			local npc_id = thief_info.npc_id

			local npc_name = ""
			if npc_id then
				local npc_cfg = config.npc[npc_id]
				npc_name = npc_cfg.name
			end

			local round_word = ""
			local daily_times = thief_info.daily_times
			if daily_times < config.daily_thief.mul_reward_times then
				round_word = config.words[2194]
			end

			if state == 1 then
				-- 寻找
				local npc_cfg = config.npc[npc_id]
				local scene_cfg = config.scene[npc_cfg.scene]
				return string.format(config.words[2166], round_word, scene_cfg.name, npc_cfg.name)
			end

			return string.format(config.words[2167], round_word, npc_name)
		end,
		desc_func2 = function(cfg)
			local desc = cfg.desc_func()

			return desc
		end,
		click_func = function()
			local thief_info = game.DailyTaskCtrl.instance:GetThiefInfo()
			if thief_info then
				local main_role = game.Scene.instance:GetMainRole()
				if not main_role then
					return
				end

				local state = thief_info.state
				if state==0 or state==3 then
					local task_npc = config.daily_thief.task_npc

					local scene_id = task_npc[1]
					local ux,uy = game.LogicToUnitPos(task_npc[2], task_npc[3])
					main_role:GetOperateMgr():DoGoToScenePos(scene_id, ux, uy, function()
						-- 返回npc接受任务或交任务
						if state == 0 then
							game.DailyTaskCtrl.instance:SendDailyThiefGet()
						else
							game.DailyTaskCtrl.instance:SendDailyThiefHandleTask()
						end
					end,2)
				else
					game.DailyTaskCtrl.instance:HangThiefTask()
				end
			end
		end,
		check_func = function()
			local thief_info = game.DailyTaskCtrl.instance:GetThiefInfo()
			if thief_info then
				local state = thief_info.state
				return (state==1 or state==2 or state==3)
			end
			return false
		end,
		abandon_func = function(is_do)
			if is_do then
				game.DailyTaskCtrl.instance:SendDailyThiefCancel()
			end
			return true
		end,
		update_event = {
			game.DailyTaskEvent.UpdateThiefInfo,
		},
	},

	[game.DailyTaskId.TreasureTask] = {
		-- 藏宝图
		id = game.DailyTaskId.TreasureTask,
		cate = game.TaskCate.Daily,
		type = game.TaskType.TreasureTask,
		name_func = function()
			local type_name = game.TaskTypeName[game.TaskType.TreasureTask]

			return string.format("%s%s", type_name, config.treasure_map_info.name)
		end,
		desc_func = function(not_times)
			local nor_map_times = config.treasure_map_info.nor_map_times

			local treasure_info = game.DailyTaskCtrl.instance:GetTreasureMapInfo()
			local task_times = treasure_info.task_times

			local desc = config.treasure_map_info.desc
			if not not_times then
				desc = string.format("%s<font color='#5fc934'>(%s/%s)</font>", desc, task_times, nor_map_times)
			end
			return desc
		end,
		desc_func2 = function(cfg)
			return config.treasure_map_info.desc2
		end,
		click_func = function()
			game.Scene.instance:GetMainRole():GetOperateMgr():DoHangTask(game.DailyTaskId.TreasureTask)
		end,
		check_func = function()
			local treasure_info = game.DailyTaskCtrl.instance:GetTreasureMapInfo()
			return (treasure_info and treasure_info.is_trigger>0 and treasure_info.is_complete~=2)
		end,
		abandon_func = function(is_do)
			if is_do then

			end
			return false
		end,
		update_event = {
			game.DailyTaskEvent.UpdateTreasureMapInfo,
		},
	},

	[game.DailyTaskId.RobberTask] = {
		-- 惩凶打图
		id = game.DailyTaskId.RobberTask,
		cate = game.TaskCate.Daily,
		type = game.TaskType.RobberTask,
		name_func = function()
			local type_name = game.TaskTypeName[game.TaskType.RobberTask]

			return string.format("%s%s", type_name, config.daily_robber.name)
		end,
		desc_func = function(no_times, is_pos)
			local cxdt_data = game.DailyTaskCtrl.instance:GetCxdtData()
			local state = cxdt_data.state
			if state <= 0 then
				return ""
			end

			local desc = ""
			if state == 1 then
				local scene_id = cxdt_data.scene_id
				local scene_cfg = config.scene[scene_id]
				local str_pos = scene_cfg.name
				if is_pos then
					str_pos = string.format("%s(%s,%s)", scene_cfg.name, cxdt_data.x, cxdt_data.y)
				end
				desc = string.format(config.daily_robber.desc, str_pos)

				if not no_times then
					desc = string.format("%s<font color='#5fc934'>(%s/%s)</font>", desc, cxdt_data.times, cxdt_data.max_times)
				end
			elseif state == 2 then
				local npc_id = config.activity_hall_ex[1007].npc_id
				local npc_cfg = config.npc[npc_id]
				local scene_id = npc_cfg.scene
				local scene_cfg = config.scene[scene_id]

				desc = string.format(config.words[2196], scene_cfg.name, npc_cfg.name)
			end
			
			return desc
		end,
		desc_func2 = function()
			local cxdt_data = game.DailyTaskCtrl.instance:GetCxdtData()
			local state = cxdt_data.state
			if state <= 0 then
				return ""
			end

			local scene_id = cxdt_data.scene_id
			local scene_cfg = config.scene[scene_id]
			local str_pos = string.format("%s(%s,%s)", scene_cfg.name, cxdt_data.x, cxdt_data.y)
			local desc2 = string.format(config.daily_robber.desc2, str_pos)

			return desc2
		end,
		click_func = function()
			game.Scene.instance:GetMainRole():GetOperateMgr():DoHangTask(game.DailyTaskId.RobberTask)			
		end,
		check_func = function()
			local cxdt_data = game.DailyTaskCtrl.instance:GetCxdtData() or {state=0}
			return (cxdt_data.state>0)
		end,
		abandon_func = function(is_do)
			if is_do then
				game.DailyTaskCtrl.instance:CsDailyRobberAbandonTask()
			end
			return true
		end,
		update_event = {
			game.DailyTaskEvent.UpdateCxdtInfo,
		},
	},

	[game.DailyTaskId.YunbiaoTask] = {
		-- 帮会运镖
		id = game.DailyTaskId.YunbiaoTask,
		cate = game.TaskCate.Daily,
		type = game.TaskType.YunbiaoTask,
		name_func = function()
			
			--[[
				"carry_times__C",
		        "rob_times__C",
		        "quality__C",
		        "stat__C",
		        "expire_time__I",
		        "carry_scene__I",
		        "carry_x__H",
		        "carry_y__H",
			]]
			local task_type_name = game.TaskTypeName[game.TaskType.YunbiaoTask]

			return config.words[2184]
		end,
		desc_func = function()
			local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
			if not yunbiao_data then
				return ""
			end

			local stat = yunbiao_data.stat
			if stat == 0 then
				return ""
			end

			-- stat 0-没有运镖 1-运镖途中 2-运镖完成 3-奖励已领			
			if stat == 1 then
				local line = yunbiao_data.line or 1
				local line_cfg = config.guild_carry_scene[line]
				local target_cfg = line_cfg[#line_cfg]
				local target_scene = target_cfg.scene
				local target_npc = target_cfg.npc

				local scene_cfg = config.scene[target_scene]
				local npc_cfg = config.npc[target_npc]

				return string.format(config.words[2185], scene_cfg.name, npc_cfg.name)
			elseif stat == 2 then
				local carry_npc = config.carry_common.carry_npc
				local npc_cfg = config.npc[carry_npc]
				
				return string.format(config.words[2186], npc_cfg.name)
			end

			return ""
		end,
		desc_func2 = function(cfg)
			local desc = cfg.desc_func()

			return desc
		end,
		click_func = function()		
			local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
			if not yunbiao_data then
				return
			end

			local stat = yunbiao_data.stat
			if stat == 0 then
				return
			end

			-- 开始运镖后，根据运镖状态客户端插入任务列表

			local main_role = game.Scene.instance:GetMainRole()
			if main_role then
				main_role:GetOperateMgr():DoHangGuildCarry()				
			end
		end,
		check_func = function()
			local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData() or {stat=0}
			if yunbiao_data.stat > 0 then
				local cur_time = global.Time:GetServerTime()
				if cur_time >= yunbiao_data.expire_time then
					return false
				end
				return true
			end
			return false
		end,
		time_func = function()
			local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
			if yunbiao_data then
				local expire_time = yunbiao_data.expire_time
				local left_time = expire_time - global.Time:GetServerTime()
				return left_time
			end
			return 0
		end,
		abandon_func = function(is_do)
			if is_do then

			end
			return false
		end,
		update_event = {
			game.GuildEvent.YunbiaoStateChange,
		},
		on_event = function(event_type, ...)
			local yunbiao_data = game.GuildCtrl.instance:GetYunbiaoData()
			if yunbiao_data then

			end

		end,
	},

	-- [game.DailyTaskId.WulinReward] = {
	-- 	-- 武林悬赏令
	-- 	id = game.DailyTaskId.WulinReward,
	-- 	cate = game.TaskCate.Daily,
	-- 	type = game.TaskType.WulinReward,
	-- 	name_func = function()
	-- 		local task_cfg = game.TaskCtrl.instance:GetTaskCfg(game.DailyTaskId.WulinReward)
	-- 		if task_cfg then
	-- 			local task_type_name = game.TaskTypeName[game.TaskType.WulinReward]
	-- 			return (task_type_name .. task_cfg.name)
	-- 		end

	-- 		return ""
	-- 	end,
	-- 	desc_func = function()
	-- 		local accept_task = game.WulinRewardCtrl.instance:GetAcceptTask()
	-- 		if not accept_task then
	-- 			return ""
	-- 		end

	-- 		local task_cfg = game.TaskCtrl.instance:GetTaskCfg(game.DailyTaskId.WulinReward)
	-- 		if task_cfg then
	-- 			return task_cfg.desc
	-- 		end

	-- 		return ""
	-- 	end,
	-- 	desc_func2 = function(cfg)
	-- 		local desc = cfg.desc_func()

	-- 		return desc
	-- 	end,
	-- 	click_func = function()		
	-- 		local accept_task = game.WulinRewardCtrl.instance:GetAcceptTask()
	-- 		if not accept_task then
	-- 			return
	-- 		end

	-- 		local main_role = game.Scene.instance:GetMainRole()
	-- 		if main_role then
	-- 			print("accept_task XXX", accept_task)
	-- 			main_role:GetOperateMgr():DoHangTask(accept_task)
	-- 		end
	-- 	end,
	-- 	check_func = function()
	-- 		local accept_task = game.WulinRewardCtrl.instance:GetAcceptTask()
	-- 		return (accept_task~=nil)
	-- 	end,
	-- 	abandon_func = function(is_do)
	-- 		if is_do then

	-- 		end
	-- 		return false
	-- 	end,
	-- 	update_event = {
	-- 		game.WulinRewardEvent.WulinRewardChange,
	-- 	},
	-- 	on_event = function(event_type, ...)
	-- 		local accept_task = game.WulinRewardCtrl.instance:GetAcceptTask()
	-- 		if accept_task then

	-- 		end
	-- 	end,
	-- },
}

local DefaultConfig = {
	name_func = function() return "" end,
	desc_func = function() return "" end,
	desc_func2 = function() return "" end,
	click_func = function() end,
	check_func = function() return false end,
	abandon_func = function() end,
	update_event = {},
	on_event = function() end,
}

local config_task = config.task
for k,v in pairs(DailyTaskConfig) do
	v.seq = 999999
	local task_cfg = config_task[v.id]
	if task_cfg and task_cfg[1] then
		v.seq = task_cfg[1].seq
		v.show_seq = task_cfg[1].show_seq
	end
	
	for ck,cv in pairs(DefaultConfig) do
		if not v[ck] then
			v[ck] = cv
		end
	end
end

return DailyTaskConfig