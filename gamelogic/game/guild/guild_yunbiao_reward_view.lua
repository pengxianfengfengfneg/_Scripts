local GuildYunbiaoRewardView = Class(require("game/task/npc_dialog_view"))

local carry_npc_id = config.carry_common.carry_npc

function GuildYunbiaoRewardView:_init(ctrl)
  
    self.ctrl = ctrl
end

function GuildYunbiaoRewardView:OpenViewCallBack()
	GuildYunbiaoRewardView.super.OpenViewCallBack(self, carry_npc_id)
	
	self:InitRewards()
end

function GuildYunbiaoRewardView:CloseViewCallBack()
	GuildYunbiaoRewardView.super.CloseViewCallBack(self)

	self:ClearRewards()
end

function GuildYunbiaoRewardView:InitInfos()
	GuildYunbiaoRewardView.super.InitInfos(self)

	self.txt_name = self._layout_objs["txt_name"]
	self.txt_name:SetText(config.words[2184])

	local task_cfg = nil
	for k,v in pairs(game.DailyTaskConfig) do
		if v.type == game.TaskType.YunbiaoTask then
			task_cfg = v
			break
		end
	end

	if task_cfg then
		local desc = task_cfg.desc_func()
		self.txt_content = self._layout_objs["txt_content"]
		self.txt_content:SetText(string.format(config.words[2190],desc))
	end
end

function GuildYunbiaoRewardView:InitRewards()
	self.reward_item_list = {}
	self.list_reward = self._layout_objs["list_reward"]
	self.list_reward:RemoveChildrenToPool()

	self.group_reward:SetVisible(true)
	self.list_reward:SetVisible(true)

	local x,y = self.group_reward:GetPosition()
	self.group_reward:SetPositionY(y+25)

	local reward_list = {}
	local yunbiao_data = self.ctrl:GetYunbiaoData()
	if yunbiao_data then
		local quality = yunbiao_data.quality
		local reward_cfg = config.carry_reward[quality]
		if reward_cfg then
			local drop_cfg = config.drop[reward_cfg.show_drop] or {}
			for _,v in ipairs(drop_cfg.client_goods_list or {}) do
				table.insert(reward_list, {
						v[1],
						0
					})
			end
		end
	end

	local package_name = "ui_task"
	local res_name = ""
	for _,v in ipairs(reward_list) do
		local item_id = v[1]
		local item_num = v[2]

		local currency_cfg = self:GetCurrencyCfg(item_id)

		res_name = "task_reward_item"
		if currency_cfg then
			res_name = "task_money"
		end

		local obj = self.list_reward:AddItemFromPool(package_name, res_name)
		--local obj = _ui_mgr:CreateObject(package_name, res_name)
		if currency_cfg then
			obj:SetText(item_num)
			obj:SetIcon("ui_common", currency_cfg.icon)
		else
			local item = game_help.GetGoodsItem(obj:GetChild("item"), true)
			item:SetItemInfo({id=item_id,num=item_num})

			table.insert(self.reward_item_list, item)
		end

		self.list_reward:AddChild(obj)
	end
end

function GuildYunbiaoRewardView:ClearRewards()
	for _,v in ipairs(self.reward_item_list or {}) do
		v:DeleteMe()
	end
	self.reward_item_list = nil
end

function GuildYunbiaoRewardView:GetCurrencyCfg(item_id)
	return game.MoneyItemMap[item_id]
end

return GuildYunbiaoRewardView
