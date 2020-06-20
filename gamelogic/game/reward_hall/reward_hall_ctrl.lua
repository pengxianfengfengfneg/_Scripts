local RewardHallCtrl = Class(game.BaseCtrl)

function RewardHallCtrl:_init()
	if RewardHallCtrl.instance ~= nil then
		error("RewardHallCtrl Init Twice!")
	end
	RewardHallCtrl.instance = self

	self.data = require("game/reward_hall/reward_hall_data").New()
	self.reward_hall_view = require("game/reward_hall/reward_hall_view").New()
	self.get_gift_view = require("game/reward_hall/get_gift_view").New()
	self.get_back_view = require("game/reward_hall/get_back_view").New()
	self:RegisterAllProtocal()
	self:RegisterAllEvents()
	self.pray_times = 0
	global.Runner:AddUpdateObj(self, 2)
end

function RewardHallCtrl:_delete()
	global.Runner:RemoveUpdateObj(self)
	self.data:DeleteMe()
	self.reward_hall_view:DeleteMe()
	self.get_gift_view:DeleteMe()
	self.get_back_view:DeleteMe()

	RewardHallCtrl.instance = nil
end

function RewardHallCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.LoginReq)},
        {game.ActivityEvent.TodayOnlineTime, handler(self, self.SetOnlineTime)},
        {game.ActivityEvent.StopActivity, handler(self, self.OnStopActivity)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RewardHallCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(30402, "OnSignInfo")
	self:RegisterProtocalCallback(30404, "OnSignGetDaily")
	self:RegisterProtocalCallback(30406, "OnSignGetAcc")
	self:RegisterProtocalCallback(30408, "OnAddSignGet")
	self:RegisterProtocalCallback(30409, "OnSignTimesChange")

	self:RegisterProtocalCallback(30502, "OnLevelGiftInfo")
	self:RegisterProtocalCallback(30504, "OnLevelGiftGet")

	self:RegisterProtocalCallback(50602, "OnCardInfo")
	self:RegisterProtocalCallback(50603, "OnCardChange")

	self:RegisterProtocalCallback(53102, "OnOnlineRewardInfo")
	self:RegisterProtocalCallback(53104, "OnOnlinePray")
	self:RegisterProtocalCallback(53106, "OnOnlineRewardGet")

    self:RegisterProtocalCallback(53111, "OnGrowthFundInfo")
    self:RegisterProtocalCallback(53113, "OnGrowthFundGet")

    self:RegisterProtocalCallback(53121, "OnDailyGiftInfo")
    self:RegisterProtocalCallback(53123, "OnDailyGiftGet")

    self:RegisterProtocalCallback(53131, "OnPayBackInfo")
    self:RegisterProtocalCallback(53133, "OnPayBackGet")

    self:RegisterProtocalCallback(53141, "OnGetBackInfo")
	self:RegisterProtocalCallback(53143, "OnGetBackReward")
	
    self:RegisterProtocalCallback(53602, "OnSevenLoginInfo")
	self:RegisterProtocalCallback(53604, "OnSevenLoginGet")
	
	self:RegisterProtocalCallback(53802, "OnDividendInfo")
	self:RegisterProtocalCallback(53804, "OnDividendLvGet")
	self:RegisterProtocalCallback(53806, "OnDividendStoneGet")
	self:RegisterProtocalCallback(53807, "OnDividendFlagChange")
	self:RegisterProtocalCallback(53809, "OnDividendLuckyGet")
	self:RegisterProtocalCallback(53810, "OnDividendLivelyChange")
	self:RegisterProtocalCallback(53811, "OnDividendChargeChange")
end

function RewardHallCtrl:OnStopActivity(act_id)
    if act_id == game.ActivityId.Dividend then
        self:FireEvent(game.RewardHallEvent.StopDividendAct)
    end
end

function RewardHallCtrl:LoginReq()
	self:SendSevenLoginInfo()
end

function RewardHallCtrl:GetData()
	return self.data
end

function RewardHallCtrl:OpenView(index)
	self.reward_hall_view:Open(index)
end

function RewardHallCtrl:CsSignInfo()
	self:SendProtocal(30401,{})
end

function RewardHallCtrl:OnSignInfo(data)
	self.data:SetSignData(data)
end

function RewardHallCtrl:GetSignData()
	return self.data:GetSignData()
end

function RewardHallCtrl:SendSignGetDaily()
	self:SendProtocal(30403)
end

function RewardHallCtrl:OnSignGetDaily(data)
	self.data:OnGetDailySign(data)
	self:FireEvent(game.RewardHallEvent.UpdateSignInfo)
end

function RewardHallCtrl:SendSignGetAcc(id)
	self:SendProtocal(30405,{id = id})
end

function RewardHallCtrl:OnSignGetAcc(data)
	self.data:UpdateAccSign(data)
	self:FireEvent(game.RewardHallEvent.UpdateSignInfo)
end

function RewardHallCtrl:SendAddSign()
	self:SendProtocal(30407)
end

function RewardHallCtrl:OnAddSignGet(data)
	self.data:OnAddSign(data)
	self:FireEvent(game.RewardHallEvent.UpdateSignInfo)
end

function RewardHallCtrl:OnSignTimesChange(data)
	self.data:OnSignTimesChange(data)
end

--等级礼包
function RewardHallCtrl:SendLevelGiftInfo()
	self:SendProtocal(30501,{})
end

function RewardHallCtrl:OnLevelGiftInfo(data)
	self.data:SetLevelGiftData(data)
	self:FireEvent(game.RewardHallEvent.UpdateLevelGift)
end

function RewardHallCtrl:GetLevelGiftData()
	return self.data:GetLevelGiftData()
end

function RewardHallCtrl:SendLevelGiftGet(level)
	self:SendProtocal(30503,{lv=level})
end

function RewardHallCtrl:OnLevelGiftGet(data)
	self.data:UpdateLevelGiftData(data)
	self:FireEvent(game.RewardHallEvent.UpdateLevelGift)
end

--周月卡
function RewardHallCtrl:SendCardInfo()
    self:SendProtocal(50601)
end

--买卡
function RewardHallCtrl:SendBuyCard(type)
	self:SendProtocal(50605, {num = 1 ,type = type})
end

function RewardHallCtrl:GetCardData(type)
	return self.data:GetCardData(type)
end

function RewardHallCtrl:OnCardInfo(data)
	self.data:SetWeekMonthCardData(data)
	self:FireEvent(game.RewardHallEvent.UpdateWeekMonthCard)
end

function RewardHallCtrl:SendCardReward(type)
    self:SendProtocal(50604, {type = type})
end

function RewardHallCtrl:OnCardChange(data)
	self.data:UpdateWeekMonthCardData(data)
	self:FireEvent(game.RewardHallEvent.UpdateWeekMonthCard)
end

function RewardHallCtrl:SendOnlineInfo()
	self:SendProtocal(53101)
end

function RewardHallCtrl:OnOnlineRewardInfo(data)
	self.data:SetOnlineInfo(data)
    self:FireEvent(game.RewardHallEvent.UpdateOnlineInfo)
	game.MainUICtrl.instance:SendGetOnlineTime()
end

function RewardHallCtrl:GetOnlineInfo()
	return self.data:GetOnlineInfo()
end

function RewardHallCtrl:SendOnlinePray()
	self:SendProtocal(53103)
end

function RewardHallCtrl:OnOnlinePray(data)
    self.data:SetOnlinePray(data)
    self:FireEvent(game.RewardHallEvent.UpdateOnlinePray, data)
end

function RewardHallCtrl:SendOnlineRewardGet(id)
	self:SendProtocal(53105, {id = id})
end

function RewardHallCtrl:OnOnlineRewardGet(data)
    self.data:SetOnlineRewardGet(data.id)
    self:FireEvent(game.RewardHallEvent.UpdateOnlineInfo)
end

function RewardHallCtrl:SetOnlineTime(time)
	self.online_time = time
	self.pray_times = 0
	local info = self:GetOnlineInfo()
	if info == nil then
		return
	end
	for _, v in ipairs(config.online_reward.online_time) do
		if time >= v[2] then
			self.pray_times = v[1]
		end
	end
	if info.times >= config.online_reward.max_times then
		self.pray_times = 0
	else
		self.pray_times = self.pray_times - info.times
	end
end

function RewardHallCtrl:GetCanPrayTimes()
	return self.pray_times
end


function RewardHallCtrl:SendGetGrowthFundInfo()
    self:SendProtocal(53110)
end

function RewardHallCtrl:OnGrowthFundInfo(data)
    self.data:SetGrowthFundInfo(data)
    self:FireEvent(game.RewardHallEvent.UpdateGrowthFundInfo)
end

function RewardHallCtrl:GetGrowthFundInfo()
    return self.data:GetGrowthFundInfo()
end

function RewardHallCtrl:SendGrowthFundGet(grade, id)
    self:SendProtocal(53112, {grade = grade, id = id})
end

function RewardHallCtrl:OnGrowthFundGet(data)
    self.data:OnGrowthFundGet(data)
    self:FireEvent(game.RewardHallEvent.UpdateGrowthFundInfo)
end

function RewardHallCtrl:SendPayBackInfo()
    self:SendProtocal(53130)
end

function RewardHallCtrl:OnPayBackInfo(data)
    self.data:SetPayBackInfo(data)
end

function RewardHallCtrl:GetPayBackInfo()
    return self.data:GetPayBackInfo()
end

function RewardHallCtrl:SendPayBackGet(type)
    self:SendProtocal(53132, {type = type})
end

function RewardHallCtrl:OnPayBackGet(data)
    self.data:SetPayBackGet(data)
    self:FireEvent(game.RewardHallEvent.UpdatePayBackInfo)
end

function RewardHallCtrl:SendDailyGiftInfo()
    self:SendProtocal(53120)
end

function RewardHallCtrl:OnDailyGiftInfo(data)
    self.data:SetDailyGiftInfo(data)
    self:FireEvent(game.RewardHallEvent.UpdateDailyGiftInfo)
end

function RewardHallCtrl:GetDailyGiftInfo()
    return self.data:GetDailyGiftInfo()
end

function RewardHallCtrl:SendDailyGiftGet(grade, id)
    self:SendProtocal(53122, {grade = grade, id = id})
end

function RewardHallCtrl:OnDailyGiftGet(data)
    self.data:SetDailyGiftGet(data)
    self.get_gift_view:Close()
    self:FireEvent(game.RewardHallEvent.UpdateDailyGiftInfo)
end

function RewardHallCtrl:OpenGetGiftView(info)
    self.get_gift_view:Open(info)
end

function RewardHallCtrl:SendGetBackInfo()
    self:SendProtocal(53140)
end

function RewardHallCtrl:OnGetBackInfo(data)
    self.data:SetGetBackInfo(data)
    self:FireEvent(game.RewardHallEvent.UpdateGetBackInfo)
end

function RewardHallCtrl:GetGetBackInfo()
    return self.data:GetGetBackInfo()
end

function RewardHallCtrl:SendGetBackReward(type, id, times)
    self:SendProtocal(53142, {type = type, id = id, retrieve_times = times})
end

function RewardHallCtrl:SendGetBackReward(type, id, times)
	self:SendProtocal(53142, {type = type, id = id, retrieve_times = times})
end

--发送购买成长基金请求
function RewardHallCtrl:SendBuyFundReward()
	self:SendProtocal(53144, {type = 11})
end

function RewardHallCtrl:OnGetBackReward(data)
    self.data:SetGetBackReward(data)
    self.get_back_view:Close()
    self:FireEvent(game.RewardHallEvent.UpdateGetBackInfo)
end

function RewardHallCtrl:OpenGetBackView(info, times, type)
    self.get_back_view:SetMaxTimes(times)
    self.get_back_view:SetInfo(info)
    self.get_back_view:Open(type)
end

function RewardHallCtrl:SendSevenLoginInfo()
	self:SendProtocal(53601)
end

function RewardHallCtrl:OnSevenLoginInfo(data)
	--[[ 
		"login_day__C",
		"list__T__day@C", 
	]]
	self.data:SetSevenLoginInfo(data)
end

function RewardHallCtrl:SendSevenLoginGet(day)
	self:SendProtocal(53603,{day = day})
end

function RewardHallCtrl:OnSevenLoginGet(data)
	self.data:OnSevenLoginGet(data)
end

function RewardHallCtrl:GetServerLoginInfo()
	return self.data:GetServerLoginInfo()
end

function RewardHallCtrl:IsGetLoginReward(day)
	return self.data:IsGetLoginReward(day)
end

function RewardHallCtrl:CanGetLoginReward(day)
	return self.data:CanGetLoginReward(day)
end

function RewardHallCtrl:CanShowSevenLogin()
	return self.data:CanShowSevenLogin()
end

function RewardHallCtrl:GetSevenLoginRedVisible()
	return self.data:GetSevenLoginRedVisible()
end

function RewardHallCtrl:GetSignTipState()
	return self.data:GetSignTipState()
end

function RewardHallCtrl:GetLevelGiftTipState()
	return self.data:GetLevelGiftTipState()
end

function RewardHallCtrl:GetPayBackTipState()
	return self.data:GetPayBackTipState()
end

function RewardHallCtrl:GetGetBackTipState()
	return self.data:GetGetBackTipState()
end

function RewardHallCtrl:GetViewTipsState()
	return self:GetSignTipState() or (self:CanShowSevenLogin() and self:GetSevenLoginRedVisible()) or self:GetLevelGiftTipState() or self:GetPayBackTipState() or self:GetGetBackTipState() or self:GetOnlineTipState() or (self:CanShowDividend() and self:CheckDividendRedPoint())
end

function RewardHallCtrl:GetOnlineTipState()
	return self.pray_times > 0
end

function RewardHallCtrl:Update(now_time, elapse_time)
	if self.online_time then
		self:SetOnlineTime(self.online_time + elapse_time)
	end
end

function RewardHallCtrl:SendDividendInfo()
    self:SendProtocal(53801)
end

function RewardHallCtrl:OnDividendInfo(data)
    self.data:SetDividendInfo(data)
end

function RewardHallCtrl:SendDividendLvGet(id)
    self:SendProtocal(53803, {id = id})
end

function RewardHallCtrl:OnDividendLvGet(data)
    self.data:OnDividendLvGet(data)
end

function RewardHallCtrl:SendDividendStoneGet(id)
    self:SendProtocal(53805, {id = id})
end

function RewardHallCtrl:OnDividendStoneGet(data)
    self.data:OnDividendStoneChange(data)
end

function RewardHallCtrl:SendDividendLuckyGet(type, id)
    self:SendProtocal(53808, {type = type, id = id})
end

function RewardHallCtrl:OnDividendLuckyGet(data)
    self.data:OnDividendLuckyInfo(data)
end

function RewardHallCtrl:OnDividendFlagChange(data)
    self.data:OnDividendStoneChange(data)
end

function RewardHallCtrl:OnDividendLivelyChange(data)
    self.data:OnDividendLuckyInfo(data)
end

function RewardHallCtrl:OnDividendChargeChange(data)
    self.data:OnDividendLuckyInfo(data)
end

function RewardHallCtrl:GetDividendInfo()
    return self.data:GetDividendInfo()
end

function RewardHallCtrl:GetSprintLevelState(id)
    return self.data:GetSprintLevelState(id)
end

function RewardHallCtrl:GetSprintLevelGotNum(id)
    return self.data:GetSprintLevelGotNum(id)
end

function RewardHallCtrl:GetStoneGoldState(id)
    return self.data:GetStoneGoldState(id)
end

function RewardHallCtrl:GetStoneGoldStage(id)
    return self.data:GetStoneGoldStage(id)
end

function RewardHallCtrl:GetLotteryLively()
    return self.data:GetLotteryLively()
end

function RewardHallCtrl:GetLotteryCharge()
    return self.data:GetLotteryCharge()
end

function RewardHallCtrl:GetLotteryLivelyTimes()
    return self.data:GetLotteryLivelyTimes()
end

function RewardHallCtrl:GetLotteryChargeTimes()
    return self.data:GetLotteryChargeTimes()
end

function RewardHallCtrl:GetLotteryLivelyId()
    return self.data:GetLotteryLivelyId()
end

function RewardHallCtrl:GetLotteryChargeId()
    return self.data:GetLotteryChargeId()
end

function RewardHallCtrl:CanShowDividend()
    return self.data:CanShowDividend()
end

function RewardHallCtrl:CheckDividendRedPoint()
    return self.data:CheckDividendRedPoint()
end

function RewardHallCtrl:CheckDividendLevelRedPoint()
    return self.data:CheckDividendLevelRedPoint()
end

function RewardHallCtrl:CheckDividendStoneRedPoint()
    return self.data:CheckDividendStoneRedPoint()
end

function RewardHallCtrl:CheckLuckyLotteryRedPoint()
    return self.data:CheckLuckyLotteryRedPoint()
end

game.RewardHallCtrl = RewardHallCtrl

return RewardHallCtrl