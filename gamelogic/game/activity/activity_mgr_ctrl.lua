local ActivityMgrCtrl = Class(game.BaseCtrl)
require("game/activity/activity_link_func")
function ActivityMgrCtrl:_init()
	if ActivityMgrCtrl.instance ~= nil then
		error("ActivityMgrCtrl Init Twice!")
	end
	ActivityMgrCtrl.instance = self

	self.activity_data = require("game/activity/activity_data").New(self)

	self:RegisterAllProtocal()
	self:RegisterAllEvents()
end

function ActivityMgrCtrl:_delete()

	if self.activity_hall_view then
		self.activity_hall_view:DeleteMe()
		self.activity_hall_view = nil
	end

	if self.activity_data then
		self.activity_data:DeleteMe()
		self.activity_data = nil
	end

	ActivityMgrCtrl.instance = nil
end

function ActivityMgrCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.CsDailyLivelyInfo)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function ActivityMgrCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(30102, "ActivityGetFlagResponse")
	self:RegisterProtocalCallback(30103, "ActivityAddFlagResponse")
	self:RegisterProtocalCallback(30104, "ActivityRemoveFlagResponse")
	self:RegisterProtocalCallback(52402, "ScDailyLivelyInfo")
	self:RegisterProtocalCallback(52404, "ScDailyLivelyGet")
	self:RegisterProtocalCallback(52405, "ScDailyLivelyChange")
end

function ActivityMgrCtrl:ActivityGetFlagReq()
	self:SendProtocal(30101,{})
end

function ActivityMgrCtrl:ActivityGetFlagResponse(data)
	self.activity_data:SetAllData(data)
end

--动态修改活动状态
function ActivityMgrCtrl:ActivityAddFlagResponse(data)
	self.activity_data:AddActivityData(data)
end

--动态删除活动
function ActivityMgrCtrl:ActivityRemoveFlagResponse(data)
	self.activity_data:RemoveActivityData(data)
end

function ActivityMgrCtrl:GetActivity(act_id)
	return self.activity_data:GetActivity(act_id)
end

function ActivityMgrCtrl:GetActivities()
	return self.activity_data:GetActivities()
end

function ActivityMgrCtrl:OpenActivityTip(act_id)

	local act_cfg
	for k, v in pairs(config.activity_hall) do
		if v.type == 2 and v.act_id == act_id then
			act_cfg = v
			break
		end
	end

	if not act_cfg then
		return
	end

	local limit_lv = act_cfg.limit_lv
	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	if main_role_lv < limit_lv then
		return
	end

	local cfg = game.ActivityLinkFunc[act_id]
	if cfg and cfg.check_func() then
		local view = require("game/activity/activity_open_tips").New()
		view:Open(act_id)
	end
end

function ActivityMgrCtrl:CheckActivityTips()

	local ongoing_acts = self.activity_data:GetOnGoingActs()

	for act_id, act in pairs(ongoing_acts) do
		self:OpenActivityTip(act_id)
	end
end

function ActivityMgrCtrl:GetActComingTime(act_id)
	local info_list = {}
	for _,v in ipairs(config.daily_activity_schedule or {}) do
		if v.act_id == act_id then
			for _,cv in ipairs(v.repeats) do

				table.insert(info_list, {
					id = v.id,
					act_id = act_id,
					wday = cv,
					hour = v.start_time[1],
					min = v.start_time[2],
					sec = v.start_time[3],
					start_time = (cv-1)*24*3600 + v.start_time[1]*3600 + v.start_time[2]*60 + v.start_time[3],
					end_time = (cv-1)*24*3600 + v.end_time[1]*3600 + v.end_time[2]*60 + v.end_time[3],
				})
			end
		end
	end

	table.sort(info_list, function(v1,v2)
		return v1.start_time<v2.start_time
	end)


	local server_time = global.Time:GetServerTime()
	local date = os.date("*t", server_time)
	local wday = date.wday - 1
	wday = (wday==0 and 7 or wday)
	local now_time = (wday-1)*24*3600 + date.hour*3600 + date.min*60 + date.sec

	local on_day_info = info_list[1]
	for _,v in ipairs(info_list) do
		if now_time < v.start_time then
			on_day_info = v
			break
		end
	end

	local full_time = 7*24*3600
	local delta_time = (on_day_info.start_time-now_time)
	delta_time = (delta_time<0 and (full_time+delta_time) or delta_time)
	on_day_info.delta_time = delta_time

	return on_day_info
