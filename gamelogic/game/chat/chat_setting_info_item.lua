
local ChatSettingInfoItem = Class(game.UITemplate)

local _voice_update_interval = 0.1
local _max_record_time = 60
local _tips_type = {recording_tips = 1, cancel_tips = 2}

function ChatSettingInfoItem:_init(chat_channel, role_id, group_id)
	self.chat_channel = chat_channel
	self.chat_role_id = role_id
	self.group_id = group_id
end

function ChatSettingInfoItem:OpenViewCallBack()
	self:Init()
end

function ChatSettingInfoItem:CloseViewCallBack()

end

function ChatSettingInfoItem:Init()
	self.head_icon = self:GetIconTemplate("head_icon")

	self.txt_lv = self._layout_objs["txt_lv"]
	self.img_career = self._layout_objs["img_career"]

	self.txt_name = self._layout_objs["txt_name"]
	self.txt_date = self._layout_objs["txt_date"]
	self.txt_time = self._layout_objs["txt_time"]
	self.txt_channel = self._layout_objs["txt_channel"]

	self.rtx_content = self._layout_objs["rtx_content"]

	self.btn_go = self._layout_objs["btn_go"]
	self.btn_go:AddClickCallBack(function()
		self:OnClickBtnGo()
	end)
end

function ChatSettingInfoItem:UpdateData(data)
	local sender = data.sender
	self.head_icon:UpdateData(sender)

	self.txt_lv:SetText(sender.level)
	self.txt_name:SetText(sender.name)

	local dt = os.date("*t", data.time)
	self.txt_date:SetText(string.format("%02d-%02d", dt.month, dt.day))
	self.txt_time:SetText(string.format("%02d:%02d", dt.hour, dt.min))

	self.txt_channel:SetText(string.format("[%s]", game.ChatChannelWord[data.channel]))

	self.rtx_content:SetText(data.content)

	self:UpdateCareer(sender.career)
end

function ChatSettingInfoItem:UpdateCareer(career)
	local res = game.CareerRes[career]
	self.img_career:SetSprite("ui_main", res)
end

function ChatSettingInfoItem:OnClickBtnGo()
	
end

return ChatSettingInfoItem
