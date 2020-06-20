local BuffItem = Class(game.UITemplate)

local string_format = string.format
local config_effect_desc = config.effect_desc

function BuffItem:_init(ctrl, buff_info_list)
    self.ctrl = ctrl
    self.buff_info_list = buff_info_list
    self.buff_list = buff_info_list.buff_list
end

function BuffItem:OpenViewCallBack()
	self:GetRoot():AddClickCallBack(function()
		self.ctrl:OpenBuffView(self.buff_info_list)
	end)
	self.img_buff = self._layout_objs["img_buff"]
	self:SetVisible(false)
end

function BuffItem:CloseViewCallBack()
end

function BuffItem:UpdateData(data)
	if not data then
		if not self.buff_data then
			return
		else
			self.buff_data = nil
			self:SetVisible(false)
		end
	else
		if self.buff_data == data and data.end_time == self.end_time then
			return
		else
			if not self.buff_data then
				self:SetVisible(true)
			end
			self.buff_data = data
			self.end_time = data.end_time

			local cfg = config_effect_desc[data.id]
			if cfg then
				self.img_buff:SetSprite("ui_main", cfg.icon)
			end
		end
	end
end

return BuffItem
