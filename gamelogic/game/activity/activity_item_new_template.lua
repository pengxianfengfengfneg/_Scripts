local ActivityItemNewTemplate = Class(game.UITemplate)

function ActivityItemNewTemplate:_init(parent)
	self.parent = parent
	self.activity_data = game.ActivityMgrCtrl.instance:GetData()
	self.activity_ctrl = game.ActivityMgrCtrl.instance
end

function ActivityItemNewTemplate:OpenViewCallBack()

	self._layout_objs["use_btn"]:AddClickCallBack(function()
		if self.parent:GetType() ~= 1 then
			local cfg = game.ActivityLinkFunc[self.act_id]
			if cfg and cfg.check_func() then
				local act_cfg = self:GetActHallCfg(self.act_id)
				cfg.click_func(act_cfg)
				game.ActivityMgrCtrl.instance:CloseActivityHallView()
			end
		else
			local cfg = game.ActivityHallTypeOneLink[self.act_cfg.id]
			if cfg and cfg.check_func() then
				game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_activity/activity_hall_view/activity_daily_template/btn"})
				cfg.click_func(self.act_cfg)
				game.ActivityMgrCtrl.instance:CloseActivityHallView()
			end
		end
    end)
end

function ActivityItemNewTemplate:GetActHallCfg(act_id)
	for _,v in pairs(config.activity_hall) do
		if v.act_id == act_id then
			return v
		end
	end
end

function ActivityItemNewTemplate:CloseViewCallBack()

end

function ActivityItemNewTemplate:RefreshItem(idx)

	local act_list = self.parent:GetListData()

	self._layout_objs["n16"]:SetText(config.words[4036])

	if self.parent:GetType() == 1 then
		self:SetDailyAct(act_list, idx)
	elseif self.parent:GetType() == 3 then
		self:SetGmAct(act_list, idx)
	elseif self.parent:GetType() == 4 then
		self:SetTypeFour(idx)
	else
		local daily_index_list = self.parent:GetDailyIndexListData()
		local act_id = act_list[idx]
		local daily_indexs = daily_index_list[act_id]

		self:SetConfigAct(act_id, daily_indexs)
	end

	-- if (idx%2) == 1 then
	-- 	self._layout_objs["n7"]:SetSprite("ui_common", "005")
	-- else
	-- 	self._layout_objs["n7"]:SetSprite("ui_common", "006_bt")
	-- end
end

--配置 类型
function ActivityItemNewTemplate:SetConfigAct(act_id, daily_indexs)

	self.tab_index = self.parent:GetType()
	self.act_id = act_id

	local act_cfg
	for k, v in pairs(config.activity_hall) do
		if v.act_id == act_id then
			act_cfg = v
			break
		end
	end

	self._layout_objs["activity_img"]:SetSprite("ui_activity", act_cfg.icon)

	self._layout_objs["activity_name"]:SetText(act_cfg.name)

	local complete_times = self.activity_data:GetActivityCompleteTimes(act_cfg.id)

	if act_cfg.add_exp == 0 then
		self._layout_objs["activity_value"]:SetText(config.words[1552])
	else
		local cur_value = complete_times*act_cfg.add_exp
		local max_value = act_cfg.times*act_cfg.add_exp
		self._layout_objs["activity_value"]:SetText(tostring(cur_value).."/"..tostring(max_value))
	end

	if act_cfg.times == 0 then
		self._layout_objs["activity_times"]:SetText(config.words[4035])
	else
		self._layout_objs["activity_times"]:SetText(tostring(complete_times).."/"..tostring(act_cfg.times))
	end

	--选择当前日常活动表信息
	local cur_daily_cfg
	local cur_time = global.Time:GetServerTime()
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

	self.cur_daily_cfg = cur_daily_cfg

	self._layout_objs["activity_time"]:SetText(string.format(config.words[4030], cur_daily_cfg.start_time[1], cur_daily_cfg.start_time[2]))

	local btn_state = self.activity_data:GetCfgActivityState(cur_daily_cfg.id)

	if btn_state == game.ActivityState.ACT_STATE_UNDEFINE or btn_state == game.ActivityState.ACT_STATE_PREPARE then
		self._layout_objs["n15"]:SetVisible(true)
		self._layout_objs["n16"]:SetVisible(true)
		self._layout_objs["activity_time"]:SetVisible(true)

		self._layout_objs["n18"]:SetVisible(false)
		self._layout_objs["use_btn"]:SetVisible(false)

	elseif btn_state == game.ActivityState.ACT_STATE_ONGOING then
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(false)
		self._layout_objs["use_btn"]:SetVisible(true)

	elseif btn_state == game.ActivityState.ACT_STATE_FINISH or btn_state == game.ActivityState.ACT_STATE_REMOVE then
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(true)
		self._layout_objs["n18"]:SetSprite("ui_common", "hd_09")
		self._layout_objs["use_btn"]:SetVisible(false)
	end

	--超出次数限制
	if complete_times >= act_cfg.times and act_cfg.times > 0 then
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(true)
		self._layout_objs["n18"]:SetSprite("ui_common", "hd_04")
		self._layout_objs["use_btn"]:SetVisible(false)
	end

	self._layout_objs["recommend"]:SetVisible(act_cfg.recommend == 1)
