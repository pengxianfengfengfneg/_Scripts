local ActivityDailyTemplate = Class(game.UITemplate)

function ActivityDailyTemplate:_init()
	self.ctrl = game.ActivityMgrCtrl.instance
end

function ActivityDailyTemplate:OpenViewCallBack()
	local act_list = self.ctrl:GetDailyActList()

	local act_num = #act_list
	self.act_list = act_list

	self.list = self._layout_objs["n0"]
	self.ui_list = game.UIList.New(self.list)
	self.ui_list:SetVirtual(true)
	self.list:SetScrollEnable(true)

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

function ActivityDailyTemplate:CloseViewCallBack()

	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end

	if self.ui_award_list then
		self.ui_award_list:DeleteMe()
		self.ui_award_list = nil
	end
end

function ActivityDailyTemplate:GetListData()
	return self.act_list
end

function ActivityDailyTemplate:GetType()
	return 1
end

function ActivityDailyTemplate:OnClickItem(item)

	self.ui_list:Foreach(function(item)
		item:SetSelect(false)
	end)
	item:SetSelect(true)

	local act_cfg = item:GetActCfg()
	self:SetActivityDesc(act_cfg)
	self._layout_objs["n25"]:SetVisible(true)
end

function ActivityDailyTemplate:SetActivityDesc(act_hall_cfg)

	self._layout_objs["activity_img"]:SetSprite("ui_activity", act_hall_cfg.icon)

	self._layout_objs["n4"]:SetText(act_hall_cfg.name)

	self._layout_objs["n9"]:SetText(act_hall_cfg.limit_lv)

	if act_hall_cfg.group_type == 1 then
		self._layout_objs["n12"]:SetText(config.words[4031])
	else
		self._layout_objs["n12"]:SetText(config.words[4032])
	end

	self._layout_objs["n15"]:SetText(config.words[4034])

	self._layout_objs["n18"]:SetText(act_hall_cfg.desc)

	local drop_id = act_hall_cfg.award
	local award_items = config.drop[drop_id].client_goods_list
	if self.ui_award_list then
		self.ui_award_list:DeleteMe()
		self.ui_award_list = nil
	end
	if not self.ui_award_list then

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
	end

	self.ui_award_list:SetItemNum(#award_items)
end

function ActivityDailyTemplate:SetGuideOper(id, guide_id)

	local total_num = #self.act_list
	local per_page_num = 8
	local item_pos
	local target_index

	for k, v in pairs(self.act_list) do
		if v.id == id then
			target_index = k
			break
		end
	end

	self.ui_list:ScrollToView(target_index-1, nil, true)

	local index = self.ui_list._list_obj:ItemIndexToChildIndex(target_index)

-- print("-------------SetGuideOper-----------",game.ScreenHeight, target_index, index)
	if index == 0 then
		index = 1
	end
	local off_height = (index*129 + 147)

	--目标项不能移动到第一个时，位置有偏差
	if (total_num - target_index  + 1) < 8 then
		off_height = off_height - 20
	end
		
	item_pos = {617, off_height}

	local guide_view = game.GuideCtrl.instance:GetGuideView()
	if guide_view and guide_view:IsOpen() then
		guide_view:SetDynamicPos(item_pos[1], item_pos[2])
		self.list:SetScrollEnable(false)
	end
end

return ActivityDailyTemplate