--[[
	open_func 					功能打开函数
	check_open_func 			功能打开检测函数
	check_visible_func 			功能显示检测函数
	check_red_func 				功能红点检测函数
	sub_func 					包含子功能列表
	red_events 					红点监听事件
	red_delta 					红点刷新间隔 默认0.1秒
	update_event				更新事件，出现消失

	注：函数类型皆附带参数 (func_id, sub_func, cfg, params) 即功能id，子功能列表，功能本身配置，自定义params传参 按需使用
]]

local func_config = config.func

local sys_id_config = {
	[game.OpenFuncId.PassTask] = {
        open_func = function(func_id, sub_func, cfg, task_id, pass_id)
            game.PassBossCtrl.instance:OpenView()
        end,
        check_open_func = function()
            return true
        end,
        check_visible_func = function()
            return true
        end,
    },

    [game.OpenFuncId.LevelHang] = {
        open_func = function(func_id, sub_func, cfg, params)
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
            	main_role:GetOperateMgr():DoHang()
            end
        end,
        check_open_func = function()
            return true
        end,
        check_visible_func = function()
            return true
        end,
    },

    [game.OpenFuncId.HuntNpc] = {
        open_func = function(func_id, sub_func, cfg, task_id, pass_id)
            local task_cfg = config.task[task_id] or {}
            local dialog_id = nil
            for _,v in ipairs(task_cfg.finish_cond or {}) do
            	if v[1]=="talk" then
            		dialog_id = v[2]
            		break
            	end
            end

            if dialog_id then
	            local main_role = game.Scene.instance:GetMainRole()
	            main_role:GetOperateMgr():DoTalkToNpc(task_id, dialog_id)
	        end
        end,
        check_open_func = function()
            return true
        end,
        check_visible_func = function()
            return true
        end,
    },

    [game.OpenFuncId.HuntMonster] = {
        open_func = function(func_id, sub_func, cfg, task_id)
            local task_cfg = config.task[task_id]
            local kill_cfg = nil
            for _,v in ipairs(task_cfg.finish_cond or {}) do
            	if v[1] == "kill_mon" then
            		kill_cfg = v
            		break
            	end
            end

            if kill_cfg then
            	local scene_id = kill_cfg[3]
            	local monster_id = math.floor(kill_cfg[2]/100)
            	local kill_num = kill_cfg[2] - monster_id*100

	            local main_role = game.Scene.instance:GetMainRole()
	            main_role:GetOperateMgr():DoHangMonster(scene_id, monster_id, kill_num)
	        end
	        
        end,
        check_open_func = function()
            return true
        end,
        check_visible_func = function()
            return true
        end,
    },

    [game.OpenFuncId.ChosePet] = {
    	open_func = function(func_id, sub_func, cfg, task_id)
            local task_cfg = config.task[task_id]
            local actived_cfg = nil
            for _,v in ipairs(task_cfg.finish_cond or {}) do
            	if v[1] == "actived_pets" then
            		actived_cfg = v
            		break
            	end
            end

            if actived_cfg then
            	game.MainUICtrl.instance:OpenChosePetView()
	        end	        
        end,
        check_open_func = function()
            return true
        end,
        check_visible_func = function()
            return true
        end,

	},

	[game.OpenFuncId.Fighting] = {
		open_func = function()
			game.MainUICtrl.instance:SwitchToFighting()
		end,
		check_visible_func = function()
            return false
        end,
	},
		
	[game.OpenFuncId.MainCity] = {
		open_func = function()
			game.MainUICtrl.instance:SwitchToMainCity()
		end,
		check_visible_func = function()
            return false
        end,
	},

	[game.OpenFuncId.Role] = {
		open_func = function(func_id, sub_func)							  
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/btn_role"})
			game.RoleCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func)
			return game.RoleCtrl.instance:GetHonorTipState()
		end,

		sub_func = {

		},

		red_events = {
			game.RoleEvent.HonorUpgrade,
			game.SceneEvent.UpdateEnterSceneInfo,
			game.CarbonEvent.OnDungInfo,
			game.BagEvent.BagItemChange,
		},
	},

	[game.OpenFuncId.Forging] = {
		open_func = function()
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/btn_foundry"})
			game.FoundryCtrl.instance:OpenView()
		end,

		check_red_func = function()
			local t = game.FoundryCtrl.instance:CheckEquipHd()
			return t
		end,

		red_events = {
			game.FoundryEvent.MainUIRedpoint,
		},
	},

	[game.OpenFuncId.Pet] = {
		open_func = function()
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/btn_pet"})
			game.PetCtrl.instance:OpenView()
		end,

		check_red_func = function()
			return false
		end,

		check_open_tips = function(func_id, sub_func, cfg)
			local open_cond = cfg.open_cond
			if #open_cond > 0 then
				game.GameMsgCtrl.instance:PushMsg(string.format(config.words[4989], open_cond[1][2], cfg.name))
			end
		end,
	},

	[game.OpenFuncId.Bag] = {
		open_func = function()
			game.BagCtrl.instance:OpenView()
		end,

		check_red_func = function()
			return (game.test_bag_red==true)
		end,

		red_events = {
			game.TestEvent.TestBagRed,
		},

	},

	[game.OpenFuncId.GoldShop] = {
		open_func = function()
			game.ShopCtrl.instance:OpenViewByShopId(1)
		end,

		check_red_func = function()
			return false
		end,
	},

	[game.OpenFuncId.EquipShop] = {
		open_func = function()
			game.ShopCtrl.instance:OpenView(1001)
		end,

		check_red_func = function()
			return false
		end,
	},

	[game.OpenFuncId.Mail_Main] = {
		open_func = function()
			game.MailCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return not game.MailCtrl.instance:IsAllRead()
		end,

		red_events = {
			game.MailEvent.RefreshView,
		},
	},

	[game.OpenFuncId.DailyTask] = {
		open_func = function()
			game.DailyTaskCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Friend] = {
		open_func = function()
			game.SwornCtrl.instance:OpenHomeView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			local data = game.FriendCtrl.instance:GetData()
			local flag = data:CheckRedPoint()
			return flag
		end,

		red_events = {
			game.FriendEvent.RefreshRoleIdList,
		},
	},

	[game.OpenFuncId.Carbon] = {
		open_func = function()
			game.CarbonCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.RoleMount] = {
		open_func = function()
			game.RoleCtrl.instance:OpenView(3)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.RoleWing] = {
		open_func = function()
			game.RoleCtrl.instance:OpenView(4)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.ShenWeapon] = {
		open_func = function()
			game.FoundryCtrl.instance:OpenGodWeaponView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,

		check_visible_func = function ()
			local t = game.FoundryCtrl.instance:CheckGetGodweapon()
			return t
		end,

		update_event = {
			game.FoundryEvent.UpdateGodweaponInfo,
		},
	},

	[game.OpenFuncId.HideWeapon] = {
		open_func = function()
			game.FoundryCtrl.instance:OpenHideWeaponView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.PetPossessed] = {
		open_func = function()
			game.PetCtrl.instance:OpenView(3)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.PetIntelligent] = {
		open_func = function()
			game.PetCtrl.instance:OpenView(4)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.PetSkill] = {
		open_func = function()
			game.PetCtrl.instance:OpenView(2)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.RoleSkill] = {
		open_func = function()
			game.RoleCtrl.instance:OpenView(2)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return game.SkillCtrl.instance:CheckSkillUpgradeRedPoint()
		end,

		red_events = {
			game.MoneyEvent.Change,
			game.SkillEvent.SkillUpgrade,
			game.SkillEvent.SkillOneKeyUp,
			game.SkillEvent.SkillNew,
		},
	},

	[game.OpenFuncId.FoundryCuilian] = {
		open_func = function()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.FoundryDuanlian] = {
		open_func = function()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.FoundryJinglian] = {
		open_func = function()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Carbon_SiJueZhuang] = {
		open_func = function()
			game.CarbonCtrl.instance:OpenView(2)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Carbon_Material] = {
		open_func = function()
			game.CarbonCtrl.instance:OpenView(1)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.ZhenLongQiJu] = {
		open_func = function()
			game.DailyTaskCtrl.instance:OpenView(1)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Boss] = {
		open_func = function()

		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Marry] = {
		open_func = function()
			game.MarryCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Hero] = {
		open_func = function()
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/btn_hero"})
			game.HeroCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return game.HeroCtrl.instance:GetTipState()
		end,

		red_events = {
			game.HeroEvent.HeroActive,
			game.BagEvent.BagItemChange,
		},
	},

	[game.OpenFuncId.OpenActivity] = {
		open_func = function()

		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.BenifitHall] = {
		open_func = function(func_id, sub_func, cfg, ...)
			game.RewardHallCtrl.instance:OpenView(...)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return game.RewardHallCtrl.instance:GetViewTipsState()
		end,

		red_events = {
			game.RewardHallEvent.OnSevenLoginInfo,
            game.RewardHallEvent.OnSevenLoginGet,
			game.RewardHallEvent.UpdateAccInfo,
			game.RewardHallEvent.UpdateSignInfo,
			game.RewardHallEvent.UpdateOnlineInfo,
			game.RewardHallEvent.UpdateOnlinePray,
			game.RewardHallEvent.UpdateLevelGift,
			game.RewardHallEvent.UpdateGetBackInfo,
			game.RewardHallEvent.UpdatePayBackInfo,
			game.RewardHallEvent.OnDividendLuckyInfo,
            game.RewardHallEvent.OnDividendLvGet,
            game.RewardHallEvent.OnDividendStoneChange,
			game.RewardHallEvent.OnDividendLuckyInfo,
			game.RewardHallEvent.StopDividendAct,
		},
	},

	[game.OpenFuncId.LuckyTruning] = {
		open_func = function()
			game.LuckyTruningCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.DailyFirstCharge] = {
		open_func = function()

		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Auction] = {
		open_func = function()
			game.AuctionCtrl.instance:CsAuctionInfo(true)
		end,
		check_red_func = function()
			local data = game.AuctionCtrl.instance:GetData()
			local flag = data:CheckRedPoint()
			return flag
		end,

		red_events = {
			game.AuctionEvent.UpdateInfo,
		},
	},

	[game.OpenFuncId.Exterior] = {
		open_func = function(func_id, sub_func, cfg, ...)
			game.ExteriorCtrl.instance:OpenView(...)
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Skill] = {
		open_func = function()
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/btn_skill"})
			game.SkillCtrl.instance:OpenView()
		end,

		check_red_func = function()
			return game.SkillCtrl.instance:CheckRedPoint()
		end,

		red_events = {
			game.MoneyEvent.Change,
			game.SkillEvent.SkillUpgrade,
			game.SkillEvent.SkillOneKeyUp,
			game.SkillEvent.SkillNew,
		},
	},
	
	[game.OpenFuncId.LakeExp] = {
		open_func = function()
			game.LakeExpCtrl.instance:OpenView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Rank] = {
		open_func = function()
			game.RankCtrl.instance:OpenRankView()
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Market] = {
		open_func = function()
			game.MarketCtrl.instance:OpenView()
		end,

		check_open_func = function()
            return true
        end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Recharge] = {
		open_func = function()
			game.RechargeCtrl.instance:OpenView()
		end,

		check_open_func = function()
            return true
        end,

		check_red_func = function(func_id, sub_func, cfg)
			local recharge_ctrl = game.RechargeCtrl.instance
			return recharge_ctrl:CheckGiftRed() or recharge_ctrl:CheckWeekRed()
		end,

		red_events = {
			game.RechargeEvent.OnConsumeInfo,
            game.RechargeEvent.OnGetCharge,
			game.VipEvent.UpdateCaculateRechargeMoney,
			game.RechargeEvent.OnGetConsume,
            game.RechargeEvent.OnConsumeChange,
            game.RechargeEvent.OnConsumeRoraty,
            game.BagEvent.BagItemChange,
		},
	},

	[game.OpenFuncId.FirstRecharge] = {
		open_func = function()
			game.RechargeCtrl.instance:OpenFirstRechargeView()
		end,

		check_open_func = function()
            return true
        end,

		check_red_func = function(func_id, sub_func, cfg)
			return (game.RechargeCtrl.instance:GetFlag()==1)
		end,

		check_visible_func = function(func_id, sub_func, cfg)
			return game.OpenFuncCtrl.instance:IsFuncVisible(func_id) and (game.RechargeCtrl.instance:CheckShowFirstRecharge())
		end,

		red_events = {
			game.RechargeEvent.OnConsumeInfo,
			game.RechargeEvent.OnConsumeFlagChange,
		},
	},

	[game.OpenFuncId.ActivityHall] = {
		open_func = function()
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_top/func_group_3/btn_func_1"})
			game.ActivityMgrCtrl.instance:OpenActivityHallView()
		end,

		check_open_func = function()
            return true
        end,

		check_red_func = function(func_id, sub_func, cfg)
			return game.ActivityMgrCtrl.instance:CheckHd()
		end,

		red_events = {
			game.ActivityEvent.MainUIRedpoint,
		},
	},

	[game.OpenFuncId.Arena] = {
		open_func = function()
			game.ArenaCtrl.instance:OpenArenaView(1)
		end,

		check_open_func = function()
            return true
        end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.Guild] = {
		open_func = function()
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/btn_guild"})
			game.GuildCtrl.instance:OpenView()
		end,

		check_open_func = function()
            return true
        end,

		check_red_func = function(func_id, sub_func, cfg)
			return false
		end,
	},

	[game.OpenFuncId.BlackSociety] = {
		open_func = function()
			game.SocietyCtrl.instance:OpenView()
		end,

		check_open_func = function()
            return true
        end,

        check_visible_func = function()
        	local t = game.SocietyCtrl.instance:CheckActOpen()
        	return t
        end,

		check_red_func = function(func_id, sub_func, cfg)
			return game.SocietyCtrl.instance:CheckAllHd()
		end,

		red_events = {
			game.SocietyEvent.RefreshMainUI
		},

		update_event = {
			game.SocietyEvent.RefreshMainUI,
		},
	},

	[game.OpenFuncId.GodweaponPiece] = {
		open_func = function()
			game.FoundryCtrl.instance:OpenGodWeaponCollectView()
		end,

		check_open_func = function()
            return true
        end,

        check_visible_func = function()
        	return not game.OpenFuncCtrl.instance:IsFuncOpened(game.OpenFuncId.ShenWeapon)
        end,

		check_red_func = function(func_id, sub_func, cfg)
			local t = game.FoundryCtrl.instance:CheckGodweaponChipHd()
			return t
		end,

		check_show_text = function ()
			return game.FoundryCtrl.instance:GetGodweaponChipText()
		end,

		update_event = {
			game.FoundryEvent.GodweaponCollect,
		},

		red_events = {
			game.FoundryEvent.GodweaponCollect,
		},
	},

	[game.OpenFuncId.Feedback] = {
		open_func = function()
			game.FeedbackCtrl.instance:OpenView()
		end,

		check_open_func = function()
			return true
		end,

		check_red_func = function(func_id, sub_func, cfg)
			return game.FeedbackCtrl.instance:TipState()
		end,
	},

	[game.OpenFuncId.WeaponSoul] = {
		open_func = function(func_id, sub_func, cfg, ...)
			game.WeaponSoulCtrl.instance:OpenView(...)
		end,

		check_open_func = function()
			return true
		end,

		check_red_func = function()
			local t = game.WeaponSoulCtrl.instance:CheckRedPoint()
			return t
		end,

		red_events = {
			game.WeaponSoulEvent.RefreshMainUI,
		},
	},

	[game.OpenFuncId.Sworn] = {
		open_func = function()
			game.SwornCtrl.instance:OpenView()
		end,

		check_open_func = function(func_id, sub_func, cfg)
			local role_lv = game.RoleCtrl.instance:GetRoleLevel()
			local open_lv = config.sworn_base.open_lv
			if role_lv < open_lv then
				game.GameMsgCtrl.instance:PushMsg(open_lv .. config.words[2101])
				return false
			end
			return true
		end,
	},

	[game.OpenFuncId.Mentor] = {
		open_func = function()
			game.MentorCtrl.instance:OpenView()
		end,

		check_open_func = function(func_id, sub_func, cfg)
			local role_lv = game.RoleCtrl.instance:GetRoleLevel()
			local open_lv = config.mentor_base.open_lv
			if role_lv < open_lv then
				game.GameMsgCtrl.instance:PushMsg(open_lv .. config.words[2101])
				return false
			end
			return true
		end,
	},

	[game.OpenFuncId.DragonDesign] = {
		open_func = function()
			game.DragonDesignCtrl.instance:OpenView()
		end,

		check_open_func = function()
			return true
		end,

		check_red_func = function()
			return false
		end,

		red_events = {
			game.WeaponSoulEvent.RefreshMainUI,
		},
	},

	[game.OpenFuncId.Achieve] = {
		open_func = function()
			game.AchieveCtrl.instance:OpenView()
		end,

		check_red_func = function()
			return game.AchieveCtrl.instance:GetAchieveTips()
		end,

		red_events = {
			game.AchieveEvent.AchieveInfo,
		},
	},
}