end

--gm 类型
function ActivityItemNewTemplate:SetGmAct(act_list, idx)

	local act_cfg = act_list[idx]
	local act_id = act_cfg.act_id
	self.act_id = act_id
	self.act_cfg = act_cfg

	self._layout_objs["activity_img"]:SetSprite("ui_activity", act_cfg.icon)

	self._layout_objs["activity_name"]:SetText(act_cfg.name)

	local complete_times = self.activity_data:GetActivityCompleteTimes(act_cfg.id)

	if act_cfg.add_exp == 0 then
		self._layout_objs["activity_value"]:SetText(config.words[1552])
	else
		local cur_value = complete_times*act_cfg.add_exp
		local max_value = act_cfg.times*act_cfg.add_exp
		self._layout_objs["activity_value"]:SetText(tostring(cur_value).."/"..tostring(max_value))
	end

	if act_cfg.times == 0 then
		self._layout_objs["activity_times"]:SetText(config.words[4035])
	else
		self._layout_objs["activity_times"]:SetText(tostring(complete_times).."/"..tostring(act_cfg.times))
	end

	local btn_state = self.activity_data:GetActivityState(self.act_id)

	if btn_state == game.ActivityState.ACT_STATE_UNDEFINE or btn_state == game.ActivityState.ACT_STATE_PREPARE then
		self._layout_objs["n15"]:SetVisible(true)
		self._layout_objs["n16"]:SetVisible(true)
		self._layout_objs["activity_time"]:SetVisible(true)

		self._layout_objs["n18"]:SetVisible(false)
		self._layout_objs["use_btn"]:SetVisible(false)

	elseif btn_state == game.ActivityState.ACT_STATE_ONGOING then
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(false)
		self._layout_objs["use_btn"]:SetVisible(true)

	elseif btn_state == game.ActivityState.ACT_STATE_FINISH or btn_state == game.ActivityState.ACT_STATE_REMOVE then
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(true)
		self._layout_objs["n18"]:SetSprite("ui_common", "hd_09")
		self._layout_objs["use_btn"]:SetVisible(false)
	end

	--超出次数限制
	if complete_times >= act_cfg.times and act_cfg.times > 0 then
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(true)
		self._layout_objs["n18"]:SetSprite("ui_common", "hd_04")
		self._layout_objs["use_btn"]:SetVisible(false)
	end

	for k, v in pairs(config.daily_activity_schedule) do

		if v.act_id == self.act_id then
			self.cur_daily_cfg = v
			break
		end
	end
end

function ActivityItemNewTemplate:SetSelect(val)

	self._layout_objs["select_img"]:SetVisible(val)
end

function ActivityItemNewTemplate:GetDailyCfg()
	return self.cur_daily_cfg
end

--包含服务器发的 活动开关时间
function ActivityItemNewTemplate:GetGmCfg()
	return self.act_cfg
end

