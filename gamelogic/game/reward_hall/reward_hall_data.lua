local RewardHallData = Class(game.BaseData)

function RewardHallData:_init()

end

function RewardHallData:SetSignData(data)
	self.sign_data = data
end

function RewardHallData:GetSignData()
	return self.sign_data
end

function RewardHallData:OnGetDailySign(data)
	self.sign_data.is_get = data.is_get
	self.sign_data.daily = data.daily
	self.sign_data.acc = data.acc
end

function RewardHallData:UpdateAccSign(data)
	for _, v in pairs(self.sign_data.acc) do
		if v.id == data.id then
			v.state = 2
			break
		end
	end
end

function RewardHallData:OnAddSign(data)
	self.sign_data.times = data.times
	self.sign_data.bq_times = data.bq_times
	self.sign_data.daily = data.daily
	self.sign_data.acc = data.acc
end

function RewardHallData:OnSignTimesChange(data)
	if self.sign_data then
		self.sign_data.times = data.times
	end
end

function RewardHallData:GetAccSignTipState()
	if self.sign_data then
		for _, v in pairs(self.sign_data.acc) do
			if v.state == 1 then
				return true
			end
		end
	end
	return false
end

function RewardHallData:GetSignTipState()
	if not self.sign_data then
		return false
	end
	if self.sign_data.is_get == 0 or (self.sign_data.times > 0 and self.sign_data.bq_times < 2) or self:GetAccSignTipState() then
		return true
	end
	return false
end

function RewardHallData:SetLevelGiftData(data)
	self.level_gift_data = data
end

function RewardHallData:UpdateLevelGiftData(data)
	for _, var in pairs(self.level_gift_data.states) do
		if var.lv == data.lv then
			var.state = 2
		end
	end
end

function RewardHallData:GetLevelGiftData()
	return self.level_gift_data
end

function RewardHallData:GetLevelGiftTipState()
	if not self.level_gift_data then
		return false
	end
	for _, v in pairs(self.level_gift_data.states) do
		if v.state == 1 then
			return true
		end
	end
	return false
end


function RewardHallData:SetWeekMonthCardData(data)
	self.card_data = data
end

function RewardHallData:UpdateWeekMonthCardData(data)
	if not self.card_data then
		return
	end
	
	for _, var in pairs(self.card_data.info) do
		for _, v in pairs(data.info) do
			if var.type == v.type then
				var.expire_time = v.expire_time
				var.flag = v.flag
				break
			end
		end
	end
end

function RewardHallData:GetWeekMonthCardData()
	return self.card_data
end

function RewardHallData:GetCardData(card_type)
	if not self.card_data then
		return
	end

	for _, var in pairs(self.card_data.info) do
		
		if var.type == card_type then
			return var
		end
	end
end

function RewardHallData:SetOnlineInfo(info)
	self.online_info = info
end

function RewardHallData:GetOnlineInfo()
	return self.online_info
end

function RewardHallData:SetOnlineRewardGet(id)
	local flag = true
	for _, v in pairs(self.online_info.list) do
		if v.id == id then
			v.state = 2
			flag = false
			break
		end
	end
	if flag then
		table.insert(self.online_info.list, {id = id, state = 2})
	end
end

function RewardHallData:SetOnlinePray(data)
	self.online_info.times = data.times
	local flag = true
	for _, v in pairs(self.online_info.list) do
		if v.id == data.id then
			v.state = 1
			flag = false
			break
		end
	end
	if flag then
		table.insert(self.online_info.list, {id = data.id, state = 1})
	end
end

function RewardHallData:SetGrowthFundInfo(data)
	self.growth_fund_info = data
end

function RewardHallData:GetGrowthFundInfo()
	return self.growth_fund_info
end

function RewardHallData:OnGrowthFundGet(data)
	if self.growth_fund_info and data.grade == self.growth_fund_info.grade then
		table.insert(self.growth_fund_info.get_list, {id = data.id})
	end
end

function RewardHallData:SetPayBackInfo(data)
	self.pay_back_info = data
end

function RewardHallData:GetPayBackInfo()
	return self.pay_back_info
end

function RewardHallData:SetPayBackGet(data)
	self.pay_back_info.type = data.type
end