local func_ctrl = game.OpenFuncCtrl.instance
local default_func_tb = {
	click_func = function(func_id, sub_func, cfg)
		-- if not cfg.check_open_func(func_id, sub_func, cfg) then
		-- 	cfg.check_open_tips(func_id, sub_func, cfg)
		-- 	return
		-- end

		local open_list = func_ctrl:GetOpenList(func_id)
		if #open_list >= 2 then
			func_ctrl:OpenFolderView(open_list)
			return
		end

		local func_id = (open_list[1] and open_list[1] or func_id)

		cfg.open_func(func_id)
	end,
	open_func = function(func_id, sub_func, cfg)

	end,
	check_open_func = function(func_id, sub_func, cfg)
		return func_ctrl:IsFuncOpened(func_id)
	end,
	check_open_tips = function(func_id, sub_func, cfg)

	end,
	check_visible_func = function(func_id, sub_func, cfg)
		return func_ctrl:IsFuncVisible(func_id)
	end,
	check_red_func = function(func_id, sub_func, cfg)
		return false
	end,	
	update_event = {},
	check_show_text = function()
		return ""
	end,
}

local default_attr_tb = {
	sub_func = {},
	red_events = {},
	red_delta = 0.1,
}

local et = {}
for _,v in pairs(func_config) do
	local cfg = sys_id_config[v.id] or et
	for ck,cv in pairs(default_func_tb) do
		local func = cfg[ck] or cv

		if type(func) == "function" then
			v[ck] = function(...)
				return func(v.id, v.sub_func, v, ...)
			end
		else
			v[ck] = func
		end
	end

	for ck,cv in pairs(default_attr_tb) do
		v[ck] = cfg[ck] or cv
	end
end

return func_config