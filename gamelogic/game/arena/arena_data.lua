local ArenaData = Class(game.BaseData)

function ArenaData:_init()
	self.rank_list = {}
end

function ArenaData:SetArenaInfo(data)
	self.my_rank = data.rank
	self.buy_times = data.buy_times
	self.left_times = data.left_times
	self.reward_time = data.reward_time
end

function ArenaData:UpdateBuyTimes(data)
	self.buy_times = data.buy_times
	self.left_times = data.left_times
end

function ArenaData:SetOppData(data)
	self.opp_data = data
end

function ArenaData:GetOppData()
	return self.opp_data
end

function ArenaData:SetRankList(rank_list)

	self.rank_list = rank_list.list
end

function ArenaData:GetRankList()
	return self.rank_list
end

function ArenaData:GetLeftTimes()
	return self.left_times or 0
end

function ArenaData:GetBuyTimes()
	return self.buy_times or 0
end

function ArenaData:GetRewardTime()
	return self.reward_time or 0
end

function ArenaData:UpdateMyRank(data)
	self.my_rank = data.rank_new
end

function ArenaData:GetMyRank()
	return self.my_rank or 999
end

function ArenaData:GetLeftBuyTimes()
	local vip = game.VipCtrl.instance:GetVipLevel()
	local max_times = 0

	for key, var in pairs(config.arena_times) do
		if var.need_vip == vip then
			if var.times > max_times then
				max_times = var.times
			end
		end
	end

	return max_times - self.buy_times
end

function ArenaData:GetNextVipBuyTimes(cur_vip)

	local next_vip = cur_vip + 1
	local next_max_times = 0
	local cur_min_times = 0

	for key, var in pairs(config.arena_times) do
		if var.need_vip == cur_vip then
			if cur_min_times == 0 then
				cur_min_times = var.times
			end

			if var.times < cur_min_times then
				cur_min_times = var.times
			end
		end
	end


	for key, var in pairs(config.arena_times) do
		if var.need_vip == next_vip then
			if var.times > next_max_times then
				next_max_times = var.times
			end
		end
	end

	return next_max_times - cur_min_times
end

function ArenaData:SubLeftTimes()
	if self.left_times then
		self.left_times = self.left_times - 1
	end
end

return ArenaData