
local ChatVoiceTemplate = Class(game.UITemplate)

local _voice_update_interval = 0.1
local _max_record_time = 60
local _tips_type = {recording_tips = 1, cancel_tips = 2}

function ChatVoiceTemplate:_init(chat_channel, role_id, group_id)
	self.chat_channel = chat_channel
	self.chat_role_id = role_id
	self.group_id = group_id
end

function ChatVoiceTemplate:OpenViewCallBack()
	self:Init()
	self:_AddUpdateObj()
	self:StartRecord()

end

function ChatVoiceTemplate:CloseViewCallBack()
	self:_RemoveUpdateObj()
	self:StopRecord()

	self:Reset()

end

function ChatVoiceTemplate:Init()
	self:GetRoot():SetVisible(true)

	self.img_mic = self._layout_objs["img_mic"]
	self.img_cancel = self._layout_objs["img_cancel"]

	self.vol_img_list = {}
	for i=1,5 do
		local img_volume = self._layout_objs["img_volume_" .. i]
		table.insert(self.vol_img_list, img_volume)
	end	

	self.next_update_voice_time = 0

	self.volume_factor = 0xff00 / 10
	if game.PlatformCtrl.instance:IsAndroidPlatform() or game.PlatformCtrl.instance:IsIosPlatform() then
		self.volume_factor = 200 / 10
	end

	self.chat_channel = self.chat_channel or game.ChatChannel.World
end

function ChatVoiceTemplate:Reset()
	self:GetRoot():SetVisible(false)

	self.img_mic:SetVisible(true)
	self.img_cancel:SetVisible(false)
	for _,v in ipairs(self.vol_img_list or {}) do
		v:SetVisible(false)
	end
end

function ChatVoiceTemplate:Update(now_time)
	if now_time > self.next_update_voice_time then
		self.next_update_voice_time = now_time + _voice_update_interval
		self:RefreshVoiceState()
	end
end

function ChatVoiceTemplate:SetTimeoutCallBack(callback)
	self.timeout_callback = callback
end

function ChatVoiceTemplate:RefreshVoiceState()
	local mic_level = game.VoiceMgr:GetMicLevel(true)
	local level = mic_level / self.volume_factor

	for k,v in ipairs(self.vol_img_list or game.EmptyTable) do
		v:SetVisible(level>=(k-1))
	end
end

function ChatVoiceTemplate:StartRecord()
	if not self.is_recording then
		self.is_recording = true
		self.record_time = 0
		self.record_file_id = game.VoiceMgr:StartRecord()
	end
end

function ChatVoiceTemplate:StopRecord(send_func)
	if self.is_cancel_voice then
		return
	end

	if self.is_recording then
		self.is_recording = false

		if not self.record_file_id then
			return
		end
		self.record_file_id = nil

		game.VoiceMgr:StopAndUploadRecord(nil, function(is_success, record_id, share_id, result)
			if is_success then
				local time = game.VoiceMgr:GetLocalRecordTime(record_id)
				
				self:FireEvent(game.VoiceEvent.OnSpeechText, share_id, time, result, self.chat_channel, self.chat_role_id, self.group_id)

				if self.voice_callback then
					self.voice_callback()
				end
			end
		end)
	end
end

function ChatVoiceTemplate:_AddUpdateObj()
	if not self.updating then
		global.Runner:AddUpdateObj(self, 2)
		self.updating = true
	end
end

function ChatVoiceTemplate:_RemoveUpdateObj()
	if self.updating then
		global.Runner:RemoveUpdateObj(self)
		self.updating = false
	end
end

function ChatVoiceTemplate:CancelChatVoice()
	if self.is_cancel_voice then return end

	self.is_cancel_voice = true

	self.img_mic:SetVisible(false)
	self.img_cancel:SetVisible(true)

	game.VoiceMgr:StopRecord()
end

function ChatVoiceTemplate:SetChatChannel(channel)
	self.chat_channel = channel
end

function ChatVoiceTemplate:SetVoiceCallback(callback)
	self.voice_callback = callback
end

return ChatVoiceTemplate