function ActivityItemNewTemplate:SetDailyAct(act_list, idx)
	
	local act_cfg = act_list[idx]
	self.act_cfg = act_cfg

	self._layout_objs["activity_img"]:SetSprite("ui_activity", act_cfg.icon)

	if act_cfg.id == 1011 then
		local thief_info = game.DailyTaskCtrl.instance:GetThiefInfo()
		local finish_times = 0
		if thief_info then
			finish_times = thief_info.daily_times
		end

		if finish_times >= config.daily_thief.mul_reward_times then
			self._layout_objs["activity_name"]:SetText(act_cfg.name..config.words[1972])
		else
			self._layout_objs["activity_name"]:SetText(act_cfg.name..config.words[1971])
		end

	else
		self._layout_objs["activity_name"]:SetText(act_cfg.name)
	end

	local complete_times = self.activity_data:GetActivityCompleteTimes(act_cfg.id)

	if act_cfg.add_exp == 0 then
		self._layout_objs["activity_value"]:SetText(config.words[1552])
	else
		local cur_value = complete_times*act_cfg.add_exp
		local max_value = act_cfg.times*act_cfg.add_exp
		self._layout_objs["activity_value"]:SetText(tostring(cur_value).."/"..tostring(max_value))
	end


	if act_cfg.times == 0 then
		self._layout_objs["activity_times"]:SetText(config.words[4035])
	else
		self._layout_objs["activity_times"]:SetText(tostring(complete_times).."/"..tostring(act_cfg.times))
	end

	--超出次数限制
	if complete_times >= act_cfg.times and act_cfg.times > 0 then
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(true)
		self._layout_objs["use_btn"]:SetVisible(false)
		self._layout_objs["n18"]:SetSprite("ui_common", "hd_04")
	else
		self._layout_objs["n15"]:SetVisible(false)
		self._layout_objs["n16"]:SetVisible(false)
		self._layout_objs["activity_time"]:SetVisible(false)

		self._layout_objs["n18"]:SetVisible(false)
		self._layout_objs["use_btn"]:SetVisible(true)
	end

	self._layout_objs["recommend"]:SetVisible(act_cfg.recommend == 1)
end

function ActivityItemNewTemplate:GetActCfg()
	return self.act_cfg
end

function ActivityItemNewTemplate:SetTypeFour(idx)

	local act_list = self.parent:GetListData()
	local daily_task_list = self.parent:GetDailyTaskListData()
	local daily_index_list = self.parent:GetDailyIndexListData()

	local act_cfg
	local cur_daily_cfg
	--日常任务
	if idx > #act_list then
		local i = idx - #act_list
		local j = daily_task_list[i]
		act_cfg = config.activity_hall[j]
	--日常活动
	else
		local act_id = act_list[idx]
		local daily_indexs = daily_index_list[act_id]
		for k, v in pairs(config.activity_hall) do
			if v.act_id == act_id then
				act_cfg = v
				break
			end
		end

		local cur_time = global.Time:GetServerTime()
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
			local last_index = daily_indexs[1]
			cur_daily_cfg = config.daily_activity_schedule[last_index]
		end

		local offset_day = self.activity_ctrl:GetDaysOpen(cur_daily_cfg.id)
		self._layout_objs["activity_time"]:SetText(string.format(config.words[4028], offset_day))
	end

	self.act_cfg = act_cfg
	self.cur_daily_cfg = cur_daily_cfg
	
	self._layout_objs["activity_img"]:SetSprite("ui_activity", act_cfg.icon)

	self._layout_objs["activity_name"]:SetText(act_cfg.name)

	local complete_times = self.activity_data:GetActivityCompleteTimes(act_cfg.id)

	if act_cfg.add_exp == 0 then
		self._layout_objs["activity_value"]:SetText(config.words[1552])
	else
		local cur_value = complete_times*act_cfg.add_exp
		local max_value = act_cfg.times*act_cfg.add_exp
		self._layout_objs["activity_value"]:SetText(tostring(cur_value).."/"..tostring(max_value))
	end

	if act_cfg.times == 0 then
		self._layout_objs["activity_times"]:SetText(config.words[4035])
	else
		self._layout_objs["activity_times"]:SetText(tostring(complete_times).."/"..tostring(act_cfg.times))
	end

	--即将开启页面(直接显示几天后开启或等级不足)
	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	if main_role_lv < act_cfg.limit_lv then
		self._layout_objs["n16"]:SetText(config.words[4037])
		self._layout_objs["activity_time"]:SetText(string.format(config.words[4029], act_cfg.limit_lv))
	end

	self._layout_objs["n15"]:SetVisible(true)
	self._layout_objs["n16"]:SetVisible(true)
	self._layout_objs["activity_time"]:SetVisible(true)

	self._layout_objs["n18"]:SetVisible(false)
	self._layout_objs["use_btn"]:SetVisible(false)
end

return ActivityItemNewTemplate