local GuildArenaFightViewFirst = Class(game.BaseView)

function GuildArenaFightViewFirst:_init(ctrl)
	self._package_name = "ui_guild_arena"
    self._com_name = "fight_view_first"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1
    self._view_level = game.UIViewLevel.Standalone
end

function GuildArenaFightViewFirst:OpenViewCallBack()

	self.ctrl:CsJoustsHallInfo()

	self:BindEvent(game.GuildArenaEvent.UpdateViewInfo, function(data)
		self:UpdateInfo(data)
	end)

	self:BindEvent(game.GuildArenaEvent.UpdateStageChange, function(data)
		self:UpdateStageInfo(data)
	end)

	-- self._layout_objs["score_btn"]:AddClickCallBack(function()
	-- 	self.ctrl:OpenScoreAwardView()
 --    end)

	-- self._layout_objs["score_rank_btn"]:AddClickCallBack(function()
	-- 	self.ctrl:OpenScoreRankView()
 --    end)

 --    self._layout_objs["quit_btn"]:AddClickCallBack(function()
 --    	self.ctrl:CsJoustsHallLeaveB()
 --    end)
end

function GuildArenaFightViewFirst:CloseViewCallBack()
	self:DelTimer()
end

local get_state_str = function(stage)
	if stage == 1 then
		return config.words[5204]
	elseif stage == 2 then
		return config.words[5204]
	elseif stage == 3 then
		return config.words[5204]
	elseif stage == 4 then
		return config.words[5205]
	elseif stage == 5 then
		return config.words[5208]
	elseif stage == 6 then
		return config.words[5206]
	elseif stage == 7 then
		return config.words[5207]
	elseif stage == 8 then
		return config.words[5204]
	elseif stage == 9 then
		return config.words[5205]
	elseif stage == 10 then
		return config.words[5208]
	end
end

function GuildArenaFightViewFirst:UpdateInfo(data)
	self._layout_objs["score_txt"]:SetText(data.score)
	self._layout_objs["rank_txt"]:SetText(data.target_rank)

	local role_lv = game.Scene.instance:GetMainRoleLevel() or 1
	local exp = config.level[role_lv].jousts_battle_add_exp
	self._layout_objs["exp_award_txt"]:SetText(exp)
end

--每轮中的阶段有改变(首次也会通知)
function GuildArenaFightViewFirst:UpdateStageInfo(data)

	--前三轮战场信息
	local first_fight_data = data

	local end_time = data.end_time
	local cur_time = global.Time:GetServerTime()
	local cfg_time = end_time - cur_time
	local str = get_state_str(data.stage)

	self:DelTimer()
	self.timer = global.TimerMgr:CreateTimer(1,
		function()

			if cfg_time <= 0 then
				self:DelTimer()
			else
				cfg_time = cfg_time - 1
				self._layout_objs["txt1"]:SetText(string.format(str, cfg_time))
			end
		end)

	--毒瘴开启
	if data.stage == 5 then
		self._layout_objs["du_img"]:SetSprite("ui_guild_arena", "yw_01")
		self._layout_objs["n21"]:SetText(config.words[5210])

		local scene_logic = game.Scene.instance:GetSceneLogic()
		scene_logic:SetPoisonVisibel(true)
	else
		self._layout_objs["du_img"]:SetSprite("ui_guild_arena", "yw_02")		
		self._layout_objs["n21"]:SetText(config.words[5209])
		local scene_logic = game.Scene.instance:GetSceneLogic()
		scene_logic:SetPoisonVisibel(false)
	end
end

function GuildArenaFightViewFirst:DelTimer()
	if self.timer then
		global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
	end
end

return GuildArenaFightViewFirst