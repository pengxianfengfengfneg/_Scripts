local CarbonCtrl = Class(game.BaseCtrl)

function CarbonCtrl:_init()
	if CarbonCtrl.instance ~= nil then
		error("CarbonCtrl Init Twice!")
	end
	CarbonCtrl.instance = self
	
	self.data = require("game/carbon/carbon_data").New()
	self.chapter_reward_view = require("game/carbon/chapter_reward_view").New(self)
	self.first_reward_view = require("game/carbon/first_reward_view").New(self)
	self.hero_trial_view = require("game/carbon/hero_trial_view").New(self)
	self.carbon_wipe_view = require("game/carbon/carbon_wipe_view").New(self)
	self.guild_team_carbon_view = require("game/carbon/guild_team_carbon_view").New(self)
	self.guild_team_reward_preview = require("game/carbon/guild_team_reward_preview").New(self)
	self.anger_boss_view = require("game/carbon/anger_boss_view").New(self)

	self:RegisterAllProtocal()
	self:RegisterAllEvents()

	self.auto_chan = false
end

function CarbonCtrl:_delete()
	self.data:DeleteMe()
	self.data = nil

	if self.carbon_view then
		self.carbon_view:DeleteMe()
		self.carbon_view = nil
	end

	if self.succ_result_view then
		self.succ_result_view:DeleteMe()
		self.succ_result_view = nil
	end

	if self.fail_result_view then
		self.fail_result_view:DeleteMe()
		self.fail_result_view = nil
	end

	if self.carbon_fight_view then
		self.carbon_fight_view:DeleteMe()
		self.carbon_fight_view = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	self.chapter_reward_view:DeleteMe()
	self.first_reward_view:DeleteMe()
	self.hero_trial_view:DeleteMe()
	self.carbon_wipe_view:DeleteMe()
	self.guild_team_carbon_view:DeleteMe()
	self.guild_team_reward_preview:DeleteMe()
	self.anger_boss_view:DeleteMe()

	CarbonCtrl.instance = nil
end

function CarbonCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(25202, "DungInfoResponse")
	self:RegisterProtocalCallback(25204, "DungResetResponse")
	self:RegisterProtocalCallback(25206, "DungWipeResponse")
	self:RegisterProtocalCallback(25208, "DungGetFirstRwd")
	self:RegisterProtocalCallback(25210, "DungGetChapterRwd")
	self:RegisterProtocalCallback(25212, "DungSingleInfoResponse")
	self:RegisterProtocalCallback(25222, "DungEnterResponse")
	self:RegisterProtocalCallback(25226, "DungLeaveResponse")
	self:RegisterProtocalCallback(25227, "DungResultResponse")

	self:RegisterProtocalCallback(25224, "OnDungEnterTeam")
	self:RegisterProtocalCallback(25228, "OnDungData")
	self:RegisterProtocalCallback(25229, "OnDungTeamStatus")

	self:RegisterProtocalCallback(25214, "ScDungHeroInfo")

	self:RegisterProtocalCallback(25230, "OnDungRefreshMon")

	
end

function CarbonCtrl:GetData()
	return self.data
end

function CarbonCtrl:OpenView(template_index)
	--if not self.carbon_view then
	--	self.carbon_view = require("game/carbon/carbon_view").New(self)
	--end
	--self.carbon_view:Open(template_index)
end

function CarbonCtrl:CloseView()
	if self.carbon_view then
		self.carbon_view:DeleteMe()
		self.carbon_view = nil
	end
end

function CarbonCtrl:OpenSuccResultView(info)
	if not self.succ_result_view then
		self.succ_result_view = require("game/carbon/carbon_succ_result_view").New(self)
	end
	self.succ_result_view:Open(info)
end

function CarbonCtrl:OpenFailResultView(info)
	if not self.fail_result_view then
		self.fail_result_view = require("game/carbon/carbon_fail_result_view").New(self)
	end
	self.fail_result_view:Open(info)
end

function CarbonCtrl:OpenFightView()
	if not self.carbon_fight_view then
		self.carbon_fight_view = require("game/carbon/carbon_fight_view").New(self)
	end
	self.carbon_fight_view:Open()
end

