local ActivityHallView = Class(game.BaseView)

function ActivityHallView:_init(ctrl)
	self._package_name = "ui_activity"
    self._com_name = "activity_hall_view"
    self.guide_index = 1
    self._show_money = true

	self.ctrl = ctrl
end

function ActivityHallView:OpenViewCallBack(open_index)
	

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[4022])

	self._layout_objs["list"]:SetHorizontalBarTop(true)

	self.daily_template = self:GetTemplateByObj("game/activity/activity_daily_template", self._layout_objs["list"]:GetChildAt(0))
	self:GetTemplateByObj("game/activity/activity_limit_template", self._layout_objs["list"]:GetChildAt(1))
	self:GetTemplateByObj("game/activity/activity_special_template", self._layout_objs["list"]:GetChildAt(2))
	self:GetTemplateByObj("game/activity/activity_wait_template", self._layout_objs["list"]:GetChildAt(3))

	self:SetActExp()

	for i = 1, 5 do

		self._layout_objs["award_img"..i]:SetTouchDisabled(false)
		self._layout_objs["award_img"..i]:AddClickCallBack(function()
			if self._layout_objs["hd_img"..i]:IsVisible() then
	    		self.ctrl:CsDailyLivelyGet(i)
	    	else
	    		local drop_id = config.daily_lively_reward[1].reward[i][3]
				local item_id = config.drop[drop_id].client_goods_list[1][1]
				local item_num = config.drop[drop_id].client_goods_list[1][2]
	    		game.BagCtrl.instance:OpenTipsView({id = item_id, num = item_num}, nil, false)
	    	end
	    end)
	end

	self:BindEvent(game.ActivityEvent.ChangeActiveExp, function(data)
		self:SetActExp()
    end)

    self.tab_controller = self:GetRoot():AddControllerCallback("tab_ctrl", function(idx)
    	game.GuideCtrl.instance:CheckTabHideGuide(idx+1)
	end)
	self.tab_controller:SetSelectedIndexEx(open_index and (open_index - 1) or 0)

	if self.guide_callback then
		self.guide_callback()
		self.guide_callback = nil
	end
end

function ActivityHallView:CloseViewCallBack()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.ui_daily_list then
		self.ui_daily_list:DeleteMe()
		self.ui_daily_list = nil
	end

	self.guide_callback = nil
end

function ActivityHallView:InitList()

	self.list = self._layout_objs["list"]
	self.ui_list = game.UIList.New(self.list)
	self.ui_list:SetVirtual(true)

	self.ui_list:SetCreateItemFunc(function(obj)
		local item = require("game/activity/activity_item_template").New(self)
		item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        return item
	end)

	self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)
    self.ui_list:SetItemNum(0)


    self.daily_list_data = self.ctrl:GetDailyActList()

    self.list_daily = self._layout_objs["list_daily"]
	self.ui_daily_list = game.UIList.New(self.list_daily)
	self.ui_daily_list:SetVirtual(true)

	self.ui_daily_list:SetCreateItemFunc(function(obj)
		local item = require("game/activity/activity_daily_item").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
	end)

	self.ui_daily_list:SetRefreshItemFunc(function (item, idx)
		local data = self.daily_list_data[idx]
        item:UpdateData(data)
    end)

    self.ui_daily_list:SetItemNum(#self.daily_list_data)
end

function ActivityHallView:UpdateList()
	if self.tab_index == 0 then
		return
	end

	local act_list
	if self.tab_index == 1 then
		act_list = self.ctrl:GetTodayActivitys()
	else
		act_list = self.ctrl:GetTomorrowActivitys()
	end

	local act_num = #act_list
	self.ui_list:SetItemNum(act_num)
end

function ActivityHallView:GetTabIndex()
	return self.tab_index
end

local step_to_progress = {
	[0] = 0,
	[1] = 6,
	[2] = 36,
	[3] = 66,
	[4] = 93,
	[5] = 100,
}

function ActivityHallView:SetActExp()

	local active_info = self.ctrl:GetData():GetActiveInfo()

	self._layout_objs["active_value"]:SetText(active_info.lively_exp)

	local cur_exp = active_info.lively_exp
	local max_exp = config.daily_lively_reward[1].max_exp
	local reward = config.daily_lively_reward[1].reward
	local cur_step = 0
	local got_list = active_info.got_list

	for k, v in ipairs(reward) do

		local exp = v[2]
		local drop_id = v[3]
		local item_id = config.drop[drop_id].client_goods_list[1][1]
		local item_num = config.drop[drop_id].client_goods_list[1][2]

		self._layout_objs["award_value"..k]:SetText(exp)
		self._layout_objs["award_img"..k]:SetSprite("ui_item", tostring(config.goods[item_id].icon))

		local bg_img = "ndk_0"..tostring(config.goods[item_id].color)
		self._layout_objs["award_bg"..k]:SetSprite("ui_common",bg_img)
		local got = false
		for x, y in pairs(got_list) do

			if y.id == k then
				got = true
				break
			end
		end

		local can_get = false
		if cur_exp >= exp then
			cur_step = k

			if not got then
				can_get = true
				
			end
		end

		if can_get then
			self._layout_objs["hd_img"..k]:SetVisible(true)
			self:SetEffect(k, true)
		else
			self._layout_objs["hd_img"..k]:SetVisible(false)
			self:SetEffect(k, false)
		end

		self._layout_objs["get_img"..k]:SetVisible(got)
	end

	self._layout_objs["n17"]:SetProgressValue(step_to_progress[cur_step])
end

function ActivityHallView:SetEffect(index, show)

	if show then
		self._layout_objs["effect"..index]:SetVisible(true)
	    local effect = self:CreateUIEffect(self._layout_objs["effect"..index], "effect/ui/ui_huoyue.ab")
	    effect:SetLoop(true)
	else
		self._layout_objs["effect"..index]:SetVisible(false)
	end
end

function ActivityHallView:SetGuideOper(tab_index, id, guide_id)
	self.guide_callback = function()
		self.daily_template:SetGuideOper(id, guide_id)
	end
end

return ActivityHallView