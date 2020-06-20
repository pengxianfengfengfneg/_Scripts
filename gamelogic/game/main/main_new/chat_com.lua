local ChatCom = Class(game.UITemplate)

function ChatCom:_init()
    
end

function ChatCom:OpenViewCallBack()
	self:Init()
	
end

function ChatCom:CloseViewCallBack()
    self:CloseChatVoice()
end

function ChatCom:Init()
	local touch_com = self._layout_objs["touch_com"]
    touch_com:AddClickCallBack(function()
        game.ChatCtrl.instance:OpenView()
    end)

    self.chat_data = {}
    self.chat_item_list = {
	    self:GetTemplate("game/main/main_new/main_chat_item", "chat_item_1"),
	    self:GetTemplate("game/main/main_new/main_chat_item", "chat_item_2"),
	}

	self.chat_voice_com = self._layout_objs["chat_voice_com"]

    self.btn_friend = self._layout_objs["btn_friend"]
    self.btn_friend:AddClickCallBack(function()
        game.FriendCtrl.instance:OpenFriendView()
    end)

	-- 语音
	self.channel_idx = 1
	self.channel_tb = {
		{game.ChatChannel.World, "p_03 (2)"},
		{game.ChatChannel.Guild, "p_04"},
		{game.ChatChannel.Team,"p_01 (2)"},
	}
	self.chat_channel = game.ChatChannel.World

	local btn_press_voice = self._layout_objs["btn_voice"]
	btn_press_voice:AddClickCallBack(function()
		if self.is_speaking then
			self.is_speaking = false
			return
		end

		self.channel_idx = math.max((self.channel_idx+1)%4, 1)
		local cfg = self.channel_tb[self.channel_idx] or self.channel_tb[1]
		self.chat_channel = cfg[1]

		btn_press_voice:SetIcon("ui_main", cfg[2])
	end)

    btn_press_voice:SetTouchEndCallBack(function(x, y)
        self:CloseChatVoice()
    end)

    btn_press_voice:SetTouchRollOutCallBack(function(x, y)
    	self.is_speaking = false
        self:CancelChatVoice()
    end)

    btn_press_voice:SetLongClickLinkCallBack(function(x, y)
        if game.VoiceMgr:InitEngine() then
        	self.is_speaking = true
            self:OpenChatVoice()
        end
    end, 0.3)

    local cache_data = game.ChatCtrl.instance:GetChatCacheData()
    table.sort(cache_data,function(v1,v2)
        return v1.time<v2.time
    end)

    for _,v in ipairs(cache_data) do
        self:OnUpdateNewChat(v)
    end
end

local NotShowChannel = {
    [game.ChatChannel.Sys] = 1,
    [game.ChatChannel.Private] = 1,
    [game.ChatChannel.Group] = 1,
}
function ChatCom:OnUpdateNewChat(data)
    if NotShowChannel[data.channel] then
        return
    end

    if data.main_panel and data.main_panel~=1 then
        return
    end

    local data_num = #self.chat_data
    if data_num >= 2 then
        self.chat_data[1] = self.chat_data[2]
        self.chat_data[2] = data
    else
        table.insert(self.chat_data, data)
    end

    self.is_update_chat = true
end

function ChatCom:Update(now_time, elapse_time)
    if self.is_update_chat then
        self.is_update_chat = false

        self.chat_item_list[1]:UpdateData(self.chat_data[2])
        self.chat_item_list[2]:UpdateData(self.chat_data[1])
    end
end

function ChatCom:OpenChatVoice()
    if not self.chat_voice_template then
        self.chat_voice_template = require("game/chat/chat_voice_template").New(self.chat_channel)
        self.chat_voice_template:SetVirtual(self.chat_voice_com)
        self.chat_voice_template:Open()
    end
end

function ChatCom:CloseChatVoice()
    if self.chat_voice_template then
        self.chat_voice_template:DeleteMe()
        self.chat_voice_template = nil
    end
end

function ChatCom:CancelChatVoice()
    if self.chat_voice_template then
        self.chat_voice_template:CancelChatVoice()
    end
end

return ChatCom