function RewardHallData:GetPayBackTipState()
	return self.pay_back_info and self.pay_back_info.type == 0 and self.pay_back_info.leave_num > 0
end

function RewardHallData:SetDailyGiftInfo(info)
	self.daily_gift_info = info.reward_list
end

function RewardHallData:GetDailyGiftInfo()
	return self.daily_gift_info
end

function RewardHallData:SetDailyGiftGet(data)
	for _, v in pairs(self.daily_gift_info) do
		if v.grade == data.grade then
			v.state = 2
		end
	end
end

function RewardHallData:SetGetBackInfo(info)
	self.get_back_info = info.retrieve
end

function RewardHallData:GetGetBackInfo()
	return self.get_back_info
end

function RewardHallData:SetGetBackReward(data)
	for _, v in pairs(self.get_back_info) do
		if v.id == data.id then
			v.times = data.times
		end
	end
end

function RewardHallData:GetGetBackTipState()
	if not self.get_back_info then
		return false
	end
	for _, v in pairs(self.get_back_info) do
		if v.times > 0 then
			return true
		end
	end
	return false
end

function RewardHallData:SetSevenLoginInfo(data)
	self.seven_login_info = data
	self:FireEvent(game.RewardHallEvent.OnSevenLoginInfo, data)
end

function RewardHallData:GetServerLoginInfo()
	return self.seven_login_info
end

function RewardHallData:OnSevenLoginGet(data)
	if self.seven_login_info then
		local update = true
		for k, v in pairs(self.seven_login_info.list) do
			if v.day == data.day then
				update = false
				break
			end
		end
		if update then
			table.insert(self.seven_login_info.list, {day = data.day})
		end
		self:FireEvent(game.RewardHallEvent.OnSevenLoginGet, data)
	end
end

function RewardHallData:IsGetLoginReward(day)
	if self.seven_login_info then
		for k, v in pairs(self.seven_login_info.list) do
			if v.day == day then
				return true
			end
		end
	end
	return false
end

function RewardHallData:CanGetLoginReward(day)
	if self.seven_login_info then
		local login_day = self.seven_login_info.login_day
		return login_day >= day and not self:IsGetLoginReward(day)
	end
	return false
end

function RewardHallData:GetSevenLoginRedVisible()
	if self.seven_login_info then
		for k, v in pairs(config.seven_login) do
			if self:CanGetLoginReward(v.day) then
				return true
			end
		end
	end
	return false
end

function RewardHallData:CanShowSevenLogin()
	if self.seven_login_info then
		if #self.seven_login_info.list < #config.seven_login then
			return true
		end
	end
	return false
end

function RewardHallData:SetDividendInfo(data)
	self.dividend_info = data
	self:FireEvent(game.RewardHallEvent.UpdateDividendInfo, data)
end

function RewardHallData:GetDividendInfo()
	return self.dividend_info
end

function RewardHallData:GetSprintLevelGotNum(id)
	if self.dividend_info then
		for k, v in ipairs(self.dividend_info.lv_got_list) do
			if v.id == id then
				return v.num
			end
		end
	end
	return 0
end

function RewardHallData:GetSprintLevelGotList()
	if self.dividend_info then
		return self.dividend_info.lv_role_got_list
	end
end

function RewardHallData:GetSprintLevelState(id)
	local got_list = self:GetSprintLevelGotList()
	for k, v in ipairs(got_list or game.EmptyTable) do
		if v.id == id then
			return 2
		end
	end
	local role_lv = game.RoleCtrl.instance:GetRoleLevel()
	if role_lv >= config.sprint_level[id].lv then
		return 1
	end
	return 0
end

function RewardHallData:GetStoneGoldGotList()
	if self.dividend_info then
		return self.dividend_info.stone_got_list
	end
end

function RewardHallData:GetStoneGoldState(id)
	local got_list = self:GetStoneGoldGotList()
	for k, v in ipairs(got_list or game.EmptyTable) do
		if v.id == id then
			return v.flag
		end
	end
	return 0
end

function RewardHallData:GetStoneGoldStage(id)
	local got_list = self:GetStoneGoldGotList()
	for k, v in ipairs(got_list or game.EmptyTable) do
		if v.id == id then
			return v.stage
		end
	end
	return 0
end

