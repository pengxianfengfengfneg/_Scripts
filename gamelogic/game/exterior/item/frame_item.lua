local FrameItem = Class(game.UITemplate)

function FrameItem:OpenViewCallBack()
    self:Init()
end

function FrameItem:Init()
	self.ctrl = game.RoleCtrl.instance

	self.head_icon = self:GetIconTemplate("head_icon")

	self.txt_name = self._layout_objs["txt_name"]
	self.txt_expire = self._layout_objs["txt_expire"]
	self.img_ycd = self._layout_objs["img_ycd"]

	self.icon_id = game.Scene.instance:GetMainRoleIcon()

	self.icon_data = {
		icon = self.icon_id,
		frame = 0,
		lock = false,	
	}
end

function FrameItem:UpdateData(data)
	self.item_data = data

	self.txt_name:SetText(data.name)

	local frame_info = self.ctrl:GetFrameInfo(data.id)
	self.icon_data.frame = data.id
	self.icon_data.lock = (frame_info==nil)

	self.head_icon:UpdateData(self.icon_data)

	local str_time = config.words[5522]
	if frame_info then
		if frame_info.expire_time > 0 then
			local left_time = (frame_info.expire_time - global.Time:GetServerTime())
			if left_time > 24*60*60 then
				str_time = game.Utils.SecToTimeCn(left_time, game.TimeFormatCn.DayHour)
			else
				str_time = game.Utils.SecToTime(left_time, game.TimeFormatEn.HourMinSec)
			end
		else
			str_time = config.words[5521]
		end
	end
	self.txt_expire:SetText(str_time)

	self:UpdateState()
end

function FrameItem:UpdateState()
	local id = self:GetId()

	local cur_frame_id = self.ctrl:GetCurFrame()
	self.is_on_use = (cur_frame_id==id)
	self.img_ycd:SetVisible(self.is_on_use)

	local frame_info = self.ctrl:GetFrameInfo(id)
	self.is_actived = (frame_info~=nil)
end

function FrameItem:GetData()
	return self.item_data
end

function FrameItem:GetId()
	return self.item_data.id
end

function FrameItem:IsOnUse()
	return self.is_on_use
end

function FrameItem:IsActived()
	return self.is_actived
end

function FrameItem:GetIconData()
	return self.icon_data
end

return FrameItem
