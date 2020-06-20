local ActivityItemTemplate = Class(game.UITemplate)

function ActivityItemTemplate:_init(parent)
	self.parent = parent
	self.activity_data = game.ActivityMgrCtrl.instance:GetData()
	self.activity_ctrl = game.ActivityMgrCtrl.instance
end

function ActivityItemTemplate:OpenViewCallBack()

	self._layout_objs["n4"]:AddClickCallBack(function()
		local cfg = game.ActivityLinkFunc[self.act_id]
		if cfg and cfg.check_func() then
			cfg.click_func()
			self:Close()
		end
    end)
end

function ActivityItemTemplate:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
end

function ActivityItemTemplate:RefreshItem(idx)

	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	self.tab_index = self.parent:GetTabIndex()
	local act_list
	if self.tab_index == 1 then
		act_list = self.activity_ctrl:GetTodayActivitys()
	else
		act_list = self.activity_ctrl:GetTomorrowActivitys()
	end

	local act_cfg = act_list[idx]
	if act_cfg.is_gm then
		self:SetGmAct(act_list, idx)
	else
		self:SetConfigAct(act_list, idx)
	end
end

--配置 类型
function ActivityItemTemplate:SetConfigAct(act_list, index)

	self.tab_index = self.parent:GetTabIndex()

	local act_cfg = act_list[index]
	local act_index_id = act_cfg.id
	local daily_cfg = config.daily_activity_schedule[act_index_id]
	self.act_id = daily_cfg.act_id

	self._layout_objs["n2"]:SetSprite("ui_activity", act_cfg.icon)

	if self.tab_index == 1 then
		self._layout_objs["n3"]:SetText(string.format(config.words[4023], daily_cfg.start_time[1], daily_cfg.start_time[2], daily_cfg.end_time[1], daily_cfg.end_time[2]))
	else
		local offset_day = self.activity_ctrl:GetDaysOpen(self.act_id)
		self._layout_objs["n3"]:SetText(string.format(config.words[4028], offset_day))
	end

	local btn_state = self.activity_data:GetCfgActivityState(act_index_id)

	if btn_state == game.ActivityState.ACT_STATE_UNDEFINE then
		self._layout_objs["n4"]:SetText(config.words[4026])
	elseif btn_state == game.ActivityState.ACT_STATE_PREPARE then
		self._layout_objs["n4"]:SetText(config.words[4026])
	elseif btn_state == game.ActivityState.ACT_STATE_ONGOING then
		self._layout_objs["n4"]:SetText(config.words[4024])
	elseif btn_state == game.ActivityState.ACT_STATE_FINISH then
		self._layout_objs["n4"]:SetText(config.words[4025])
	elseif btn_state == game.ActivityState.ACT_STATE_REMOVE then
		self._layout_objs["n4"]:SetText(config.words[4025])
	end

	local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
	if mainrole_lv < act_cfg.limit_lv then
		self._layout_objs["n4"]:SetText(string.format(config.words[4029], act_cfg.limit_lv))
	end

	--奖励物品
	local award = act_cfg.award
	local award_items = config.drop[award].client_goods_list

	if not self.ui_list then

		self.ui_list = game.UIList.New(self._layout_objs["list"])
		self.ui_list:SetVirtual(true)
		self.ui_list:SetCreateItemFunc(function(obj)
			local item = require("game/bag/item/goods_item").New()
			item:SetParent(self)
	        item:SetVirtual(obj)
	        item:Open()
	        item:SetShowTipsEnable(true)
	        return item
		end)

		self.ui_list:SetRefreshItemFunc(function(item, idx)

			local item_info = award_items[idx]
			item:SetItemInfo({ id = item_info[1], num = item_info[2]})
		end)

	end
	
	self.ui_list:SetItemNum(#award_items)
end

--gm 类型
function ActivityItemTemplate:SetGmAct(act_list, idx)

	local act_cfg = act_list[idx]
	local act_id = act_cfg.act_id
	local daily_cfg

	for key, var in pairs(config.daily_activity_schedule) do
		if var.act_id == act_id then
			daily_cfg = var
			break
		end
	end

	self.act_id = daily_cfg.act_id

	self._layout_objs["n2"]:SetSprite("ui_activity", act_cfg.icon)

	local s_time_tab = os.date("*t", act_cfg.start_time)
	local e_time_tab = os.date("*t", act_cfg.end_time)

	self._layout_objs["n3"]:SetText(string.format(config.words[4023], s_time_tab.hour, s_time_tab.min, e_time_tab.hour, e_time_tab.min))

	local btn_state = self.activity_data:GetActivityState(self.act_id)

	if btn_state == game.ActivityState.ACT_STATE_UNDEFINE then
		self._layout_objs["n4"]:SetText(config.words[4026])
	elseif btn_state == game.ActivityState.ACT_STATE_PREPARE then
		self._layout_objs["n4"]:SetText(config.words[4026])
	elseif btn_state == game.ActivityState.ACT_STATE_ONGOING then
		self._layout_objs["n4"]:SetText(config.words[4024])
	elseif btn_state == game.ActivityState.ACT_STATE_FINISH then
		self._layout_objs["n4"]:SetText(config.words[4025])
	elseif btn_state == game.ActivityState.ACT_STATE_REMOVE then
		self._layout_objs["n4"]:SetText(config.words[4025])
	end

	--奖励物品
	local award = act_cfg.award
	local award_items = config.drop[award].client_goods_list

	if not self.ui_list then

		self.ui_list = game.UIList.New(self._layout_objs["list"])
		self.ui_list:SetVirtual(true)
		self.ui_list:SetCreateItemFunc(function(obj)
			local item = require("game/bag/item/goods_item").New()
			item:SetParent(self)
	        item:SetVirtual(obj)
	        item:SetShowTipsEnable(true)
	        item:Open()
	        return item
		end)

		self.ui_list:SetRefreshItemFunc(function(item, idx)
			local item_info = award_items[idx]
			item:SetItemInfo({ id = item_info[1], num = item_info[2]})
		end)

	end

	self.ui_list:SetItemNum(#award_items)
end

return ActivityItemTemplate