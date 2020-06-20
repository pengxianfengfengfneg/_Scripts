local GuildArenaRestroomView = Class(game.BaseView)

function GuildArenaRestroomView:_init(ctrl)
	self._package_name = "ui_guild_arena"
    self._com_name = "rest_room_view"
    self.ctrl = ctrl
    self.data = self.ctrl:GetData()
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Low
    self._view_level = game.UIViewLevel.Standalone
end

function GuildArenaRestroomView:OpenViewCallBack()

	self.ctrl:CsJoustsHallInfo()

	self:BindEvent(game.GuildArenaEvent.UpdateViewInfo, function(data)
		self:UpdateInfo(data)
	end)

	-- self._layout_objs["score_btn"]:AddClickCallBack(function()
	-- 	self.ctrl:OpenScoreAwardView()
 --    end)

 --    self._layout_objs["quit_btn"]:AddClickCallBack(function()
 --    	self.ctrl:CsJoustsHallLeaveL()
 --    end)
end

function GuildArenaRestroomView:CloseViewCallBack()
	self:DelTimer()
end

function GuildArenaRestroomView:UpdateInfo(data)

	--活动已结束
	if data.is_out == 2 then

		local act_info = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildArena)
		local act_close_time = act_info.end_time

		self._layout_objs["n6"]:SetText(config.words[5221])
		self._layout_objs["txt1"]:SetText("")
		self._layout_objs["txt2"]:SetText("")

		self:DelTimer()
		local role_lv = game.Scene.instance:GetMainRoleLevel() or 1
		local exp = config.level[role_lv].jousts_hall_add_exp
		self._layout_objs["txt_exp"]:SetText(exp)
	--已淘汰
	elseif data.is_out == 1 then

		local act_info = game.ActivityMgrCtrl.instance:GetActivity(game.ActivityId.GuildArena)
		local act_close_time = act_info.end_time

		self._layout_objs["n6"]:SetText(config.words[5201])
		self._layout_objs["txt1"]:SetText(config.words[5203])

		local cur_time = global.Time:GetServerTime()
		local left_time = act_close_time - cur_time
		self:DelTimer()
		self.timer = global.TimerMgr:CreateTimer(1,
			function()

				if left_time <= 0 then
					self:DelTimer()
				else
					left_time = left_time - 1
					self._layout_objs["txt2"]:SetText(game.Utils.SecToTime2(left_time))
				end
			end)

		local role_lv = game.Scene.instance:GetMainRoleLevel() or 1
		local exp = config.level[role_lv].jousts_hall_add_exp
		self._layout_objs["txt_exp"]:SetText(exp)
	--等待进入
	else
		self._layout_objs["n6"]:SetText(config.words[5200])
		self._layout_objs["txt1"]:SetText(config.words[5202])

		local rest_room_data = self.data:GetRestRoomData()
		local enter_arena_time = rest_room_data.enter_time
		local cur_time = global.Time:GetServerTime()
		local left_time = enter_arena_time - cur_time

		self:DelTimer()
		self.timer = global.TimerMgr:CreateTimer(1,
			function()

				if left_time <= 0 then
					self:DelTimer()
				else
					left_time = left_time - 1
					self._layout_objs["txt2"]:SetText(game.Utils.SecToTime2(left_time))
				end
			end)

		local role_lv = game.Scene.instance:GetMainRoleLevel() or 1
		local exp = config.level[role_lv].jousts_hall_add_exp
		self._layout_objs["txt_exp"]:SetText(exp)
	end
end

function GuildArenaRestroomView:DelTimer()
	if self.timer then
		global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
	end
end

return GuildArenaRestroomView