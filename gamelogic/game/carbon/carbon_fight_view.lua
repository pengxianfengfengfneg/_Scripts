local CarbonFightView = Class(game.BaseView)

function CarbonFightView:_init(ctrl)
	self._package_name = "ui_carbon"
    self._com_name = "carbon_fight_view"
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1
    self._view_level = game.UIViewLevel.Standalone
	self.ctrl = ctrl
end

function CarbonFightView:_delete()

end

function CarbonFightView:CloseViewCallBack()
	self:DelTimer()
	self:ClearFinishCD()
end

function CarbonFightView:OpenViewCallBack()

    self._layout_objs["n3"]:AddClickCallBack(function()
    	self.ctrl:DungLeaveReq()
    end)

    self.dun_data = self.ctrl:GetDunFightData()
    if self.dun_data then
    	self:SetTimer()
    end

    self:BindEvent(game.CarbonEvent.OnDungData, function(data)
    	self.dun_data = data
    	self:SetTimer()
	end)

	self:BindEvent(game.CarbonEvent.OnDungResult, function(data)
    	self:OnDungResult(data)
	end)
end

function CarbonFightView:SetTimer()
	if not self.dun_data then
		return
	end

	local dung_id = self.dun_data.dung_id
	local now_lv = self.dun_data.level
	local chapt, wave = self.ctrl:GetDungeonChatWave(dung_id, now_lv)
	local chapt_cfg = config.dungeon_lv[dung_id][chapt]
	local cfg = chapt_cfg.wave_list[wave]
	local limit_time = cfg[2]

	if self.ctrl:IsTeamCarbon(dung_id) then
		local pass_cond = chapt_cfg.pass_cond
		for _,v in ipairs(pass_cond) do
			if v[1] == 2 then
				limit_time = v[2]
				break
			end
		end
	end

	if limit_time == 0 then
		--隐藏倒计时
		self._layout_objs["n0"]:SetVisible(false)
		self._layout_objs["left_time_txt"]:SetVisible(false)
	else
		--显示倒计时
		local begin_time = self.dun_data.begin_time
		local finish_time = begin_time + limit_time

		local left_time = finish_time - global.Time:GetServerTime() + 1

		local function UpdateTime()
			left_time = left_time - 1
    		local str = game.Utils.SecToTime(left_time)
    		self._layout_objs["left_time_txt"]:SetText(string.format(config.words[1408], str))

    		if left_time <= 0 then
    			self:DelTimer()
    		end
		end
		UpdateTime()
		
		self:DelTimer()
		self.timer = global.TimerMgr:CreateTimer(1,UpdateTime)
		self._layout_objs["n0"]:SetVisible(true)
		self._layout_objs["left_time_txt"]:SetVisible(true)
	end
end

function CarbonFightView:DelTimer()
	if self.timer then
    	global.TimerMgr:DelTimer(self.timer)
    	self.timer = nil
    end
end

function CarbonFightView:OnDungResult(data)
	self:DelTimer()

	local dung_id = self.dun_data.dung_id
	if self.ctrl:IsTeamCarbon(dung_id) then
		self:StartFinishCD()
	end
end

function CarbonFightView:StartFinishCD()
	self:ClearFinishCD()

	local left_time = 10 + 1
	local function UpdateTime()
		left_time = left_time - 1
		local str = game.Utils.SecToTime(left_time)
		self._layout_objs["left_time_txt"]:SetText(string.format(config.words[1408], str))

		if left_time <= 0 then
			self.ctrl:DungLeaveReq()
			self:ClearFinishCD()
		end
	end
	UpdateTime()

	self.finish_timer = global.TimerMgr:CreateTimer(1,UpdateTime)
	self._layout_objs["n0"]:SetVisible(true)
	self._layout_objs["left_time_txt"]:SetVisible(true)
end

function CarbonFightView:ClearFinishCD()
	if self.finish_timer then
		global.TimerMgr:DelTimer(self.finish_timer)
    	self.finish_timer = nil
	end
end

return CarbonFightView