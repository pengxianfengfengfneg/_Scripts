local TaskItem = Class(game.UITemplate)

local timer_mgr = global.TimerMgr
local string_format = string.format
local handler = handler

local et = {}

function TaskItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function TaskItem:OpenViewCallBack()
	self:Init()
end

function TaskItem:CloseViewCallBack()
    self:ClearTimer()
end

function TaskItem:Init()
	self.txt_name = self._layout_objs["txt_name"]
	self.rtx_desc = self._layout_objs["rtx_desc"]

	self.txt_time = self._layout_objs["txt_time"]	
	
end

function TaskItem:UpdateData(data)
    if data == nil then
        return
    end
	self.task_id = data.id

	self.name_func = data.name_func
    self.desc_func = data.desc_func
    self.click_func = data.click_func
    self.time_func = data.time_func

    self.task_state = data.stat
    self.task_masks = data.masks

    self.txt_time:SetVisible(self.time_func~=nil)

    self:ClearTimer()
	self:StartTimer()

    self:UnBindAllEvents()

    self:RegisterActionEvents()
    
    self:CheckTaskState()
end

function TaskItem:CheckTaskState()
    if self.name_func then
        self.txt_name:SetText(self.name_func())
        self.rtx_desc:SetText(self.desc_func())
    else
        local task_cfg = self.ctrl:GetTaskCfg(self.task_id)
        local task_name = self.ctrl:GetTaskShowName(task_cfg.type, task_cfg.name)

        local task_state = self.task_state
        if task_state == game.TaskState.NotAcceptable then
            self.txt_name:SetText(task_name)

            local lv = 1
            local cond = self.task_masks[1]
            if cond then
                lv = cond.total
            end
            self.rtx_desc:SetText(string.format(config.words[2153], lv))
        elseif task_state == game.TaskState.Acceptable then
            self.txt_name:SetText(config.words[2189])
            self.rtx_desc:SetText(task_name)
        else
            local task_desc = task_cfg.desc
            local str_process = game.TaskStateWord[task_state]
            local cond = self.task_masks[1]
            if cond then
                if task_state == game.TaskState.Accepted then
                    str_process = string.format("%s/%s", cond.current, cond.total)
                end
            else
                local is_finish = self.ctrl:CheckTaskFinish(self.task_id)
                if not is_finish then
                    str_process = "0/1"
                end
            end
            str_process = string.format("(%s)", str_process)
            task_desc = string.format(config.words[2191], task_desc, str_process)

            self.txt_name:SetText(task_name)
            self.rtx_desc:SetText(task_desc)
        end
    end
end

function TaskItem:OnClick()
	game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_main/new_main_view/mid_bottom/task_com/touch_com"})

    game.GuideCtrl.instance:SetCurClickTaskId(self.task_id)
    game.ViewMgr:FireGuideEvent()

	if self.click_func then
        self.click_func()
    else
        local is_get_reward = true
        if self.ctrl:ShouldTaskFindNpc(self.task_id) then
            is_get_reward = false
        end

        if not self.ctrl:CheckTaskFinish(self.task_id) then
            is_get_reward = false
        end

        if is_get_reward then
            self.ctrl:SendTaskGetReward(self.task_id)
        else
            local main_role = game.Scene.instance:GetMainRole()
            if main_role then
                main_role:GetOperateMgr():DoHangTask(self.task_id)
            end
        end
	end
end

function TaskItem:GetTaskName(task_type, name)
    return game.TaskTypeName[task_type] .. name
end

function TaskItem:GetTaskId()
	return self.task_id
end

local time_func = game.Utils.SecToTimeEn
local time_format = game.TimeFormatEn.MinSec
function TaskItem:TickFunc(is_time)
	if self.time_func then
		local left_time = self.time_func()
		local str_time = time_func(left_time, time_format)
		self.txt_time:SetText(string_format("(%s)",str_time))

		return left_time
	end
	return 0
end

function TaskItem:ClearTimer()
	if self.timer_id then
		timer_mgr:DelTimer(self.timer_id)
		self.timer_id = nil
	end
end

function TaskItem:StartTimer()
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

function TaskItem:RegisterActionEvents()
    local update_event = nil
    local task_cfg = self.ctrl:GetTaskCfg(self.task_id)
    if #task_cfg.update_event then
        update_event = task_cfg.update_event
    end

    for _,v in ipairs(update_event or et) do
        local event_name = self.ctrl:GetTaskUpdateEvent(v)
        if event_name then
            self:BindEvent(event_name, handler(self,self.CheckTaskState))
        end
    end
end

return TaskItem
