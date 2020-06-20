local MainTaskItem = Class(game.UITemplate)

local et = {}
local handler = handler
local string_format = string.format
local config_task = config.task
local config_words = config.words

local TaskCate = game.TaskCate
local TaskState = game.TaskState
local TaskStateWord = game.TaskStateWord
local TaskTypeName = game.TaskTypeName

local timer_mgr = global.TimerMgr

function MainTaskItem:_init()
    
end

function MainTaskItem:OpenViewCallBack()
	self:Init()
	
end

function MainTaskItem:CloseViewCallBack()
    self:ClearTimer()
end

function MainTaskItem:Init()
	self.ctrl = game.TaskCtrl.instance

	self.rtx_title = self._layout_objs["rtx_title"]	
	self.rtx_desc = self._layout_objs["rtx_desc"]	
	self.txt_time = self._layout_objs["txt_time"]	

	self:GetRoot():AddClickCallBack(function()
		
		self:OnClick()
	end)
end

function MainTaskItem:UpdateData(data)
	self.task_cate = data.cate
	self.task_type = data.type

	self.click_func = nil
	if self.task_cate == TaskCate.Daily then
		self.name_func = data.name_func
		self.desc_func = data.desc_func

		self.click_func = data.click_func

		self.time_func = data.time_func
	end

	self.task_id = data.id
	self.task_state = data.stat

	self.task_info = data

	self:UpdateTask()
end

local OrignSize = {285,80}
local TimerSize = {285,94}
function MainTaskItem:UpdateTask()
	self.txt_time:SetVisible(self.time_func~=nil)
	self:ClearTimer()
	self:StartTimer()

	self.rtx_desc:SetText(" ")

	local size = OrignSize
	if self.time_func then
		size = TimerSize
	end
	self:GetRoot():SetSize(size[1], size[2])

	if self.task_cate == TaskCate.Daily then
		self.rtx_title:SetText(self.name_func())
		self.rtx_desc:SetText(self.desc_func())
	else
		self.task_cfg = self.ctrl:GetTaskCfg(self.task_id)

		local task_name = self:GetTaskName(self.task_cfg.type, self.task_cfg.name)
		if self.task_state == TaskState.Acceptable then
			self.rtx_title:SetText(config_words[2189])
			self.rtx_desc:SetText(task_name)
		else
			local task_desc = self.task_cfg.desc
			local cond = self.task_info.masks[1]
			if cond then
				local str_process = TaskStateWord[self.task_state]
				if self.task_state == TaskState.Accepted then
					str_process = string_format("%s/%s", cond.current, cond.total)
				end
				task_desc = string_format(config_words[2191], task_desc, str_process)
			end

			self.rtx_title:SetText(task_name)
			self.rtx_desc:SetText(task_desc)
		end
	end
end

function MainTaskItem:GetTaskName(task_type, name)
	return TaskTypeName[task_type] .. name
end

local time_func = game.Utils.SecToTimeEn
local time_format = game.TimeFormatEn.HourMinSec
function MainTaskItem:TickFunc(is_time)
	if self.time_func then
		local left_time = self.time_func()
		local str_time = time_func(left_time, time_format)
		self.txt_time:SetText(str_time)

		return left_time
	end
	return 0
end

function MainTaskItem:ClearTimer()
	if self.timer_id then
		timer_mgr:DelTimer(self.timer_id)
		self.timer_id = nil
	end
end

function MainTaskItem:StartTimer()
	if not self.time_func then
		return
	end

	self:TickFunc(false)

	self.timer_id = timer_mgr:CreateTimer(1, function()
		local left_time = self:TickFunc(true)
		if left_time <= 0 then
			self:ClearTimer()
			return true
		end
	end)
end

function MainTaskItem:OnClick()
	if self.click_func then
		self.click_func()
	else
		if self.task_state == TaskState.Acceptable or self.task_state==TaskState.Accepted then
			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoHangTask(self.task_id)
			return
		end

		if self.task_state == TaskState.Finished then
			self.ctrl:SendTaskGetReward(self.task_id)
		end
	end
end

return MainTaskItem
