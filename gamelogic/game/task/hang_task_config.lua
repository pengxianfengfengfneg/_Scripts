local et = {}

local HangTaskConfig = {
	[0] = {
		-- 对话
		oper_func = function(self, task_cfg, task_info)
			-- 对话任务
	        -- 已接受
			local talk_id = 0
			local task_state = task_info.stat
			if task_state == game.TaskState.Acceptable then
				-- 可接受任务
				talk_id = task_cfg.accept_talk
			elseif task_state == game.TaskState.Accepted then
				-- 已接受任务
				if not game.TaskCtrl.instance:HasDoTaskTalk(task_cfg.id) then
					talk_id = task_cfg.talk_id
				end
			elseif task_state == game.TaskState.Finished then
				-- 已完任务
				if not game.TaskCtrl.instance:HasDoTaskTalk(task_cfg.id) then
					talk_id = task_cfg.talk_id
				else
					talk_id = task_cfg.finish_talk
				end				
			end

			if talk_id <= 0 then
				return self:CreateOperate(game.OperateType.Empty, self.obj)
			end

			return self:CreateOperate(game.OperateType.TalkToNpc, self.obj, task_cfg.id, talk_id)
		end,	
	},
	[1] = {
		-- 等级提升
		oper_func = function(self, task_cfg, task_info, idx)
			game.TaskCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[2] = {
		-- 加入帮会
		oper_func = function(self, task_cfg, task_info, idx)
			game.GuildCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[3] = {
		-- 寻找好友
		oper_func = function(self, task_cfg, task_info, idx)
			game.FriendCtrl.instance:OpenFriendView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[4] = {
		-- 装备强化 强化总等级达到20级
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenView(1)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[5] = {
		-- 装备强化 最高强化等级达到10级
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenView(1)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[6] = {
		-- 宝石镶嵌 宝石总等级达到10级
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenView(2)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[7] = {
		-- 宝石镶嵌 宝石最高等级达到5级
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenView(2)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[8] = {
		-- 珍兽培养
		oper_func = function(self, task_cfg, task_info, idx)
			game.PetCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[9] = {
		-- 珍兽悟性
		oper_func = function(self, task_cfg, task_info, idx)
			game.PetCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[10] = {
		-- 杀怪
		oper_func = function(self, task_cfg, task_info, idx)
			if task_cfg.id == 20915 then
				-- 特殊任务处理
				local cur_scene_id = game.Scene.instance:GetSceneID()
				if cur_scene_id ~= 70101 then
					return
				end
			end

			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local scene_id = task_cond[3][1]
			local monster_id = task_cond[3][2]
			local need_num = cond.total - cond.current

			return self:CreateOperate(game.OperateType.HangTaskMonster, self.obj, task_cfg.id, scene_id, monster_id, need_num)
		end,	
	},
	[11] = {
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local dun_id = task_cond[3][1]
			local dun_lv = task_cond[3][2]
			local npc_id = task_cond[3][3] or 0

			if npc_id > 0 then
				local npc_obj = self.obj.scene:GetNpc(npc_id)
				if npc_obj then
					return self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id), self:CreateOperate(game.OperateType.HangTaskDungeon, self.obj, task_cfg.id, dun_id, dun_lv)
				end
			end

			return self:CreateOperate(game.OperateType.HangTaskDungeon, self.obj, task_cfg.id, dun_id, dun_lv)
		end,		
	},
	[12] = {
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local scene_id = task_cond[3][1]
			local gather_id = task_cond[3][2]

			return self:CreateOperate(game.OperateType.HangTaskGather, self.obj, task_cfg.id, gather_id, scene_id)
		end,		
	},
	[13] = {
		-- 在玄武岛捕捉1只珍兽并上交
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local scene_id = task_cond[3][1]
			local monster_id = task_cond[3][2]
			local gather_id = task_cond[3][3]

			return self:CreateOperate(game.OperateType.HangTaskCatchPet, self.obj, task_cfg.id, gather_id, monster_id, scene_id)
		end,		
	},

	[15] = {
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local dun_id = task_cond[3][1]
			local dun_lv = task_cond[3][2]
			local npc_id = task_cond[3][3] or 0

			if npc_id > 0 then
				local npc_obj = self.obj.scene:GetNpc(npc_id)
				if npc_obj then
					return self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id), self:CreateOperate(game.OperateType.HangTaskDungeon, self.obj, task_cfg.id, dun_id, dun_lv)
				end
			end

			return self:CreateOperate(game.OperateType.HangTaskDungeon, self.obj, task_cfg.id, dun_id, dun_lv)
		end,		
	},
	[16] = {
		-- 累计完成n环每日任务
		oper_func = function(self, task_cfg, task_info, idx)
			-- local info = game.DailyTaskCtrl.instance:GetDailyTaskInfo()
			-- if info.task_id > 0 then
			-- 	return self:CreateOperate(game.OperateType.HangDailyTask, self.obj)
			-- else
			-- 	game.ActivityMgrCtrl.instance:OpenActivityHallView()
			-- 	return self:CreateOperate(game.OperateType.Empty, self.obj)
			-- end			

			game.TaskCtrl.instance:CloseView()
			game.TaskCtrl.instance:CloseTaskDetailView()
		end,	
	},
	[17] = {
		-- 累计通关n次副本类型为id的副本
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local dun_type = task_cond[3][1]

			local seek_npc = nil
			for k,v in pairs(config.dungeon) do
				if v.dun_type == dun_type then
					seek_npc = v.npc
					break
				end
			end

			if seek_npc then
				return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, seek_npc),self:CreateOperate(game.OperateType.Empty, self.obj)
			end

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,		
	},
	[18] = {
		-- 当日活跃值达到n
		oper_func = function(self, task_cfg, task_info, idx)
			game.ActivityMgrCtrl.instance:OpenActivityHallView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[19] = {
		-- 在id商店购买n个item
		oper_func = function(self, task_cfg, task_info, idx)
			-- local task_cond = task_cfg.finish_cond[idx]
			-- local shop_id = task_cond[3][1]
			-- local item_id = task_cond[3][2]

			-- game.ShopCtrl.instance:OpenViewByShopId(shop_id, item_id)
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[20] = {
		-- 合成或提升n颗宝石至m级
		oper_func = function(self, task_cfg, task_info, idx)

			game.FoundryCtrl.instance:OpenView(2)
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[21] = {
		-- 繁殖出n只m星或以上的二代珍兽
		oper_func = function(self, task_cfg, task_info, idx)
			local pet_npc = config.pet_common.hatch_npc[1]
			if pet_npc then
				return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, pet_npc),self:CreateOperate(game.OperateType.Empty, self.obj)
			end
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[22] = {
		-- 珍兽学习n个技能
		oper_func = function(self, task_cfg, task_info, idx)
			game.PetCtrl.instance:OpenView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[23] = {
		-- 历史帮贡达到n
		oper_func = function(self, task_cfg, task_info, idx)
			game.GuildCtrl.instance:OpenView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[24] = {
		-- 结交n位英雄
		oper_func = function(self, task_cfg, task_info, idx)
			game.HeroCtrl.instance:OpenView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[25] = {
		-- 累计参与n次夺宝马贼活动
		oper_func = function(self, task_cfg, task_info, idx)
			-- local task_npc = config.daily_thief.task_npc[4]
			-- if task_npc then
			-- 	return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, task_npc),self:CreateOperate(game.OperateType.Empty, self.obj)
			-- end

			-- return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[26] = {
		-- 累计参与n次科举考试
		oper_func = function(self, task_cfg, task_info, idx)
			-- local npc_id = config.activity_hall_ex[1006].npc_id
			-- if npc_id then
			-- 	return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
			-- end
			-- return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[27] = {
		-- 累计参与n次惩凶打图
		oper_func = function(self, task_cfg, task_info, idx)
			-- local npc_id = config.activity_hall_ex[1007].npc_id
			-- if npc_id then
			-- 	return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
			-- end
			-- return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[28] = {
		-- 累计使用n张藏宝图
		oper_func = function(self, task_cfg, task_info, idx)
			game.ActivityMgrCtrl.instance:OpenActivityHallView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[29] = {
		-- 累计完成n环帮会任务
		oper_func = function(self, task_cfg, task_info, idx)
			local task_info = game.DailyTaskCtrl.instance:GetGuildTaskInfo()
			if not task_info or task_info.flag == 0 then
				game.GuildTaskCtrl.instance:OpenView()
				return self:CreateOperate(game.OperateType.Empty, self.obj)
			end
			return self:CreateOperate(game.OperateType.HangGuildTask, self.obj)		
		end,	
	},
	[30] = {
		-- n个技能等级提升至m级
		oper_func = function(self, task_cfg, task_info, idx)
			game.SkillCtrl.instance:OpenView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[31] = {
		-- 购买n次周卡或月卡
		oper_func = function(self, task_cfg, task_info, idx)
			game.RewardHallCtrl.instance:OpenView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[32] = {
		-- 累计参与n次帮会练功活动
		oper_func = function(self, task_cfg, task_info, idx)
			local npc_id = 2003
			if npc_id then
				return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
			end
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[33] = {
		-- 累计参与n次宋辽大战活动
		oper_func = function(self, task_cfg, task_info, idx)
			local npc_id = 9
			if npc_id then
				return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
			end
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[34] = {
		-- 将神器突破至n阶
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenGodWeaponView()
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[35] = {
		-- 繁殖n次珍兽
		oper_func = function(self, task_cfg, task_info, idx)
			local pet_npc = config.pet_common.hatch_npc[1]
			if pet_npc then
				return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, pet_npc),self:CreateOperate(game.OperateType.Empty, self.obj)
			end
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[36] = {
		-- 将1只珍兽的成长率洗炼至卓越
		oper_func = function(self, task_cfg, task_info, idx)
			game.PetCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[37] = {
		-- 累计完成n次帮会运镖活动
		oper_func = function(self, task_cfg, task_info, idx)
			local npc_id = config.carry_common.carry_npc
			if npc_id then
				return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
			end
			
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[38] = {
		-- 购买n次m档每日礼包
		oper_func = function(self, task_cfg, task_info, idx)
			game.RewardHallCtrl.instance:OpenView()
			
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},
	[39] = {
		-- 战力达到m
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenView()
			
			return self:CreateOperate(game.OperateType.Empty, self.obj)		
		end,	
	},

	[40] = {
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local scene_id = task_cond[3][1]
			local monster_id = task_cond[3][2]
			local gather_id = task_cond[3][3]

			return self:CreateOperate(game.OperateType.HangTaskCatchPet, self.obj, task_cfg.id, gather_id, monster_id, scene_id)
		end,		
	},
	[41] = {
		oper_func = function(self, task_cfg, task_info, idx)
			game.DailyTaskCtrl.instance:OpenDailyTaskItemView(task_cfg)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[42] = {
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local scene_id = task_cond[3][1]
			local gather_id = task_cond[3][2]

			return self:CreateOperate(game.OperateType.HangTaskGatherQueue, self.obj, task_cfg.id, gather_id, scene_id)
		end,	
	},
	[43] = {
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenGodWeaponView(1)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[44] = {
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenView(3)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[45] = {
		oper_func = function(self, task_cfg, task_info, idx)
			game.PetCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[46] = {
		oper_func = function(self, task_cfg, task_info, idx)
			game.HeroCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	-- [48] = {
	-- 	oper_func = function(self, task_cfg, task_info, idx)
	-- 		game.ActivityMgrCtrl.instance:OpenActivityHallView()

	-- 		return self:CreateOperate(game.OperateType.Empty, self.obj)
	-- 	end,
	-- },
	[49] = {
		oper_func = function(self, task_cfg, task_info, idx)
			-- game.ActivityMgrCtrl.instance:OpenActivityHallView()

			-- return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},	
	[51] = {
		oper_func = function(self, task_cfg, task_info, idx)
			--game.ActivityMgrCtrl.instance:OpenActivityHallView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	[52] = {
		-- 激活神器
		oper_func = function(self, task_cfg, task_info, idx)
			game.FoundryCtrl.instance:OpenGodWeaponCollectView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	[53] = {
		-- 提升名望
		oper_func = function(self, task_cfg, task_info, idx)
			game.RoleCtrl.instance:OpenView()

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	[54] = {
		-- 在频道id使用文本发言n次
		oper_func = function(self, task_cfg, task_info, idx)
			local task_cond = task_cfg.finish_cond[idx]
			local channel_id = task_cond[3][1]

			game.ChatCtrl.instance:OpenView(channel_id)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	[55] = {
		-- 领取n次副本ID首通奖励
		oper_func = function(self, task_cfg, task_info, idx)
			local task_cond = task_cfg.finish_cond[idx]
			local dun_id = task_cond[3][1]

			local dun_cfg = config.dungeon[dun_id]
			local npc_id = dun_cfg.npc

			return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	[56] = {
		-- 领取副本ID指定章节ch所有首通奖励
		oper_func = function(self, task_cfg, task_info, idx)
			local task_cond = task_cfg.finish_cond[idx]
			local dun_id = task_cond[3][1]

			local dun_cfg = config.dungeon[dun_id]
			local npc_id = dun_cfg.npc

			return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	[57] = {
		-- 在频道id使用语音发言n次
		oper_func = function(self, task_cfg, task_info, idx)
			local task_cond = task_cfg.finish_cond[idx]
			local channel_id = task_cond[3][1]

			game.ChatCtrl.instance:OpenView(channel_id)

			return self:CreateOperate(game.OperateType.Empty, self.obj)
		end,
	},
	[80] = {
		-- 繁殖操作n次
		oper_func = function(self, task_cfg, task_info, idx)
			local pet_npc = config.pet_common.hatch_npc[1]
			if pet_npc then
				return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, pet_npc),self:CreateOperate(game.OperateType.Empty, self.obj)
			end
			return self:CreateOperate(game.OperateType.Empty, self.obj)	
		end,
	},
	[95] = {
		oper_func = function(self, task_cfg, task_info, idx)
			local cond = task_info.masks[idx]

			local task_cond = task_cfg.finish_cond[idx]
			local dun_id = task_cond[3][1]
			local dun_lv = 1
			local npc_id = task_cond[3][2] or 0

			if npc_id > 0 then
				local npc_obj = self.obj.scene:GetNpc(npc_id)
				if npc_obj then
					return self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id), self:CreateOperate(game.OperateType.HangTaskDungeon, self.obj, task_cfg.id, dun_id, dun_lv)
				end
			end

			return self:CreateOperate(game.OperateType.HangTaskDungeon, self.obj, task_cfg.id, dun_id, dun_lv)
		end,		
	},



	-- 客户端专用
	[1000] = {
		-- 获得物品
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et

			local item_num = client_action[2]
			local item_id = client_action[3][1]

			return self:CreateOperate(game.OperateType.HangTaskGetItem, self.obj, item_id, item_num)
		end,	
	},
	[1001] = {
		-- 向Npc提交n个物品
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[idx]

			local npc_id = client_action[3][1]
			local item_num = client_action[2]
			local item_id = client_action[3][2]
			

			return self:CreateOperate(game.OperateType.HangTaskGetItem, self.obj, item_id, item_num)
		end,	
	},
	[1004] = {
		-- 拜见名士
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[3]

			return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[1005] = {
		-- 武学考验
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[3]

			return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[1006] = {
		-- 旷世之宝
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[3]
			local item_id = client_action[4]

			local oper_list = {}
			local item_num = game.BagCtrl.instance:GetNumById(item_id)
			if item_num <= 0 then
				table.insert(oper_list, self:CreateOperate(game.OperateType.GetItem, self.obj, item_id))
			end

			table.insert(oper_list, self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id))
			table.insert(oper_list, self:CreateOperate(game.OperateType.Empty, self.obj))

			return table.unpack(oper_list)
		end,	
	},
	[1007] = {
		-- 奇珍异兽
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[3]
			local pet_id = client_action[4]
			local gather_id = client_action[5]

			local pet_cfg = config.pet[pet_id]
			local catch_cfg = config.catch_pet[pet_cfg.active_item]

			local oper_list = {}
			local pet_list = game.PetCtrl.instance:GetBaby(pet_id)
			if #pet_list <= 0 then
				table.insert(oper_list, self:CreateOperate(game.OperateType.HangCatchPet, self.obj, catch_cfg.coll_id, catch_cfg.mon_id))
			end
			table.insert(oper_list, self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id))
			table.insert(oper_list, self:CreateOperate(game.OperateType.Empty, self.obj))

			return table.unpack(oper_list)
		end,	
	},
	[1008] = {
		-- 炼金任务
		oper_func = function(self, task_cfg, task_info, idx)
			local finish_cond = task_cfg.finish_cond[1][3]
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[2]
			local gather_id = finish_cond[2]
			local scene_id = finish_cond[1]

			local oper_list = {}
			table.insert(oper_list, self:CreateOperate(game.OperateType.HangTaskGatherQueue, self.obj, task_cfg.id, gather_id, scene_id))

			if npc_id then
				table.insert(oper_list, self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id))
			end
			table.insert(oper_list, self:CreateOperate(game.OperateType.GetTaskReward, self.obj, task_cfg.id))
			table.insert(oper_list, self:CreateOperate(game.OperateType.Empty, self.obj))

			return table.unpack(oper_list)
		end,	
	},
	[1009] = {
		-- 科举考试新手任务
		oper_func = function(self, task_cfg, task_info, idx)
			return self:CreateOperate(game.OperateType.HangTaskExamineNew, self.obj, task_cfg)--,self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[1010] = {
		-- 拼画
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[3]

			return self:CreateOperate(game.OperateType.GoToTalkNpc, self.obj, npc_id),self:CreateOperate(game.OperateType.Empty, self.obj)
		end,	
	},
	[1011] = {
		-- 武学考验（无对话)
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[2]
			local game_id = client_action[3]

			local oper_list = {
				self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id),
				self:CreateOperate(game.OperateType.OpenView, self.obj, "DailyTaskCtrl", "OpenLineGameView", task_cfg.id, game_id),
			}
			return table.unpack(oper_list)
		end,	
	},
	[1012] = {
		-- 拼画（无对话)
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[2]
			local game_id = client_action[3]

			local oper_list = {
				self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id),
				self:CreateOperate(game.OperateType.OpenView, self.obj, "DailyTaskCtrl", "OpenPuzzleGameView", task_cfg.id, game_id),
			}
			return table.unpack(oper_list)
		end,	
	},
	[1013] = {
		-- 转盘（无对话)
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[2]

			local oper_list = {
				self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id),
				self:CreateOperate(game.OperateType.OpenView, self.obj, "MiniGameCtrl", "OpenRotatyView", task_cfg.id),
			}
			return table.unpack(oper_list)
		end,	
	},
	[1014] = {
		-- 涂抹
		oper_func = function(self, task_cfg, task_info, idx)
			local client_action = task_cfg.client_action or et
			client_action = client_action[1]

			local npc_id = client_action[2]

			local oper_list = {
				self:CreateOperate(game.OperateType.GoToNpc, self.obj, npc_id),
				self:CreateOperate(game.OperateType.OpenView, self.obj, "MiniGameCtrl", "OpenPaintView", task_cfg.id),
			}
			return table.unpack(oper_list)
		end,
	},
}

return HangTaskConfig