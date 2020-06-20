local ChatItem = Class(game.UITemplate)

function ChatItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function ChatItem:OpenViewCallBack()
	self:Init()
end

function ChatItem:CloseViewCallBack()
    
end

function ChatItem:Init()
	self.root = self:GetRoot()

	self.txt_content = self._layout_objs["txt_content"]	

	local boundle_name = "ui_emoji"
	self.txt_content:SetupEmoji(boundle_name)

	self.list_infos = self._layout_objs["list_infos"]
	if self.list_infos then
		self.list_infos.foldInvisibleItems = true
		self.txt_name = self.list_infos:GetChild("txt_name"):GetChild("txt_name")

		self.txt_channel = self.list_infos:GetChild("txt_channel")		
	end

	if not self.txt_channel then
		self.txt_channel = self._layout_objs["txt_channel"]
	end

	if self._layout_objs["head_icon"] then
		self.head_icon = self:GetIconTemplate("head_icon")
		self.head_icon:SetClickCallback(function()
			if not self.is_self_chat then
				local sender = self.chat_data.sender
				game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, sender.id)
			end
		end)
	end

	self.txt_content:AddClickLinkCallBack(function(data, obj)
		self:OnClickLink(data, obj)
	end)

	self.btn_chat_voice = self._layout_objs["btn_chat_voice"]

	self.img_bg = self._layout_objs["img_bg"]
	if self.img_bg then
		self.img_bg_x,self.img_bg_y = self.img_bg:GetPosition()
	end

	if self.btn_chat_voice then
		self.txt_sec = self._layout_objs["btn_chat_voice/txt_sec"]

		self.min_bg_width = 90 + 20

		self.max_txt_width = 530
	end
end

local test = {
	0,
	101,
	102,	
}
function ChatItem:UpdateData(data)
	self.chat_data = data or self.chat_data or {}

	self.chat_body_type = self.chat_data.chat_body_type or game.ChatBodyType.None

	self.txt_content:SetText(self.chat_data.content or "")

	if self.img_bg then
		local x = self.img_bg_x
		local y = self.img_bg_y + 6

		local bubble_id = data.sender.bubble
		--local bubble_id = test[math.random(1,#test)]
		local cfg = config.chat_bubble[bubble_id]
		if cfg then
			self.img_bg:SetSprite("ui_main", cfg.res, true)
			self.img_bg:SetFlipX(data.is_self)

			local factor = (data.is_self and -1 or 1)
			x = self.img_bg_x + (11 + (cfg.offset_x or 0))*factor
		end
		self.txt_content:SetPosition(x, y)
	end

	self:ParseVoice(data)

	if self.btn_chat_voice then
		local size = self.txt_content:GetSize()
		if self.chat_body_type == game.ChatBodyType.Right then
			local align_type = 2
			
			local lines = self.txt_content:GetLines()
			if lines > 1 then
				align_type = 0

				size[1] = self.max_txt_width
			end
			self.txt_content.align = align_type
		end

		local width = size[1] + 26
		width = (width>=self.min_bg_width and width or self.min_bg_width)
		local height = size[2]
		
		if self.chat_data.voice == "" then
			height = height + 14
		else
			height = height + 14 + 42

			local voice_time = (self.chat_data.voice_time * 0.001)
			self.txt_sec:SetText(string.format("%.1f", voice_time))
		end

		self.img_bg:SetSize(width, height)
	end

	local gender = data.sender.gender
	if self.txt_name then
		local color = (gender==game.Gender.Male and game.Color.Blue or game.Color.Purple)
		self.is_self_chat = data.is_self
		if data.is_self then
			color = game.Color.Green
		end
		self.txt_name:SetText(self.chat_data.sender.name or "")
		self.txt_name:SetColor(table.unpack(color))
	end

	if self.txt_channel then
		local channel_word = game.ChatChannelWord[data.channel]
		self.txt_channel:SetText(channel_word)

		self.txt_channel:SetIcon("ui_main", game.ChatChannelImg[data.channel] or "")
	end

	if self.head_icon then
		self.head_icon:UpdateData(data.sender)
	end

	
end

function ChatItem:OnClickLink(data, obj)	
	local params = string.split(data, "|")

	local func_id = params[1]
	if func_id then
		func_id = tonumber(func_id)
		local rumor_cfg = config.rumor_func[func_id]
		if rumor_cfg and rumor_cfg.click_func then
			rumor_cfg.click_func(table.unpack(params))
		end
	end
end

function ChatItem:ParseVoice(data)
	if not self.btn_chat_voice then
		return
	end

	if data.voice == "" then
		self.txt_content:SetPositionY(53)
		self.btn_chat_voice:SetVisible(false)
		return
	end
	self.txt_content:SetPositionY(93)
	self.btn_chat_voice:SetVisible(true)

	if not self.is_init_voice then
		self.is_init_voice = true

		self.mov_voice = self._layout_objs["btn_chat_voice/mov_voice"]
		self.mov_voice:AddPlayEndCallback(function()
			self.mov_voice:SetVisible(false)
		end)

		self.btn_chat_voice:AddClickCallBack(function()
			self.mov_voice:SetVisible(true)

			local voice_time = (self.chat_data.voice_time * 0.001)
			local times = math.ceil(voice_time*30/30)
			self.mov_voice:SetPlaySettings(0, -1, times, 0)

			game.VoiceMgr:PlayRecordFile(data.voice)
		end)
	end
end

return ChatItem
