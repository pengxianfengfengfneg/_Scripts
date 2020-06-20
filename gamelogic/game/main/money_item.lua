local MoneyItem = Class(game.UITemplate)

local string_format = string.format
local config_effect = config.effect

function MoneyItem:_init(info, num_cfg, money_type)
    self.money_info = info
    self.num_cfg = num_cfg
    self.money_type = money_type
end

function MoneyItem:OpenViewCallBack()
	self:Init()
	
end

function MoneyItem:CloseViewCallBack()
    self:HideTips()
end

function MoneyItem:Init()
	self:GetRoot():SetIcon("ui_common", self.money_info.icon, true)

	self.btn_add = self._layout_objs["btn_add"]	
	self.btn_add:AddClickCallBack(function()
		if self.money_info.click_func then
			self.money_info.click_func(self)
		end
	end)

	self.txt_title = self._layout_objs["title"]	
	self.txt_title:SetFontSize(self.num_cfg.font_size)

	self.btn_add:SetVisible(self.money_info.is_add)

	local is_touch_left = (self.money_info.click_left~=nil)
	self.touch_com = self._layout_objs["touch_com"]	
	self.touch_com:SetVisible(is_touch_left)

	self.touch_com:AddClickCallBack(function()
		if self.money_info.click_left then
			self.money_info.click_left(self)
		end
	end)

	self.group_tips = self._layout_objs["group_tips"]	
	self.group_tips:SetVisible(false)

	self.txt_tips = self._layout_objs["txt_tips"]	
end

function MoneyItem:ShowTips(str_txt)
	if self.is_show_tips then
		return 
	end

	self.is_show_tips = true

	local interval = 3
	self.txt_tips:SetText(str_txt or "")
	self.group_tips:SetVisible(true)

	self:ClearTimer()
	self.timer_id = global.TimerMgr:CreateTimer(interval,function()
		self:HideTips()
		return true
	end)
end

function MoneyItem:HideTips()
	self.is_show_tips = false
	self.group_tips:SetVisible(false)
	
	self:ClearTimer()
end

function MoneyItem:ClearTimer()
	if self.timer_id then
		global.TimerMgr:DelTimer(self.timer_id)
		self.timer_id = nil
	end
end

function MoneyItem:GetMoneyType()
	return self.money_type
end

function MoneyItem:SetMoney(money_num)
	local money_num = self:FormatNum(money_num)
	self:GetRoot():SetText(money_num)
end

function MoneyItem:FormatNum(num)
	if num < 100000 then
		return num
	end

	return string_format(config.words[126], num*0.0001)
end

return MoneyItem
