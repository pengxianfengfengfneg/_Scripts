local GuildArenaRankView = Class(game.BaseView)

function GuildArenaRankView:_init(ctrl)
	self._package_name = "ui_guild_arena"
    self._com_name = "rank_view"
    self.ctrl = ctrl
end

function GuildArenaRankView:OpenViewCallBack()
	--积分奖励
	self:BindEvent(game.GuildArenaEvent.UpdateMyScore, function(data)
		self:SetMyScore(data)
	end)

	self:InitListOne()

	self.ctrl:CsJoustsHallScore()

	--积分排行
	self:InitListTwo()

	self.ctrl:CsJoustsHallRank()

	self:BindEvent(game.GuildArenaEvent.UpdateRankData, function(data)
		self:UpdateInfo(data)
	end)

	self._layout_objs["btn_close"]:AddClickCallBack(function()
		self:Close()
    end)
end

function GuildArenaRankView:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.ui_list2 then
		self.ui_list2:DeleteMe()
		self.ui_list2 = nil
	end
end

function GuildArenaRankView:InitListTwo()

	self.list2 = self._layout_objs["list2"]
    self.ui_list2 = game.UIList.New(self.list2)
    self.ui_list2:SetVirtual(true)

    self.ui_list2:SetCreateItemFunc(function(obj)

        local item = require("game/guild_arena/guild_arena_rank_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list2:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list2:AddItemProviderCallback(function(idx)
        return "ui_guild_arena:rank_item_template"
    end)

    self.ui_list2:SetItemNum(0)
end

function GuildArenaRankView:UpdateInfo(data)

	self.score_rank = data.score_rank
	local my_rank = data.target_rank

	local item_num = #self.score_rank
	self.ui_list2:SetItemNum(item_num)

	local my_rank_info
	for k, v in pairs(self.score_rank) do
		if v.rank == my_rank then
			my_rank_info = v
			break
		end
	end

	if my_rank_info then
		self._layout_objs["my_rank_num"]:SetText(my_rank_info.rank)
		self._layout_objs["my_role_name"]:SetText(my_rank_info.name)
		self._layout_objs["my_guild_name"]:SetText(my_rank_info.guild_name)
		self._layout_objs["my_score"]:SetText(my_rank_info.score)
		self._layout_objs["my_kill"]:SetText(my_rank_info.kill_role)
	end
end

function GuildArenaRankView:InitListOne()

	local world_level = 1
	local reward_cfg = config.jousts_hall[world_level].score_reward
	self.reward_cfg = reward_cfg
	local num = #reward_cfg

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/guild_arena/guild_arena_reward_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_guild_arena:score_tempalte"
    end)

    self.ui_list:SetItemNum(num)
end

function GuildArenaRankView:GetRewardCfg()
	return self.reward_cfg
end

function GuildArenaRankView:SetMyScore(data)
	self._layout_objs["score_txt"]:SetText(data.score)
end

return GuildArenaRankView