function RewardHallData:GetLotteryLively()
	if self.dividend_info then
		return self.dividend_info.lottery_lively
	end
	return 0
end

function RewardHallData:GetLotteryCharge()
	if self.dividend_info then
		return self.dividend_info.lottery_charge
	end
	return 0
end

function RewardHallData:CanGetLivelyReward(id)
	if self.dividend_info then
		for k, v in ipairs(self.dividend_info.lively_got_list) do
			if v.id == id then
				return false
			end
		end
		return self:GetLotteryLively() >= config.lucky_lottery[1].value[id][2]
	end
	return false
end

function RewardHallData:CanGetChargeReward(id)
	if self.dividend_info then
		for k, v in ipairs(self.dividend_info.charge_got_list) do
			if v.id == id then
				return false
			end
		end
		return self:GetLotteryCharge() >= config.lucky_lottery[2].value[id][2]
	end
	return false
end

function RewardHallData:GetLotteryLivelyTimes()
	local times = 0
	for k, v in ipairs(config.lucky_lottery[1].value) do
		if self:CanGetLivelyReward(v[1]) then
			times = times + 1
		end
	end
	return times
end

function RewardHallData:GetLotteryChargeTimes()
	local times = 0
	for k, v in ipairs(config.lucky_lottery[2].value) do
		if self:CanGetChargeReward(v[1]) then
			times = times + 1
		end
	end
	return times
end

function RewardHallData:GetLotteryLivelyId()
	for k, v in ipairs(config.lucky_lottery[1].value) do
		if self:CanGetLivelyReward(v[1]) then
			return v[1]
		end
	end
end

function RewardHallData:GetLotteryChargeId()
	for k, v in ipairs(config.lucky_lottery[2].value) do
		if self:CanGetChargeReward(v[1]) then
			return v[1]
		end
	end
end

function RewardHallData:OnDividendLvGet(data)
	self.dividend_info.lv_got_list = data.lv_got_list
	table.insert(self.dividend_info.lv_role_got_list, {id = data.id})
	self:FireEvent(game.RewardHallEvent.OnDividendLvGet)
end

function RewardHallData:OnDividendStoneChange(data)
	for k, v in ipairs(self.dividend_info.stone_got_list) do
		if v.id == data.id then
			for i, cv in pairs(data) do
				v[i] = cv
			end
			break
		end
	end
	self:FireEvent(game.RewardHallEvent.OnDividendStoneChange, data)
end

function RewardHallData:OnDividendLuckyInfo(data)
	if data.type == 1 then
		table.insert(self.dividend_info.lively_got_list, {id = data.id})
	elseif data.type == 2 then
		table.insert(self.dividend_info.charge_got_list, {id = data.id})
	else
		for k, v in pairs(data) do
			self.dividend_info[k] = v
		end
	end
	self:FireEvent(game.RewardHallEvent.OnDividendLuckyInfo, data)
end

function RewardHallData:CanShowDividend()
	local open_lv = config.sys_config.dividend_open_lv.value
	local role_lv = game.RoleCtrl.instance:GetRoleLevel()
	local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.Dividend)
	return (role_lv >= open_lv) and act and (act.state == game.ActivityState.ACT_STATE_ONGOING)
end

function RewardHallData:CheckDividendRedPoint()
	local act = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.Dividend)
	if not act or act.state ~= game.ActivityState.ACT_STATE_ONGOING then
		return false
	end
	return self:CheckDividendLevelRedPoint() or self:CheckDividendStoneRedPoint() or self:CheckLuckyLotteryRedPoint()
end

function RewardHallData:CheckDividendLevelRedPoint()
	for k, v in pairs(config.sprint_level) do
		local state = self:GetSprintLevelState(v.id)
		if state == 1 then
			return true
		end
	end
	return false
end

function RewardHallData:CheckDividendStoneRedPoint()
	for k, v in pairs(config.stone_gold) do
		local state = self:GetStoneGoldState(v.id)
		if state == 1 then
			return true
		end
	end
	return false
end

function RewardHallData:CheckLuckyLotteryRedPoint()
	local live_times = self:GetLotteryLivelyTimes()
	local charge_times = self:GetLotteryChargeTimes()
	return (live_times > 0) or (charge_times > 0)
end

return RewardHallData