function CarbonCtrl:CloseFightView()
	if self.carbon_fight_view then
		self.carbon_fight_view:DeleteMe()
		self.carbon_fight_view = nil
	end
end

function CarbonCtrl:RegisterAllEvents()
    local events = {
        {game.SceneEvent.ChangeScene, handler(self, self.ChangeScene)},
        {game.LoginEvent.LoginSuccess, handler(self, self.CsDungHeroInfo)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

--所有副本信息查询
function CarbonCtrl:DungInfoReq()
	self:SendProtocal(25201,{})
end

function CarbonCtrl:DungInfoResponse(data)
	self.data:SetDungeData(data)
	self:FireEvent(game.CarbonEvent.OnDungInfo)
end

--重置
function CarbonCtrl:DungResetReq(dungId)
	self:SendProtocal(25203,{dung_id = dungId})
end

function CarbonCtrl:DungResetResponse(data)
	self.data:UpdateDungeData(data)
end

--请求扫荡
function CarbonCtrl:DungWipeReq(dungId, preferLv)
	self:SendProtocal(25205,{dung_id = dungId})
	self.enter_carbon_info = {dung_id = dungId, prefer_lv = preferLv}
end

function CarbonCtrl:DungWipeResponse(data)
	self.data:UpdateDungeData(data)

	self:OpenWipeView(data)

	self:FireEvent(game.CarbonEvent.RefreshMaterial, data)
end

--单个副本信息查询
function CarbonCtrl:DungSingleInfoReq(dungId)
	self:SendProtocal(25211,{dung_id = dungId})
end

function CarbonCtrl:DungSingleInfoResponse(data)
	self.data:UpdateSingleDungeInfo(data)
end

function CarbonCtrl:DungEnterReq(dungId, preferLv)
	self:SendProtocal(25221, {dung_id = dungId, prefer_lv = preferLv})
	self.enter_carbon_info = {dung_id = dungId, prefer_lv = preferLv}
end

function CarbonCtrl:DungEnterResponse(data)
	self.hero_trial_view:Close()
end

function CarbonCtrl:GetEnterCarbonInfo()
	return self.enter_carbon_info
end

function CarbonCtrl:DungLeaveReq()
	self:SendProtocal(25225,{})
end

function CarbonCtrl:DungLeaveResponse()
	if self.leave_cd_timer then
		global.TimerMgr:DelTimer(self.leave_cd_timer)
		self.leave_cd_timer = nil
	end
end

local wave_num = 5
function CarbonCtrl:GetDungeWaveAward(now_lv)

	local chapt_num = math.ceil(now_lv/wave_num)
	local wave = now_lv - (chapt_num-1)*wave_num

	return chapt_num, wave
end

function CarbonCtrl:GetDungeonChatWave(dunge_id, now_lv)

	local now_lv = now_lv + 1
	if dunge_id ~= 300 then
		return 1, 1
	else
		return self:GetDungeWaveAward(now_lv)
	end
end

function CarbonCtrl:IsTeamCarbon(carbon_id)
	local cfg = config.dungeon[carbon_id]
	if not cfg then
		return false
	end

	return (cfg.dun_type>50 and cfg.npc>0)
end

function CarbonCtrl:NeedShowResult(carbon_id)
	local cfg = config.dungeon[carbon_id]
	if cfg and cfg.dun_type == game.CarbonType.HeroTrialCarbon then
		return true
	else
		return false
	end
end

function CarbonCtrl:IsDungeonScene(scene_id)
	local dun_id = config_help.ConfigHelpDungeon.GetDunForScene(scene_id)
	return (dun_id~=nil)
end

function CarbonCtrl:DungResultResponse(data)
	self:FireEvent(game.CarbonEvent.OnDungResult, data)
	
	-- if self:IsTeamCarbon(data.dung_id) then
	-- 	-- 组队副本不弹出结算
	-- 	return
	-- end

	local scene_id = game.Scene.instance:GetSceneID()
	if not self:IsDungeonScene(scene_id) then
		return
	end

	if self:NeedShowResult(data.dung_id) == false then
		local count_down = config.dungeon_lv[data.dung_id][data.level].end_wait_time
		self.leave_cd_timer = global.TimerMgr:CreateTimer(1, function()
			if count_down <= 0 then
				self:DungLeaveReq()
				self.leave_cd_timer = nil
				return true
			else
				game.GameMsgCtrl.instance:PushMsg(string.format(config.words[1424], count_down))
				count_down = count_down - 1
			end
		end)
		return
	end

	local is_succ = data.succeed == 1
	self.data:SetAutoStart(data.dung_id, is_succ)
	if is_succ then
		self:OpenSuccResultView(data)
	else
		self:OpenFailResultView(data)
	end

	self.sjz_carbon_success = nil
	if is_succ then
		local dunge_type = config.dungeon[data.dung_id].dun_type
		if dunge_type == game.CarbonType.SjzCarbon then
			self.sjz_carbon_success = true
		end
	end
end

function CarbonCtrl:SendDungEnterTeam(dung_id)
	self:SendProtocal(25223, {dung_id = dung_id})

	--self.enter_carbon_info = {dung_id = dung_id, prefer_lv = 1}
end

function CarbonCtrl:OnDungEnterTeam(data)
	--[[
		dung_id__H  
	]]
	self.guild_team_carbon_view:Close()
end

function CarbonCtrl:OnDungData(data)
	--[[
		"dung_id__H",
        "level__H",
        "wave__C",
        "begin_time__I",
        "members__T__id@L##assist@C",
	]]
	self.enter_dun_id = data.dung_id

	self.data:OnDungData(data)

	self:FireEvent(game.CarbonEvent.OnDungData, data)
end

function CarbonCtrl:OnDungTeamStatus(data)
	--[[
		"status__T__role_id@L##name@s##distance@C##level@C##assist@C##times@C##alive@C##online@C",
	]]

	self.data:OnDungTeamStatus(data)

	self:FireEvent(game.CarbonEvent.UpdateDunTeamState)

	game.MakeTeamCtrl.instance:OpenTeamStateView()
end

function CarbonCtrl:GetDunTeamStateData()
	return self.data:GetDunTeamStateData()
end

function CarbonCtrl:GetDunFightData()
	return self.data:GetDunFightData()
end

function CarbonCtrl:ResetDunFightData()
	self.data:ResetDunFightData()
end

function CarbonCtrl:SetAutoChan(val)
	self.auto_chan = val
end

function CarbonCtrl:GetAutoChan()
	return self.auto_chan
end

function CarbonCtrl:ChangeScene(to_scene_id, from_scene_id)
	local enter_dun_id = self.enter_dun_id
	self.enter_dun_id = nil

	if self:IsTeamCarbon(enter_dun_id) then
		-- 组队副本退出 不打开个人副本
		return
	end

	if config.scene[to_scene_id].type == game.SceneType.DungeonScene then
		-- 副本继续下一关 不打开个人副本
		return
	end

	if not from_scene_id then return end
	local scene_type = config.scene[from_scene_id].type
	if scene_type == game.SceneType.DungeonScene then

		local index = 1
		local dunge_type
		local dung_id
		if self.enter_carbon_info then
			dung_id = self.enter_carbon_info.dung_id
			dunge_type = config.dungeon[dung_id].dun_type

			if dunge_type == game.CarbonType.MatrialCarbon then
				index = 1
			elseif dunge_type == game.CarbonType.SjzCarbon then
				index = 3
			elseif dunge_type == game.CarbonType.YanziwuCarbon then
				index = 2
			elseif dunge_type == game.CarbonType.HeroTestCarbon then
				index = 4
			end
		end

		local scene_logic = game.Scene.instance:GetSceneLogic()
		scene_logic:AddSceneStartFunc(function()

			if dunge_type == game.CarbonType.ZlqjCarbon then
				game.DailyTaskCtrl.instance:OpenView()
			else
				self:OpenView(index)
			end
		end)
	end

	-- if not to_scene_id then return end
	-- local scene_type = config.scene[to_scene_id].type
	-- if scene_type ~= game.SceneType.DungeonScene then
	-- 	self:CloseFightView()
	-- end
end

function CarbonCtrl:CheckChanTimesByType(dunge_type, need_times)
	return self.data:CheckChanTimesByType(dunge_type, need_times)
end

function CarbonCtrl:CheckLvWave(dunge_id, need_lv, need_wave)
	return self.data:CheckLvWave(dunge_id, need_lv, need_wave)
end

function CarbonCtrl:OpenRankView(rank_id)

	if not self.rank_view then
		self.rank_view = require("game/carbon/carbon_rank_view").New()
	end

	self.rank_view:Open(rank_id)
end

function CarbonCtrl:CloseRankView()

	if self.rank_view:IsOpen() then
		self.rank_view:Close()
	end
end

function CarbonCtrl:SetAutoStart(id, val)
	self.data:SetAutoStart(id, val)
end

function CarbonCtrl:GetAutoStart(id)
	return self.data:GetAutoStart(id)
end

function CarbonCtrl:SendGetChapterRwd(id, chapter, star)
	self:SendProtocal(25209, {dung_id = id, chapter = chapter, star = star})
end

function CarbonCtrl:DungGetChapterRwd(data)
	self.data:SetChapterRwd(data)
	self:FireEvent(game.CarbonEvent.GetChapterReward, data)
end

function CarbonCtrl:OpenChapterRewardView(dun_id, chapter, star)
	self.chapter_reward_view:Open(dun_id, chapter, star)
end

function CarbonCtrl:GetSjzSuccessFlag()
	return self.sjz_carbon_success
end

function CarbonCtrl:ResetSjzSuccessFlag()
	self.sjz_carbon_success = nil
end

function CarbonCtrl:SendGetFirstRwd(id, level, wave)
	self:SendProtocal(25207, {dung_id = id, level = level, wave = wave})
end

function CarbonCtrl:DungGetFirstRwd(data)
	self.data:SetFirstRwd(data)
	self:FireEvent(game.CarbonEvent.GetFirstReward, data)
end

function CarbonCtrl:OpenFirstRewardView(dun_id, level)
	self.first_reward_view:Open(dun_id, level)
end

function CarbonCtrl:OpenTeamCarbonDailogView()
	
end

function CarbonCtrl:GetDungeDataByID(dun_id)
	return self.data:GetDungeDataByID(dun_id)
end

function CarbonCtrl:GetDungeonData()
	return self.data:GetDungeonData()
end

function CarbonCtrl:OpenHeroTrialView()
	self.hero_trial_view:Open()
end

function CarbonCtrl:OpenWipeView(info)
	self.carbon_wipe_view:Open(info)
end

function CarbonCtrl:GetMaxLv(carbon_id)
	return self.data:GetMaxLv(carbon_id)
end

function CarbonCtrl:OpenGuildTeamCarbonView()
	self.guild_team_carbon_view:Open()
end

function CarbonCtrl:OpenGuildTeamRewardPreview(info, times)
	self.guild_team_reward_preview:Open(info, times)
end

function CarbonCtrl:CsDungHeroInfo()
	self:SendProtocal(25213,{})
end

function CarbonCtrl:ScDungHeroInfo(data)
	self.data:SetHeroDungeInfo(data)
end

--是否显示英雄试炼副本
function CarbonCtrl:CheckHeroDungeVisible(dunge_id)
	local cur_hero_dunge_id = self.data:GetHeroDungeId()
	return dunge_id == cur_hero_dunge_id
end

function CarbonCtrl:OnDungRefreshMon(data)
	--[[
		"wave__C",
        "mons__T__id@L##type@I##x@I##y@I##special@C",
	]]
	
	for _,v in ipairs(data.mons) do
		if v.special == 1 then
			self:ShowAngerBossView(self.enter_dun_id)
			break
		end
	end
	self:FireEvent(game.CarbonEvent.OnDungRefreshMon, data)
end

function CarbonCtrl:ShowAngerBossView(dun_id)
	local cfg = config.dungeon[dun_id]
	local anger_boss_id = cfg.anger_boss or 0
	if anger_boss_id > 0 then
		self:OpenAngerBossView(anger_boss_id)
	end
end

function CarbonCtrl:OpenAngerBossView(anger_boss_id)
	self.anger_boss_view:Open(anger_boss_id)
end

function CarbonCtrl:GetEnterDungID()
	return self.enter_dun_id
end

game.CarbonCtrl = CarbonCtrl

return CarbonCtrl