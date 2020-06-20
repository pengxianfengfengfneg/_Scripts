local RoundTemplate = Class(game.UITemplate)

function RoundTemplate:_init()

end

function RoundTemplate:OpenViewCallBack()
	self.img_list = {}
	self.cur_list_idx = 0
	self.cur_icon_idx = -1
	self.rotation = 0

	for i=0,11 do
		self.img_list[i] = require("game/login/img_item").New() 
		self.img_list[i]:SetVirtual(self._layout_objs["n" .. (i+1)])
		self.img_list[i]:Open()
	end

	self.controller = self:GetRoot():AddControllerCallback("c1", function(idx)
		local icon_idx = self.img_list[idx]:GetID()
		self:SetRotation(idx * 30)
		self:ResetList(idx, icon_idx)

		if self.callback then
			self.callback(icon_idx + 1)
		end
    end)

    self._layout_root:SetTouchEnable(true)
	self._layout_root:SetTouchBeginCallBack(function(x, y)
		self.touch_pos_x = x
		self.touch_moving = false
	end)
	self._layout_root:SetTouchMoveCallBack(function(x, y)
		if not self.touch_moving and math.abs(self.touch_pos_x - x) > 5 then
			self.touch_moving = true
		end
		if self.touch_moving then
			self:SetRotation(self.rotation + (self.touch_pos_x - x) * 0.3)
			self.touch_pos_x = x
		end
	end)
	self._layout_root:SetTouchEndCallBack(function(x, y)
		if self.touch_moving then
			self:SetRotation(self.rotation + (self.touch_pos_x - x) * 0.3, true)
			self:SetRotation(self.cur_list_idx * 30)
		end
	end)
end

function RoundTemplate:CloseViewCallBack()
	for i,v in pairs(self.img_list) do
		v:DeleteMe()
	end
	self.img_list = nil
end

function RoundTemplate:SetCallBack(callback)
	self.callback = callback
end

function RoundTemplate:SetSelect(icon_idx)
	local list_idx = 0
	self:ResetList(list_idx, icon_idx - 1)
	self:SetRotation(list_idx * 30)
	self.controller:SetSelectedIndexEx(list_idx)
end

function RoundTemplate:SetData(icon_type, icon_list)
	self.icon_type = icon_type
	self.icon_list = icon_list
end

function RoundTemplate:SetRotation(val, auto_sel)
	if self.rot_lock then
		return
	end

	val = math.floor(val)
	self.rotation = val

	local angle = val % 360
	if angle < 0 then
		angle = angle + 360
	end
	self._layout_root:SetRotation(-angle)

	for i,v in pairs(self.img_list) do
		v:SetRotation(angle)
	end

	if auto_sel then
		local list_rotation = self.cur_list_idx * 30
		local num = math.abs(val - list_rotation) // 15
		if num > 0 then
			num = (num - 1) // 2 + 1
			if val < list_rotation then
				num = -num
			end

			local list_idx = self.cur_list_idx + num
			if list_idx < 0 then
				list_idx = list_idx + 12
			end
			list_idx = list_idx % 12

			self.rot_lock = true
			self.controller:SetSelectedIndexEx(list_idx)
			self.rot_lock = false
		end
	end

end

function RoundTemplate:ResetList(list_idx, icon_idx)
	self.cur_list_idx = list_idx
	self.cur_icon_idx = icon_idx

	local tmp_list_idx, tmp_icon_idx
	for i=-5,6 do
		tmp_list_idx = list_idx + i
		if tmp_list_idx < 0 then
			tmp_list_idx = tmp_list_idx + 12
		end
		tmp_list_idx = tmp_list_idx % 12

		tmp_icon_idx = icon_idx + i
		if tmp_icon_idx < 0 then
			tmp_icon_idx = tmp_icon_idx + #self.icon_list
		end
		tmp_icon_idx = tmp_icon_idx % #self.icon_list

		if self.icon_type == 1 then
			self.img_list[tmp_list_idx]:Refresh(tmp_icon_idx, "ui_login", self.icon_list[tmp_icon_idx + 1].icon)
		else
			self.img_list[tmp_list_idx]:Refresh(tmp_icon_idx, "ui_headicon", self.icon_list[tmp_icon_idx + 1].icon)
		end
		self.img_list[tmp_list_idx]:SetIconType(self.icon_type)
	end
end

return RoundTemplate
