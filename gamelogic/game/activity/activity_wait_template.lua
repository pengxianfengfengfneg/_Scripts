local ActivityWaitTemplate = Class(game.UITemplate)

function ActivityWaitTemplate:_init()
	self.ctrl = game.ActivityMgrCtrl.instance
end

function ActivityWaitTemplate:OpenViewCallBack()

	local act_list, act_daily_index_list, cfg_daily_task_list = self.ctrl:GetWaitOpenActivitys()
	self.act_list = act_list
	self.act_daily_index_list = act_daily_index_list
	self.cfg_daily_task_list = cfg_daily_task_list
	local act_num = #act_list
	act_num = act_num + #cfg_daily_task_list

	self.list = self._layout_objs["n0"]
	self.ui_list = game.UIList.New(self.list)
	self.ui_list:SetVirtual(true)

	self.ui_list:SetCreateItemFunc(function(obj)
		local item = require("game/activity/activity_item_new_template").New(self)
		item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        return item
	end)

	self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
    	self:OnClickItem(item)
    end)

    self.ui_list:SetItemNum(act_num)

    self._layout_objs["tip"]:SetVisible(act_num<=0)
    self._layout_objs["n2"]:SetTouchDisabled(false)
    self._layout_objs["arrow_img"]:SetTouchDisabled(false)
    self._layout_objs["arrow_img"]:AddClickCallBack(function()
    	self._layout_objs["n25"]:SetVisible(false)
    end)
end

function ActivityWaitTemplate:CloseViewCallBack()

	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.ui_award_list then
		self.ui_award_list:DeleteMe()
		self.ui_award_list = nil
	end
end

function ActivityWaitTemplate:CloseViewCallBack()

end

function ActivityWaitTemplate:GetListData()
	return self.act_list
end

function ActivityWaitTemplate:GetDailyIndexListData()
	return self.act_daily_index_list
end

function ActivityWaitTemplate:GetDailyTaskListData()
	return self.cfg_daily_task_list
end

function ActivityWaitTemplate:GetType()
	return 4
end

function ActivityWaitTemplate:OnClickItem(item)

	self.ui_list:Foreach(function(item)
		item:SetSelect(false)
	end)
	item:SetSelect(true)

	local daily_cfg = item:GetDailyCfg()
	local act_cfg = item:GetActCfg()

	self:SetActivityDesc(daily_cfg, act_cfg)
	self._layout_objs["n25"]:SetVisible(true)
end

function ActivityWaitTemplate:SetActivityDesc(daily_cfg, act_cfg)

	local act_hall_cfg = act_cfg

	self._layout_objs["activity_img"]:SetSprite("ui_activity", act_hall_cfg.icon)

	self._layout_objs["n4"]:SetText(act_hall_cfg.name)

	self._layout_objs["n9"]:SetText(act_hall_cfg.limit_lv)

	if act_hall_cfg.group_type == 1 then
		self._layout_objs["n12"]:SetText(config.words[4031])
	else
		self._layout_objs["n12"]:SetText(config.words[4032])
	end

	if daily_cfg then
		self._layout_objs["n15"]:SetText(string.format(config.words[4033], daily_cfg.start_time[1], daily_cfg.start_time[2], daily_cfg.end_time[1], daily_cfg.end_time[2]))
	else
		self._layout_objs["n15"]:SetText(config.words[4034])
	end

	self._layout_objs["n18"]:SetText(act_hall_cfg.desc)

	local drop_id = act_hall_cfg.award
	local award_items = config.drop[drop_id].client_goods_list
	if self.ui_award_list then
		self.ui_award_list:DeleteMe()
		self.ui_award_list = nil
	end
	self.ui_award_list = game.UIList.New(self._layout_objs["n21"])
	self.ui_award_list:SetVirtual(true)
	self.ui_award_list:SetCreateItemFunc(function(obj)
		local item = require("game/bag/item/goods_item").New()
		item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        item:SetShowTipsEnable(true)
        return item
	end)

	self.ui_award_list:SetRefreshItemFunc(function(item, idx)

		local item_info = award_items[idx]
		item:SetItemInfo({ id = item_info[1], num = item_info[2]})
	end)
	self.ui_award_list:SetItemNum(#award_items)
end

return ActivityWaitTemplate