local ActivityDailyItem = Class(game.UITemplate)

function ActivityDailyItem:_init()
	
end

function ActivityDailyItem:OpenViewCallBack()
	self.list_reward = self._layout_objs["list"]

	self.txt_name = self._layout_objs["n3"]

	self._layout_objs["n4"]:AddClickCallBack(function()
		self:OnClickJoin()
    end)
end

function ActivityDailyItem:CloseViewCallBack()
	self:ClearReward()
end

function ActivityDailyItem:UpdateData(data)
	self.daily_data = data

	self:UpdateReward()
end

function ActivityDailyItem:UpdateReward()
	--奖励物品
	local award = self.daily_data.award
	local award_items = config.drop[award].client_goods_list
	
	local item_num = #award_items
	self.list_reward:SetItemNum(item_num)

	self:ClearReward()
	local item_class = require("game/bag/item/goods_item")
	for i=1,item_num do
		local obj = self.list_reward:GetChildAt(i-1)
		local item = item_class.New()
		item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()        
        item:SetShowTipsEnable(true)

        local item_info = award_items[i]
		item:SetItemInfo({ id = item_info[1], num = item_info[2]})

        table.insert(self.reward_list_tb, item)
	end
end

function ActivityDailyItem:ClearReward()
	for _,v in ipairs(self.reward_list_tb or game.EmptyTable) do
		v:DeleteMe()
	end
	self.reward_list_tb = {}
end

function ActivityDailyItem:OnClickJoin()
	local dun_id = self.daily_data.dun_id
	local dun_cfg = config.dungeon[dun_id]
	local dun_npc = dun_cfg.npc
	if dun_npc > 0 then
		game.ActivityMgrCtrl.instance:CloseActivityHallView()
		game.MainUICtrl.instance:SwitchToFighting()

		local mainr_role = game.Scene.instance:GetMainRole()
		mainr_role:GetOperateMgr():DoGoToNpc(dun_npc, function()
			game.TaskCtrl.instance:OpenNpcDialogView(dun_npc)
		end)
	end
end

return ActivityDailyItem