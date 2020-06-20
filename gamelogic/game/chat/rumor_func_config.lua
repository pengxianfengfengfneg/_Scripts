local rumor_func_config = config.rumor_func

local unserialize = unserialize

--[[
	click_func 			跳转函数
	parse_func			解析函数（对应超链接的解析函数）
]]
local _id_config = {
	-- 加入帮会
	[1000] = {
		click_func = function(func_id, param1, param2, guild_id)
			if not game.OpenFuncCtrl.instance:IsFuncOpened(game.OpenFuncId.Guild) then
				game.GameMsgCtrl.instance:PushMsg(config.words[6007])
				return
			end
			local guild_ctrl = game.GuildCtrl.instance
			if guild_ctrl:IsGuildMember() then
				game.GameMsgCtrl.instance:PushMsg(config.words[6008])
			else
				if guild_ctrl:CanJoinGuild() then
					guild_ctrl:SendGuildJoinReq(guild_id)
				end
			end
        end,
    },

    -- 我要结婚
    [1001] = {
        click_func = function(func_id, param1, param2, param3)
            game.MarryCtrl.instance:OpenView()
        end,
    },

    -- 宠物展示
    [1007] = {
	    click_func = function(func_id, param)
			local info = unserialize(param)
			game.MarketCtrl.instance:OpenPetInfoView(info)
	    end,
	},

	-- 申请加入队伍
	[1008] = {
		click_func = function(func_id, param1, param2, param3)
			game.MakeTeamCtrl.instance:SendTeamApplyFor(tonumber(param3))
		end,
	},

	-- 帮会任务答题求助
	[1009] = {
		click_func = function(func_id, params)
			local data = unserialize(params)
			game.DailyTaskCtrl.instance:TryAssistExamine(data)
		end,

		parse_func = function(params)
	    	local func_id = params[1]
	    	local func_cfg = config.rumor_func[func_id]

			local herf_params = table.concat(params,"|")
			local data = unserialize(params[2])
			local quest_cfg = config.examine_bank[data.quest_id]
			local question = quest_cfg and quest_cfg.question or ""
			local content = string.format("<font color='#fef4ad'>%s</font>[<a href='%s'>%s</a>]", config.words[5155], herf_params, question)

	        return string.format("<font color='#5298e3'>%s</font>", content)
		end,
	},

	-- 帮会任务答题协助
	[1010] = {
		click_func = function(func_id, param1, param2, param3)
			
		end,

		parse_func = function(params)
			local func_id = params[1]
			local func_cfg = config.rumor_func[func_id]
			
			local data = unserialize(params[2])
			local quest_cfg = config.examine_bank[data.quest_id]
			local answer = quest_cfg and quest_cfg["options"..quest_cfg.answer] or ""
			local content = string.format(config.words[5158], data.name, answer)

	        return string.format("<font color='#%s'>%s</font>", func_cfg.color, content)
		end,
	},

	-- 聊天查看物品
	[1011] = {
		click_func = function(func_id, params)
			local info = unserialize(params)
			game.BagCtrl.instance:OpenTipsView(info, nil, true, true)
		end,
	},

	-- 聊天跳转坐标
	[1012] = {
		click_func = function(func_id, params)
			local info = unserialize(params)
			local main_role = game.Scene.instance:GetMainRole()

			local ux,uy = game.LogicToUnitPos(info.lx, info.ly)
			main_role:GetOperateMgr():DoGoToScenePos(info.id, ux, uy, nil, 0)
		end,
	},

	-- 帮会红包
	[1013] = {
		click_func = function(func_id, params)
			game.LuckyMoneyCtrl.instance:OpenView()
		end,
	},

	-- 跑环求助
	[1014] = {
		click_func = function(func_id, name, item_name, cur_times, max_times, role_id, task_id, help_flag)
			local role_id = tonumber(role_id)
			local main_role_id = game.Scene.instance:GetMainRoleID()
			if role_id == main_role_id then
				-- 自己不能协助自己
				game.GameMsgCtrl.instance:PushMsg(config.words[6311])
				return
			end

			if game.ChatCtrl.instance:IsDoneCircleHelp(help_flag) then
				game.GameMsgCtrl.instance:PushMsg(config.words[6312])
				return
			end

			local task_id = tonumber(task_id)
			local task_cfg = game.TaskCtrl.instance:GetTaskCfg(task_id)
			if task_cfg then
				local info = {
					item_id = task_cfg.costs[1][1],
					role_id = role_id,
					task_id = task_id,
					help_flag = tonumber(help_flag),
				}
				game.TaskCtrl.instance:OpenCircleTaskHelpSelectView(info)
			end
		end,
	},
	
	-- 亲传拜师贴
	[1016] = {
		click_func = function(func_id, gender, time, type, fight, notice)
			local post_info = {}
			post_info.gender = tonumber(gender)
			post_info.time = tonumber(time)
			post_info.type = tonumber(type)
			post_info.fight = fight
			post_info.notice = notice
			game.MentorCtrl.instance:OpenPostView(post_info)
		end,
	}
}

for _,v in pairs(rumor_func_config) do
	local cfg = _id_config[v.id]
	if cfg then
		v.click_func = cfg.click_func
		v.parse_func = cfg.parse_func
	end
end

return rumor_func_config