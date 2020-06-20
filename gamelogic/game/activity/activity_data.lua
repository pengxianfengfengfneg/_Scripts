local ActivityData = Class(game.BaseData)

local act_conf = config.activity
local config_activity_hall = config.activity_hall

local need_tips = function(act_id, act_state, role_lv)

	local tips = act_conf[act_id].tips
	if tips then
		local is_lv_reach = false
		for _,v in pairs(config_activity_hall) do
			if v.act_id == act_id then
				if role_lv >= v.limit_lv then
					is_lv_reach = true
				end
				break
			end
		end

		if is_lv_reach then
			for key, state in pairs(tips) do
				if state == act_state and state ~= 0 then
					return true
				end
			end
		end
	end

	return false
end

function ActivityData:_init(ctrl)
	self.ctrl = ctrl
	self.activity_data = nil
end

function ActivityData:SetAllData(data)
	self.activity_data = {}
	for _, act in pairs(data.flags) do
		self.activity_data[act.act_id] = act
	end
	self:FireEvent(game.ActivityEvent.ActivityInfo, self.activity_data)
end

--更新活动数据
function ActivityData:AddActivityData(data)
	local act_list = {}
	for _, act in pairs(data.flags) do
		self.activity_data[act.act_id] = act
		act_list[act.act_id] = act
	end

	local role_lv = game.Scene.instance:GetMainRoleLevel()
	for act_id, act in pairs(act_list) do
		if need_tips(act_id, act.state, role_lv) then
			self.ctrl:OpenActivityTip(act_id)

			self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, game.ActToMsgNoticeId[act_id], act.start_time, act.end_time, act_id)
		end
	end

	self:FireEvent(game.ActivityEvent.UpdateActivity, act_list)
end

function ActivityData:RemoveActivityData(data)
	self.activity_data[data.id] = nil
	self:FireEvent(game.ActivityEvent.StopActivity, data.id)
end

function ActivityData:GetActivity(act_id)
	if self.activity_data then
		return self.activity_data[act_id]
	end
end

function ActivityData:GetActivities()
	return self.activity_data
end

function ActivityData:IsInCfgOpenTime(act_info)
	local act_id = act_info.act_id
	local start_time = act_info.start_time

	local is_cfg_open = false
	for k, v in pairs(config.daily_activity_schedule) do
		if v.act_id == act_id then

			local cfg_start_time = game.Utils:getStartStamp(v.start_time)

			if start_time == cfg_start_time then
				is_cfg_open = true
				break
			end
		end
	end

	return is_cfg_open
end

function ActivityData:GetGMOpenActivities()

	local gm_open_list = {}

	for k, v in pairs(self.activity_data) do
		if not self:IsInCfgOpenTime(v) then
			table.insert(gm_open_list, v)
		end
	end

	return gm_open_list
end

function ActivityData:GetOnGoingActs()

	local act_list = {}
	for _, act in pairs(self.activity_data or {}) do
		if need_tips(act.act_id, act.state) then
			act_list[act.act_id] = act
		end
	end

	return act_list
end

--后端通知开启的活动状态
function ActivityData:GetActivityState(act_id)

	local act_info = self:GetActivity(act_id)
	if not act_info then
		return game.ActivityState.ACT_STATE_UNDEFINE
	end

	local start_time = act_info.start_time
	local end_time = act_info.end_time

	local cur_time = global.Time:GetServerTime()
	if start_time <= cur_time and cur_time <= end_time then
		return game.ActivityState.ACT_STATE_ONGOING
	elseif start_time > cur_time then
		return game.ActivityState.ACT_STATE_PREPARE
	elseif cur_time > end_time then
		return game.ActivityState.ACT_STATE_FINISH
	end
end

local getStartStamp = function(start_time)

	local start_stamp = 0
	local start_hour = start_time[1]
	local start_min = start_time[2]
	local cur_time = global.Time:GetServerTime()
	local cur_tab = os.date("*t", cur_time)
	local cur_hour = cur_tab.hour
	local cur_min = cur_tab.min
	local cur_sec = cur_tab.sec
	start_stamp = cur_time + (start_hour - cur_hour)*3600 + (start_min - cur_min)*60 - cur_sec

	return start_stamp
end

--按配置时间开启的活动状态
function ActivityData:GetCfgActivityState(daily_act_id)

	local daily_act_cfg = config.daily_activity_schedule[daily_act_id]
	local start_stamp = getStartStamp(daily_act_cfg.start_time)
	local end_stamp = getStartStamp(daily_act_cfg.end_time)

	local cur_time = global.Time:GetServerTime()

	if cur_time < start_stamp then
		return game.ActivityState.ACT_STATE_PREPARE
	elseif start_stamp <= cur_time and cur_time <= end_stamp then
		return game.ActivityState.ACT_STATE_ONGOING
	else
		return game.ActivityState.ACT_STATE_FINISH
	end
end

----------------------活跃值相关---------------------------
function ActivityData:SetDailyActiveInfo(data)

	self.daily_active_info = data
end

function ActivityData:UpdateDailyActiveAwardInfo(data)

	if self.daily_active_info then

		local t = {}
		t.id = data.id
		table.insert(self.daily_active_info.got_list, t)
	end
end

function ActivityData:UpdateDailyActiveValue(data)

	if self.daily_active_info then
		self.daily_active_info.lively_exp = data.lively_exp
		self.daily_active_info.completed = data.completed
	end
end

function ActivityData:GetActivityCompleteTimes(act_index)

	local act_hall_index = act_index

	local complete_times = 0

	if self.daily_active_info then
		for k, v in pairs(self.daily_active_info.completed) do

			if v.id == act_hall_index then

				complete_times = v.times
			end
		end
	end

	return complete_times
end

function ActivityData:GetActivityCompleteTimesEx(act_id)

	local act_hall_index

	for k, v in pairs(config.activity_hall) do
		if v.act_id == act_id then
			act_hall_index = k
			break
		end
	end

	local complete_times = 0

	if self.daily_active_info then
		for k, v in pairs(self.daily_active_info.completed) do

			if v.id == act_hall_index then

				complete_times = v.times
			end
		end
	end

	return complete_times
end

function ActivityData:GetActiveInfo()

	return self.daily_active_info
end

function ActivityData:GetDailyLivelyExp()
	if self.daily_active_info then
		return self.daily_active_info.lively_exp
	else
		return 0
	end
end

function ActivityData:CheckCanGetAward()

	local can_get = false

	if self.daily_active_info then
		
		local cur_exp = self.daily_active_info.lively_exp
		local reward = config.daily_lively_reward[1].reward
		local got_list = self.daily_active_info.got_list

		for k, v in ipairs(reward) do

			local got = false
			for x, y in pairs(got_list) do

				if y.id == k then
					got = true
					break
				end
			end

			local exp = v[2]
			if cur_exp >= exp then
				if not got then
					can_get = true
					break
				end
			end
		end
	end

	return can_get
end

function ActivityData:CheckMsgActivity()
	local role_lv = game.Scene.instance:GetMainRoleLevel()
	for act_id,act in pairs(self.activity_data) do
		if need_tips(act_id, act.state, role_lv) then
			self:FireEvent(game.MsgNoticeEvent.AddMsgNotice, game.ActToMsgNoticeId[act_id], act.start_time, act.end_time, act_id)
		end
	end
end

return ActivityData