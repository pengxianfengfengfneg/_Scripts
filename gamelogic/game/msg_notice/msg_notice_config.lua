local MsgNoticeType = game.MsgNoticeType
--[[
	check_enable_func		是否可以前往
	check_visible_func		前往按钮是否可见
]]
local MsgNoticeConfig = {
	[1002] = {
		click_func = function(data, params)
			local killer_id = tonumber(params[3])
			if not game.FriendCtrl.instance:IsMyEnemy(killer_id) then
				game.FriendCtrl.instance:CsFriendSysAddEnemy(killer_id)
			end
		end,
	},
	[game.MsgNoticeId.FindMentor] = {
		click_func = function(data, params)
			game.MentorCtrl.instance:OpenRegisterView(2)
		end,
		check_visible_func = function()
			return true
		end,
	},
	[game.MsgNoticeId.FindMentorSp] = {
		click_func = function(data, params)
			game.MentorCtrl.instance:OpenRegisterView(2)
		end,
		check_visible_func = function()
			return true
		end,
	},
}

local default_func_tb = {
	click_func = function(data, params)
		if data.type == MsgNoticeType.System then
			local cfg = config.goods_get_way[data.get_way]
			if cfg then
				cfg.click_func()
			end
			return
		end

		if data.type == MsgNoticeType.Activity then
			local act_id = tonumber(params[3])
			local act_info = game.ActivityMgrCtrl.instance:GetActivity(act_id)
			if act_info then
				local cfg = game.ActivityLinkFunc[act_id]
				if cfg then
					cfg.click_func()
				end
			end
			return
		end

		if data.type == MsgNoticeType.Social then

		end
	end,
	check_enable_func = function(data)
		return true
	end,
	check_visible_func = function(data)
		if data.type == MsgNoticeType.System then
			return (data.get_way>0)
		end

		if data.type == MsgNoticeType.Activity then
			
		end

		if data.type == MsgNoticeType.Social then

		end
		return true
	end,
	check_lv_func = function(data)
		local main_role_lv = game.Scene.instance:GetMainRoleLevel()
		return (main_role_lv>=data.lv)
	end,
}

local _et = {}
for k,v in pairs(config.msg_notice or _et) do
	local cfg = MsgNoticeConfig[k] or _et
	for ck,cv in pairs(default_func_tb) do
		v[ck] = cfg[ck] or cv
	end
end

return config.msg_notice