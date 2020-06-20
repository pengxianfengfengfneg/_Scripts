local CircleTaskWilfulView = Class(game.BaseView)

local handler = handler
local config_task = config.task

function CircleTaskWilfulView:_init(ctrl)
    self._package_name = "ui_task"
    self._com_name = "circle_task_wilful_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function CircleTaskWilfulView:OpenViewCallBack()
	self:Init()
	self:InitBg()

	self:RegisterAllEvents()
end

function CircleTaskWilfulView:CloseViewCallBack()
	
end

function CircleTaskWilfulView:RegisterAllEvents()
	local events = {
		{game.TaskEvent.OnCircleWilful, handler(self, self.OnCircleWilful)},
	}
	for _,v in ipairs(events) do
		self:BindEvent(v[1],v[2])
	end
end

function CircleTaskWilfulView:Init()
	local circle_wilful_times = config.sys_config["circle_wilful_times"].value

	local type_cfg_1 = circle_wilful_times[1]
	local money_cfg_1 = config.money_type[type_cfg_1[1]]
	local left_times = self.ctrl:GetCircleWilfulLeftTimes(type_cfg_1[1])
	local word_id = (left_times>=1000 and 6305 or 6306)
	local str_content = string.format(config.words[word_id], type_cfg_1[3], money_cfg_1.icon, left_times)

	self.rtx_type_1 = self._layout_objs["rtx_type_1"]
	self.rtx_type_1:SetText(str_content)

	self.btn_type_1 = self._layout_objs["btn_type_1"]
	self.btn_type_1:AddClickCallBack(function()
		if left_times > 0 then
			self.ctrl:SendCircleWilful(type_cfg_1[1])
		else
			game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6307], money_cfg_1.name))
		end
	end)
	
	local type_cfg_2 = circle_wilful_times[2]
	local money_cfg_2 = config.money_type[type_cfg_2[1]]
	local left_times = self.ctrl:GetCircleWilfulLeftTimes(type_cfg_2[1])
	local word_id = (left_times>=1000 and 6305 or 6306)
	local color_str = (left_times>0 and game.ColorString.Green or game.ColorString.Red)
	local str_content = string.format(config.words[word_id], type_cfg_2[3], money_cfg_2.icon, color_str, left_times)
	self.rtx_type_2 = self._layout_objs["rtx_type_2"]
	self.rtx_type_2:SetText(str_content)

	self.btn_type_2 = self._layout_objs["btn_type_2"]
	self.btn_type_2:AddClickCallBack(function()
		if left_times > 0 then
			self.ctrl:SendCircleWilful(type_cfg_2[1])
		else
			game.GameMsgCtrl.instance:PushMsg(string.format(config.words[6307], money_cfg_2.name))
		end
	end)
end

function CircleTaskWilfulView:InitBg()
	self:GetBgTemplate("common_bg"):SetTitleName(config.words[1660])
end

function CircleTaskWilfulView:OnCircleWilful()
	self:Close()
end

function CircleTaskWilfulView:OnEmptyClick()
	self:Close()
end

return CircleTaskWilfulView
