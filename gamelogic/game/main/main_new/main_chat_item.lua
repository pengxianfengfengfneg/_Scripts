local MainChatItem = Class(game.UITemplate)

local string_format = string.format
local string_gsub = string.gsub
local tonumber = tonumber

function MainChatItem:_init()
    
end

function MainChatItem:OpenViewCallBack()
	self:Init()
	
end

function MainChatItem:CloseViewCallBack()
    
end

function MainChatItem:Init()
	self.is_visible = false

	self.title = self._layout_objs["title"]	
	self.title:SetupEmoji("ui_emoji", 24, 24)

	self.img_channel = self._layout_objs["img_channel"]	
	self.txt_channel = self._layout_objs["txt_channel"]	

	self:GetRoot():AddClickCallBack(function()
		if not self.is_click_link then
			game.ChatCtrl.instance:OpenView()
		end
		self.is_click_link = false
	end)

	self.title:AddClickLinkCallBack(function(data, obj)
		self:OnClickLink(data, obj)
	end)
end

function MainChatItem:UpdateData(data)
	self.chat_data = data
	self:SetVisible(data~=nil)
	
	if not self.chat_data then
		return
	end

	local channel_name = game.ChatChannelWord[data.channel] or ""
    local name_color = game.ChatGenderColor[data.sender.gender] or game.ColorString.Green
    local str_name = (data.sender.name~="" and (data.sender.name .. "：") or "")
    local str_content = ""

    self.img_channel:SetSprite("ui_main", game.ChatChannelImg[data.channel] or "")
    self.txt_channel:SetText(channel_name)

    if data.is_rumor then
        str_content = string_format("<font color='#%s'>%s</font>%s", name_color, str_name, data.content or "" )
    else
    	local voice = ""
    	if data.voice_time and data.voice_time > 0 then
	    	voice = "<img asset=\'ui_common:chat_flag_0\'/>"
	    end
        str_content = string_format("%s<font color='#%s'>%s</font>%s%s", str_content, name_color, str_name, voice, data.content or "" )

        str_content = string_gsub(str_content, "3171f5", "5298e3")

        str_content = string_gsub(str_content, "width=0 height=0", function()
            return "width=28 height=28"
        end)
    end

    self.title:SetText(str_content)
end

function MainChatItem:SetVisible(val)
	if self.is_visible == val then
		return
	end
	self.is_visible = val
	self:GetRoot():SetVisible(val)
end

function MainChatItem:OnClickLink(data, obj)	
	self.is_click_link = true

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


return MainChatItem