end

function ActivityMgrCtrl:OpenActivityHallView(open_index)

	if not self.activity_hall_view then
		self.activity_hall_view = require("game/activity/activity_hall_view").New(self)
	end
	self.activity_hall_view:Open(open_index)
end

function ActivityMgrCtrl:CloseActivityHallView()
	if self.activity_hall_view then
		self.activity_hall_view:Close()
	end
end

function ActivityMgrCtrl:GetActivityHallView()
	return self.activity_hall_view
end

function ActivityMgrCtrl:GetData()
	return self.activity_data
end

local sort_func = function(a, b)
	
	local a_cfg = config.daily_activity_schedule[a.id]
	local b_cfg = config.daily_activity_schedule[b.id]
	local a_start = a_cfg.start_time[1] * 60 + a_cfg.start_time[2] 
	local b_start = b_cfg.start_time[1] * 60 + b_cfg.start_time[2] 

	if a_start == b_start then
		return a.id < b.id
	else
		return a_start < b_start
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

local function GetActivtiyField(activity_id, field_name)
	for k, v in pairs(config.activity_hall) do
		if v.act_id == activity_id then
			return v[field_name]
		end
	end
end

--今日活动 数据类型不同
function ActivityMgrCtrl:GetTodayActivitys()

	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	local activity_hall_cfg = config.activity_hall
	local open_day = game.MainUICtrl.instance:GetOpenDay()
	local cur_wday = global.Time:GetCurWeekDay()

	local result_act_list = {}

	--[[
		act_id = 1001
		index = 0
		state = 2
		end_time = 1540455900
		start_time = 1540454100
	]]
	--gm开启
	-- local gm_act_list = self.activity_data:GetActivities()

	-- for act_id, var in pairs(gm_act_list) do
	-- 	var.icon = GetActivtiyField(var.act_id, "icon")
	-- 	var.name = GetActivtiyField(var.act_id, "name")
	-- 	var.award = GetActivtiyField(var.act_id, "award")
	-- 	var.limit_lv = GetActivtiyField(var.act_id, "limit_lv")
	-- 	var.is_gm = true
	-- 	table.insert(result_act_list, var)
	-- end

	--配置开启
	local cfg_act_list = {}
	local cfg_over_act_list = {}
	for key, act_info in pairs(activity_hall_cfg) do

		--等级限制
		if main_role_lv >= act_info.limit_lv and act_info.type==2 and act_info.visible == 1 then

			local act_index_id = act_info.id
			local daily_act_info = config.daily_activity_schedule[act_index_id]

			if daily_act_info then

				--gm开启和配置活动时间一样 则不重复显示了
				local cur_time = global.Time:GetServerTime()
				local start_time = daily_act_info.start_time
				local start_stamp = getStartStamp(start_time)
				local end_time = daily_act_info.end_time
				local end_stamp = getStartStamp(end_time)
				local exist_flag = false

				for key, var in pairs(result_act_list) do
					if var.start_time == start_stamp then
						exist_flag = true
						break
					end
				end

				if not exist_flag then
					--开服天数限制
					if open_day >= daily_act_info.open_day then

						local repeats = daily_act_info.repeats
						for _, v in pairs(repeats) do

							--星期几限制
							if v == cur_wday then

								if cur_time > end_stamp then
									table.insert(cfg_over_act_list, act_info)
								else
									table.insert(cfg_act_list, act_info)
								end

								break
							end
						end
					end
				end
			end
		end
	end

	table.sort(cfg_over_act_list, sort_func)
	table.sort(cfg_act_list, sort_func)

	--合并整理
	for _, v in ipairs(cfg_act_list) do
		table.insert(result_act_list, v)
	end

	for _, v in ipairs(cfg_over_act_list) do
		table.insert(result_act_list, v)
	end

	return result_act_list
