local GuildArenaFightViewSecond = Class(game.BaseView)

function GuildArenaFightViewSecond:_init(ctrl)
	self._package_name = "ui_guild_arena"
    self._com_name = "fight_view_second"
    self.ctrl = ctrl
    self.data = ctrl:GetData()
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1
    self._view_level = game.UIViewLevel.Standalone
end

function GuildArenaFightViewSecond:OpenViewCallBack()

	self:InitList()

	self.ctrl:CsJoustsHallInfo()

	self:BindEvent(game.GuildArenaEvent.UpdateViewInfoSec, function(data)
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

function GuildArenaFightViewSecond:CloseViewCallBack()
	self:DelTimer()

	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
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
		return config.words[5218]
	elseif stage == 9 then
		return config.words[5205]
	elseif stage == 10 then
		return config.words[5208]
	end
end

function GuildArenaFightViewSecond:InitList()

	local num = 0
	local data = self.data:GetSecondFightData()
	if data then
		local hurt_rank = data.hurt_rank
		num = #hurt_rank
		self.hurt_rank = hurt_rank
		self:SetMyRank(data.hurt_rank)
	end

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/guild_arena/guild_arena_hurt_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_guild_arena:hurt_template"
    end)

    self.ui_list:SetItemNum(num)
end

function GuildArenaFightViewSecond:UpdateInfo(data)

	local num = #data.hurt_rank
	self.hurt_rank = data.hurt_rank
	self.ui_list:SetItemNum(num)

	self:SetMyRank(data.hurt_rank)
end

function GuildArenaFightViewSecond:GetHurtRank()
	return self.hurt_rank
end

function GuildArenaFightViewSecond:SetMyRank(hurt_rank)
--[[
	local my_guild_id = game.GuildCtrl.instance:GetGuildId()
	local my_guild_info

	for k,v in pairs(hurt_rank) do
		if v.guild_id == my_guild_id then
			my_guild_info = v
			break
		end
	end

	if my_guild_info then
		self._layout_objs["my_rank"]:SetText(my_guild_info.rank)
		self._layout_objs["my_guild"]:SetText(my_guild_info.guild_name)

		local hurt = string.format("%.2f", my_guild_info.hurt/100)
		self._layout_objs["my_hurt"]:SetText(tostring(hurt).."%")
	else
		self._layout_objs["my_rank"]:SetText("")
		self._layout_objs["my_guild"]:SetText(config.words[1411])
		self._layout_objs["my_hurt"]:SetText("")
	end
	]]
end

--每轮中的阶段有改变(首次也会通知)
function GuildArenaFightViewSecond:UpdateStageInfo(data)

	--第四轮战场信息
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


	--毒瘴光圈
	if data.stage == 10 then
		local scene_logic = game.Scene.instance:GetSceneLogic()
		scene_logic:SetPoisonVisibel(true)
	else
		local scene_logic = game.Scene.instance:GetSceneLogic()
		scene_logic:SetPoisonVisibel(false)
	end
end

function GuildArenaFightViewSecond:DelTimer()
	if self.timer then
		global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
	end
end

return GuildArenaFightViewSecond