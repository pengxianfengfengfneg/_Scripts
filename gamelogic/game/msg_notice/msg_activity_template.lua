local MsgActivityTemplate = Class(game.UITemplate)

local config_msg_notice = config.msg_notice
local config_activity_hall = config.activity_hall
local config_daily_activity_schedule = config.daily_activity_schedule

function MsgActivityTemplate:_init()
    
end

function MsgActivityTemplate:OpenViewCallBack()
	self.img_act = self._layout_objs["img_act"]
	self.txt_type = self._layout_objs["txt_type"]
	self.txt_lv = self._layout_objs["txt_lv"]
	self.txt_time = self._layout_objs["txt_time"]

	self.ui_list = self:CreateList("list_reward", "game/bag/item/goods_item")

	self.ui_list:SetRefreshItemFunc(function(item, idx)
		item:SetShowTipsEnable(true)

        local data = self:GetRewardData(idx)
        item:SetItemInfo(data)
    end)
end

function MsgActivityTemplate:CloseViewCallBack()
    
end

function MsgActivityTemplate:UpdateData(item)
	local cfg = item:GetCfg()
	local act_hall_id = cfg.act_id

	local act_hall_cfg = config_activity_hall[act_hall_id]

	self.txt_lv:SetText(string.format(config.words[6356], act_hall_cfg.limit_lv))

	local word_id = (act_hall_cfg.group_type==1 and 4031 or 4032)
	self.txt_type:SetText(config.words[word_id])

	self.img_act:SetSprite("ui_activity", act_hall_cfg.icon)

	local act_id = act_hall_cfg.act_id
	if act_id > 0 then

		local msg_params = item:GetMsgParams()
		local start_time = tonumber(msg_params[1])
		local end_time = tonumber(msg_params[2])

		local str_time = self:GetStrTime(start_time, end_time)
		self.txt_time:SetText(str_time)
	else
		self.txt_time:SetText(config.words[4034])
	end

	self:UpdateReward(act_hall_cfg.award)
end

function MsgActivityTemplate:GetStrTime(start_time, end_time)
	local start_date = os.date("*t", start_time)
	local end_date = os.date("*t", end_time)

	return string.format("%02d:%02d-%02d:%02d", start_date.hour, start_date.min, end_date.hour, end_date.min)
end

function MsgActivityTemplate:UpdateReward(reward_id)
	local drop_cfg = config.drop[reward_id]
	self.reward_data = {}

	for _,v in ipairs(drop_cfg.client_goods_list) do
		table.insert(self.reward_data, {
				id = v[1],
				num = v[2],
			})
	end

	self.ui_list:SetItemNum(#self.reward_data)
end

function MsgActivityTemplate:GetRewardData(idx)
	return self.reward_data[idx]
end

return MsgActivityTemplate