end

function ActivityMgrCtrl:GetTomorrowActivitys()

	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	local activity_hall_cfg = config.activity_hall
	local open_day = game.MainUICtrl.instance:GetOpenDay()
	local cur_wday = global.Time:GetCurWeekDay()

	local today_act_list = self:GetTodayActivitys()

	local result_act_list = {}

	for key, act_info in pairs(activity_hall_cfg) do
		if act_info.type == 2 and act_info.visible == 1  then
			local act_index_id = act_info.id
			local daily_act_info = config.daily_activity_schedule[act_index_id]

			if daily_act_info then

				--开服天数限制
				if open_day >= daily_act_info.open_day then

					local repeats = daily_act_info.repeats
					local today_open = false
					for _, v in ipairs(repeats) do
						if v == cur_wday then
							today_open = true
							break
						end
					end

					--今日不开启的活动  显示在即将开启标签
					if not today_open then
						table.insert(result_act_list, act_info)

					--今日开启，但条件不满足则显示在即将开启中
					else

						local today_open_flag = false
						for k, v in pairs(today_act_list) do

							if v.act_id == daily_act_info.act_id then
								today_open_flag = true
								break
							end
						end

						if not today_open_flag then
							table.insert(result_act_list, act_info)
						end
					end
				end
			end
		end
	end

	table.sort(result_act_list, sort_func)
	return result_act_list
end

function ActivityMgrCtrl:GetDailyActList()

	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	self._daily_act_list = {}
	for _,v in pairs(config.activity_hall) do

		if v.type == 1 and main_role_lv >= v.limit_lv and v.visible == 1 then

			local visible = game.ActivityHallTypeOneLink[v.id].visible_func()
			if visible then
				table.insert(self._daily_act_list, v)
			end
		end
	end

	table.sort(self._daily_act_list, function(v1,v2)
		-- return v1.id<v2.id

		local times1
		if v1.times == 0 then
			times1 = 1
		else
			local complete_times1 = self.activity_data:GetActivityCompleteTimes(v1.id)
			if complete_times1 == v1.times then
				times1 = 0
			else
				times1 = 1
			end
		end

		local times2
		if v2.times == 0 then
			times2 = 1
		else
			local complete_times2 = self.activity_data:GetActivityCompleteTimes(v2.id)
			if complete_times2 == v2.times then
				times2 = 0
			else
				times2 = 1
			end
		end

		if times1 == times2 then
			return v1.sort < v2.sort
		else
			return times1 > times2
		end
	end)

	return self._daily_act_list
end

function ActivityMgrCtrl:GetDaysOpen(daily_index)

	local cur_wday = global.Time:GetCurWeekDay()
	local offset_day

	for key, act_info in pairs(config.daily_activity_schedule) do

		if act_info.id == daily_index then

			local repeats = act_info.repeats

			for k, v in ipairs(repeats) do

				if v > cur_wday then
					offset_day = v - cur_wday
					break
				end
			end

			if not offset_day then
				offset_day = 7 - cur_wday + repeats[1]
			end

			break
		end
	end

	return offset_day
end

