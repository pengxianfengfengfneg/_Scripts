local GuildArenaScoreAwardView = Class(game.BaseView)

function GuildArenaScoreAwardView:_init(ctrl)
	self._package_name = "ui_guild_arena"
    self._com_name = "score_award_view"
    self.ctrl = ctrl
    self.data = ctrl:GetData()
end

function GuildArenaScoreAwardView:OpenViewCallBack()

	self._layout_objs["btn_close"]:AddClickCallBack(function()
		self:Close()
    end)

	self:BindEvent(game.GuildArenaEvent.UpdateMyScore, function(data)
		self:SetMyScore(data)
	end)

	self:InitList()

	self.ctrl:CsJoustsHallScore()	
end

function GuildArenaScoreAwardView:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
end

function GuildArenaScoreAwardView:InitList()

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

function GuildArenaScoreAwardView:GetRewardCfg()
	return self.reward_cfg
end

function GuildArenaScoreAwardView:SetMyScore(data)
	self._layout_objs["score_txt"]:SetText(data.score)
end

return GuildArenaScoreAwardView