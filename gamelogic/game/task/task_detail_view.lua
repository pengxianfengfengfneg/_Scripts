local TaskDetailView = Class(game.BaseView)

local handler = handler
local event_mgr = global.EventMgr
local config_task = config.task

local DailyTaskConfig = require("game/task/daily_task_config")

function TaskDetailView:_init(ctrl)
    self._package_name = "ui_task"
    self._com_name = "task_detail_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end


function TaskDetailView:OpenViewCallBack(task_id)
	self:Init(task_id)
	self:InitRewards()

	self:RegisterAllEvents()
end

function TaskDetailView:CloseViewCallBack()
	self:ClearRewards()
end

function TaskDetailView:RegisterAllEvents()
	local events = {
		{game.TaskEvent.OnGetTaskReward, handler(self,self.OnGetTaskReward)},
		{game.TaskEvent.OnCircleWilful, handler(self, self.OnCircleWilful)},
	}
	for _,v in ipairs(events) do
		self:BindEvent(v[1],v[2])
	end
end

function TaskDetailView:InitBg(title_name)
	self:GetBgTemplate("common_bg"):SetTitleName(title_name)
end

function TaskDetailView:GetTaskName(task_type, name)
	return game.TaskTypeName[task_type] .. name
end

function TaskDetailView:Init(task_id)
	self.task_id = task_id	
	self.task_cfg = self.ctrl:GetTaskCfg(self.task_id)

	self.rtx_desc = self._layout_objs["rtx_desc"]
	self.rtx_desc2 = self._layout_objs["rtx_desc2"]

	self.is_main_task = false
	self.is_runloop_task = false
	self.is_daily_task = false

	self:InitMainTask()
	self:InitDailyTask()
	self:InitRunLoopTask()

	self:UpdateTaskState()
end

function TaskDetailView:InitMainTask()
	if self.task_cfg.cate ~= game.TaskCate.Main and 
		self.task_cfg.cate ~=game.TaskCate.Branch then
		return
	end

	self.is_main_task = true

	local task_name = self:GetTaskName(self.task_cfg.type, self.task_cfg.name)
	self:InitBg(task_name)

	self.rtx_desc:SetText(self:ReplaceDesc(self.task_cfg.desc))
	self.rtx_desc2:SetText(self:ReplaceDesc(self.task_cfg.desc2))

	self.btn_fast = self._layout_objs["btn_fast"]
	self.btn_ask_help = self._layout_objs["btn_ask_help"]

	self.btn_fast:SetVisible(false)
	self.btn_ask_help:SetVisible(false)

	self.btn_go = self._layout_objs["btn_go"]
	self.btn_go:AddClickCallBack(function()
		local main_role = game.Scene.instance:GetMainRole()
		main_role:GetOperateMgr():DoHangTask(self.task_id)

		self:Close()
		self.ctrl:CloseView()
	end)

	self.btn_finish = self._layout_objs["btn_finish"]
	self.btn_finish:AddClickCallBack(function()
		self.ctrl:SendTaskGetReward(self.task_id)

		self:Close()
	end)

	self.btn_abandon = self._layout_objs["btn_abandon"]
	self.btn_abandon:SetVisible(false)

	self.btn_go:SetPosition(257,802)
end

function TaskDetailView:InitDailyTask()
	if self.task_cfg.cate ~= game.TaskCate.Daily then
		return
	end

	self.btn_fast = self._layout_objs["btn_fast"]
	self.btn_ask_help = self._layout_objs["btn_ask_help"]

	self.btn_fast:SetVisible(false)
	self.btn_ask_help:SetVisible(false)

	self.daily_task_cfg = DailyTaskConfig[self.task_id]
	
	if self.daily_task_cfg then
		local task_name = self.daily_task_cfg.name_func(true)
		self:InitBg(task_name)

		self.rtx_desc:SetText(self:ReplaceDesc(self.daily_task_cfg.desc_func(true,true)))
		self.rtx_desc2:SetText(self:ReplaceDesc(self.daily_task_cfg:desc_func2(true,true)))

		self.btn_go = self._layout_objs["btn_go"]
		self.btn_go:AddClickCallBack(function()
			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoHangTask(self.task_id)

			self:Close()
			self.ctrl:CloseView()
		end)	

		local has_abandon = self.daily_task_cfg.abandon_func()
		self.btn_abandon = self._layout_objs["btn_abandon"]
		self.btn_abandon:SetVisible(has_abandon)
		self.btn_abandon:AddClickCallBack(function()
			self.daily_task_cfg.abandon_func(true)

			self:Close()
		end)

		self.btn_finish = self._layout_objs["btn_finish"]
		self.btn_finish:SetVisible(false)

		local x = 257
		if has_abandon then
			x = 387
		end
		self.btn_go:SetPosition(x,802)
	else
		self.is_daily_task = true

		local task_name = self:GetTaskName(self.task_cfg.type, self.task_cfg.name)
		self:InitBg(task_name)

		self.rtx_desc:SetText(self:ReplaceDesc(self.task_cfg.desc))
		self.rtx_desc2:SetText(self:ReplaceDesc(self.task_cfg.desc2))

		self.btn_go = self._layout_objs["btn_go"]
		self.btn_go:AddClickCallBack(function()
			local main_role = game.Scene.instance:GetMainRole()
			main_role:GetOperateMgr():DoHangTask(self.task_id)

			self:Close()
			self.ctrl:CloseView()
		end)

		self.btn_finish = self._layout_objs["btn_finish"]
		self.btn_finish:AddClickCallBack(function()
			self.ctrl:SendTaskGetReward(self.task_id)

			self:Close()
		end)
	end
