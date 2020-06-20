local VowActivityTemplate = Class(game.UITemplate)

function VowActivityTemplate:_init(parent)
    self.parent = parent
    self.vow_data = game.VowCtrl.instance:GetData()
end

function VowActivityTemplate:_delete()
end

function VowActivityTemplate:OpenViewCallBack()

end

function VowActivityTemplate:CloseViewCallBack()
	self:DelTimer()
end

function VowActivityTemplate:RefreshItem(idx)

	local list = self.vow_data:GetTaskIdList(idx)
	for k,task_id in ipairs(list) do

		local complete_times = self.vow_data:GetTaskFinishTimes(task_id)
		local taks_cfg = config.vow_task[task_id]
		self._layout_objs["task_desc"..k]:SetText(taks_cfg.desc)
		self._layout_objs["qihe_val"..k]:SetText(taks_cfg.deed)
		self._layout_objs["progress"..k]:SetText(tostring(complete_times).."/"..taks_cfg.times)
	end

	local all_deed_data = self.vow_data:GetDeedData()
	local target_name = all_deed_data.target_name
	self._layout_objs["role_name"]:SetText(target_name)

	local end_time = all_deed_data.end_time
	local cur_time = global.Time:GetServerTime()
	local left_time = end_time - cur_time

	self:DelTimer()
	self.timer = global.TimerMgr:CreateTimer(1,
	    function()
	        left_time = left_time - 1
	        local str = game.Utils.SecToTimeCn(left_time, game.TimeFormatCn.DayHourMin)
	        self._layout_objs["left_time"]:SetText(str)

	        if left_time <= 0 then
	            self:DelTimer()
	        end
	    end)
end

function VowActivityTemplate:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

return VowActivityTemplate