function ActivityMgrCtrl:GetLimitActivitys()

	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	local activity_hall_cfg = config.activity_hall
	local open_day = game.MainUICtrl.instance:GetOpenDay()
	local cur_wday = global.Time:GetCurWeekDay()

	local act_daily_index_list = {}			--今天可以开启的活动  exp. act_daily_index_list[6001] = {2, 3} 表示今天可开启6001活动，在日常活动索引表里的索引是 2 和 3
	local cfg_act_id_list = {}		--今天可以开启活动id 每个活动Id只保留一个 cfg_act_id_list = {6001, 6002}
	for key, act_info in pairs(activity_hall_cfg) do

		--等级限制
		if main_role_lv >= act_info.limit_lv and act_info.type==2 and act_info.visible == 1 then

			local act_id = act_info.act_id

			for k, v in pairs(config.daily_activity_schedule) do
				if v.act_id == act_id then

					if open_day >= v.open_day then

						local repeats = v.repeats
						for _, v2 in pairs(repeats) do

							--星期几限制
							if v2 == cur_wday then

								if not act_daily_index_list[act_id] then
									act_daily_index_list[act_id] = {}
									table.insert(cfg_act_id_list, act_id)
								end

								table.insert(act_daily_index_list[act_id], k)
							end
						end
					end
				end
			end
		end
	end

	--按开启时间对活动排序
	local act_start_time = {}		--每个act_id 当前使用的日常索引
	local finish_act_list = {}		--已完成活动列表
	local not_finish_act_list = {}	--没完成活动列表
	local cur_time = global.Time:GetServerTime()
	for act_id, daily_indexs in pairs(act_daily_index_list) do

		local cur_daily_cfg		--某活动所选日常索引

		for k, daily_index in ipairs(daily_indexs) do
			local daily_cfg = config.daily_activity_schedule[daily_index]
			local end_time = daily_cfg.end_time
			local end_stamp = game.Utils:getStartStamp(end_time)

			if cur_time <= end_stamp then
				cur_daily_cfg = daily_cfg
				break
			end
		end

		if not cur_daily_cfg then
			local last_index = daily_indexs[#daily_indexs]
			cur_daily_cfg = config.daily_activity_schedule[last_index]
		end

		act_start_time[act_id] = cur_daily_cfg.start_time[1] * 60 + cur_daily_cfg.start_time[2]

		local complete_times = self.activity_data:GetActivityCompleteTimesEx(act_id)
		local cfg_times = GetActivtiyField(act_id, "times")
		local end_stamp = game.Utils:getStartStamp(cur_daily_cfg.end_time)
		if cur_time >= end_stamp or (cfg_times > 0 and complete_times >= cfg_times )then
			table.insert(finish_act_list, act_id)
		else
			table.insert(not_finish_act_list, act_id)
		end
	end

	table.sort( finish_act_list, function (a, b)
		if act_start_time[a] == act_start_time[b] then
			return a < b
		else
			return act_start_time[a] < act_start_time[b]
		end
	end)

	table.sort( not_finish_act_list, function (a, b)
		if act_start_time[a] == act_start_time[b] then
			return a < b
		else
			return act_start_time[a] < act_start_time[b]
		end
	end)

	local sort_act_list = {}
	for k, v in ipairs(not_finish_act_list) do
		table.insert(sort_act_list, v)
	end

	for k, v in ipairs(finish_act_list) do
		table.insert(sort_act_list, v)
	end

	return sort_act_list, act_daily_index_list
end

--即将开启活动列表 (今日不开启的活动 或 今日开启，但条件不满足, 还有等级不足的日常任务)
function ActivityMgrCtrl:GetWaitOpenActivitys()

	local activity_hall_cfg = config.activity_hall
	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	local open_day = game.MainUICtrl.instance:GetOpenDay()
	local cur_wday = global.Time:GetCurWeekDay()

	local _, today_daily_index_list = self:GetLimitActivitys()

	local act_daily_index_list = {}			--即将开启的活动  exp. act_daily_index_list[6001] = {2, 3} 表示今天可开启6001活动，在日常活动索引表里的索引是 2 和 3
	local cfg_act_id_list = {}		--即将开启活动id 每个活动Id只保留一个 cfg_act_id_list = {6001, 6002}
	local cfg_daily_task_list = {}		--tmd 日常任务也要放进即将开启


	for key, act_info in pairs(activity_hall_cfg) do

		--等级限制
		if act_info.type == 2 and act_info.visible == 1 then

			local act_id = act_info.act_id

			for k, daily_act_info in pairs(config.daily_activity_schedule) do

				if daily_act_info.act_id == act_id then

					--开服天数限制
					-- if open_day >= daily_act_info.open_day and main_role_lv >= act_info.limit_lv then
					if open_day >= daily_act_info.open_day then

						local repeats = daily_act_info.repeats
						local today_open = false
						for _, v in ipairs(repeats) do
							if v == cur_wday then
								today_open = true
								break
							end
						end

						--今日不开启的活动  显示在即将开启标签
						if not today_open then
							
							if not act_daily_index_list[act_id] then
								act_daily_index_list[act_id] = {}
								table.insert(cfg_act_id_list, act_id)
							end

							table.insert(act_daily_index_list[act_id], k) 

						--今日开启，但条件不满足则显示在即将开启中
						else

							local today_open_flag = false
							for a_id, v in pairs(today_daily_index_list) do

								if a_id == daily_act_info.act_id then

									for _, daily_index in pairs(v) do

										if daily_index == k then
											today_open_flag = true
											break
										end
									end

									break
								end
							end

							if not today_open_flag then
								if not act_daily_index_list[act_id] then
									act_daily_index_list[act_id] = {}
									table.insert(cfg_act_id_list, act_id)
								end

								table.insert(act_daily_index_list[act_id], k) 
							end
						end
					end
				end
			end
		end
	end

	for k, act_info in pairs(activity_hall_cfg) do
		if act_info.type == 1 then

			if main_role_lv < act_info.limit_lv then
				table.insert(cfg_daily_task_list, k)
			end
		end
	end

	return cfg_act_id_list, act_daily_index_list, cfg_daily_task_list
end

function ActivityMgrCtrl:CsDailyLivelyInfo()
	self:SendProtocal(52401, {})
end

function ActivityMgrCtrl:ScDailyLivelyInfo(data)
	self.activity_data:SetDailyActiveInfo(data)
	self:FireEvent(game.ActivityEvent.MainUIRedpoint)
end

function ActivityMgrCtrl:CsDailyLivelyGet(id_t)
	self:SendProtocal(52403, {id = id_t})
end

function ActivityMgrCtrl:ScDailyLivelyGet(data)
	self.activity_data:UpdateDailyActiveAwardInfo(data)
	self:FireEvent(game.ActivityEvent.ChangeActiveExp, data)
	self:FireEvent(game.ActivityEvent.MainUIRedpoint)
end

function ActivityMgrCtrl:ScDailyLivelyChange(data)
	self.activity_data:UpdateDailyActiveValue(data)
	self:FireEvent(game.ActivityEvent.ChangeActiveExp, data)
	self:FireEvent(game.ActivityEvent.MainUIRedpoint)
end

function ActivityMgrCtrl:GetDailyLivelyExp()
	return self.activity_data:GetDailyLivelyExp()
end

function ActivityMgrCtrl:IsActOpened(act_id)
	return (self:GetActivity(act_id)~=nil)
end

--特别活动
function ActivityMgrCtrl:GetSpecialActivitysList()

	local result_act_list = {}

	--[[
		act_id = 1001
		index = 0
		state = 2
		end_time = 1540455900
		start_time = 1540454100
	]]
	--gm开启
	local gm_act_list = self.activity_data:GetGMOpenActivities()

	for act_id, var in pairs(gm_act_list) do
		if GetActivtiyField(var.act_id, "name") then
			var.icon = GetActivtiyField(var.act_id, "icon") or "act_1"
			var.name = GetActivtiyField(var.act_id, "name")
			var.award = GetActivtiyField(var.act_id, "award")
			var.limit_lv = GetActivtiyField(var.act_id, "limit_lv")
			var.times = GetActivtiyField(var.act_id, "times")
			var.add_exp = GetActivtiyField(var.act_id, "add_exp")
			var.id = GetActivtiyField(var.act_id, "id")
			var.recommend = GetActivtiyField(var.act_id, "recommend")
			var.is_gm = true
			table.insert(result_act_list, var)
		end
	end

	return result_act_list
end

function ActivityMgrCtrl:CheckMsgActivity()
	self.activity_data:CheckMsgActivity()
end

function ActivityMgrCtrl:CheckHd()
	return self.activity_data:CheckCanGetAward()
end

game.ActivityMgrCtrl = ActivityMgrCtrl

return ActivityMgrCtrl