end

local FastRunloopType = {
	[game.TaskType.RunLoop3] = 1,
	[game.TaskType.RunLoop4] = 1,
}
local AskHelpRunloopType = {
	[game.TaskType.RunLoop3] = 1,
}
function TaskDetailView:InitRunLoopTask()
	if self.task_cfg.cate ~= game.TaskCate.RunLoop then
		return
	end

	self.is_runloop_task = true

	local task_name = self:GetTaskName(self.task_cfg.type, self.task_cfg.name)
	self:InitBg(task_name)

	self.btn_fast = self._layout_objs["btn_fast"]
	self.btn_ask_help = self._layout_objs["btn_ask_help"]

	local can_fast = (FastRunloopType[self.task_cfg.type]~=nil)
	local can_ask_help = (AskHelpRunloopType[self.task_cfg.type]~=nil)
	self.btn_fast:SetVisible(can_fast)
	self.btn_ask_help:SetVisible(can_ask_help)

	self.btn_fast:AddClickCallBack(function()
		self.ctrl:OpenCircleTaskWilfulView()
		self:Close()
	end)

	self.btn_ask_help:AddClickCallBack(function()
		self.ctrl:SendCircleAskForHelp()
	end)

	self.rtx_desc:SetText(self:ReplaceDesc(self.task_cfg.desc))
	self.rtx_desc2:SetText(self:ReplaceDesc(self.task_cfg.desc2))

	self.btn_go = self._layout_objs["btn_go"]
	self.btn_go:AddClickCallBack(function()
		local main_role = game.Scene.instance:GetMainRole()
		main_role:GetOperateMgr():DoHangTask(self.task_id)

		self:Close()
		self.ctrl:CloseView()
	end)

	self.btn_finish = self._layout_objs["btn_finish"]
	self.btn_finish:AddClickCallBack(function()
		self.ctrl:SendTaskGetReward(self.task_id)

		self:Close()
	end)

	self.btn_abandon = self._layout_objs["btn_abandon"]
	self.btn_abandon:AddClickCallBack(function()
		
	end)
end

function TaskDetailView:InitRewards()
	self.reward_item_list = {}
	self.list_reward = self._layout_objs["list_reward"]
	self.list_money = self._layout_objs["list_money"]

	local drop_cfg = config.drop[self.task_cfg.rewards]
	if self.is_runloop_task or self.is_daily_task then
		local lv = game.Scene.instance:GetMainRoleLevel()
		local lv_cfg = config.level[lv]

		local times = self.ctrl:GetCircleTimes() + 1
		local times_cfg = config.circle_reward[times]
		local exp = lv_cfg.circle_exp * times_cfg.mul

		drop_cfg = {
			client_goods_list = {
				{
					game.MoneyGoodsId[game.MoneyType.Exp], exp	
				}
			}	
		}
	end

	if not drop_cfg then
		return
	end
	
	local drop_goods = drop_cfg.client_goods_list

	local money_list = {}
	local reward_list = {}
	for _,v in ipairs(drop_goods) do
		local list = reward_list
		local currency_cfg = self:GetCurrencyCfg(v[1])
		if currency_cfg then
			list = money_list
		end

		table.insert(list, v)
	end

	self.list_reward:SetItemNum(#reward_list)
	self.list_money:SetItemNum(#money_list)

	for k,v in ipairs(money_list) do
		local currency_cfg = self:GetCurrencyCfg(v[1])
		local obj = self.list_money:GetChildAt(k-1)
		obj:SetText(v[2])
		obj:SetIcon("ui_common", currency_cfg.icon)
	end

	for k,v in ipairs(reward_list)	 do
		local obj = self.list_reward:GetChildAt(k-1)
		local item = game_help.GetGoodsItem(obj:GetChild("item"), true)
		item:SetItemInfo({id=v[1],num=v[2]})

		table.insert(self.reward_item_list, item)
	end

	local y = 689
	if #money_list <= 0 then
		y = 639
	end
	self.list_reward:SetPosition(90, y)
end

function TaskDetailView:ClearRewards()
	for _,v in ipairs(self.reward_item_list) do
		v:DeleteMe()
	end
	self.reward_item_list = {}
end

function TaskDetailView:UpdateTaskState()
	if self.is_main_task or self.is_runloop_task or self.is_daily_task then
		local is_finish = self.ctrl:CheckTaskFinish(self.task_id) and (not self.ctrl:ShouldTaskFindNpc(self.task_id))
		self.btn_go:SetVisible(not is_finish)
		self.btn_finish:SetVisible(is_finish)
	end
end

function TaskDetailView:OnGetTaskReward(task_id)
	if self.task_id == task_id then
		self:Close()
	end
end

function TaskDetailView:GetCurrencyCfg(item_id)
	return game.MoneyItemMap[item_id]
end

function TaskDetailView:OnEmptyClick()
	self:Close()
end

function TaskDetailView:OnCircleWilful()
	self:Close()
end

function TaskDetailView:ReplaceDesc(desc)
	local desc = string.gsub(desc, game.ColorString.Green, game.ColorString.DarkGreen)
	return string.gsub(desc, game.ColorString.PaleYellow, game.ColorString.Orange)
end

return TaskDetailView
