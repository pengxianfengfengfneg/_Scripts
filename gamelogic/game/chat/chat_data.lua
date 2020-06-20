local ChatData = Class(game.BaseData)

local global_time = global.Time
local string_gsub = string.gsub
local string_sub = string.sub
local string_format = string.format
local string_find = string.find
local string_split = string.split
local table_remove = table.remove
local table_insert = table.insert
local table_concat = table.concat
local serialize = serialize
local unserialize = unserialize
local tonumber = tonumber
local math_min = math.min
local math_max = math.max

function ChatData:_init()
    self.chat_combine_data = {max_count=60}
    self.chat_sys_data = {max_count=30}
    self.chat_world_data = {max_count=50}
    self.chat_guild_data = {max_count=50}
    self.chat_team_data = {max_count=40}
    self.chat_make_team_data = {max_count=20}
    self.chat_horn_data = {max_count=20}
    self.chat_private_data = {max_count=100}
    self.chat_group_data = {max_count=200}
    self.chat_nearby_data = {max_count=30}

    self.chat_at_data = {}

    self.channel_to_data_tb = {
    	[game.ChatChannel.World] = {self.chat_combine_data, self.chat_world_data},
    	[game.ChatChannel.Guild] = {self.chat_combine_data, self.chat_guild_data},
    	[game.ChatChannel.Sys] = {self.chat_sys_data},
    	[game.ChatChannel.Team] = {self.chat_team_data},
    	[game.ChatChannel.TeamRecruit] = {self.chat_make_team_data},
    	[game.ChatChannel.Horn] = {self.chat_combine_data, self.chat_world_data},
    	[game.ChatChannel.Private] = {self.chat_private_data},
    	[game.ChatChannel.Group] = {self.chat_group_data},
    	[game.ChatChannel.Nearby] = {self.chat_nearby_data},
	}

	self.chat_channel_data = {
		[game.ChatChannel.World] = self.chat_world_data,
		[game.ChatChannel.Guild] = self.chat_guild_data,
		[game.ChatChannel.Sys] = self.chat_sys_data,
		[game.ChatChannel.Combine] = self.chat_combine_data,
		[game.ChatChannel.Team] = self.chat_team_data,
		[game.ChatChannel.TeamRecruit] = self.chat_make_team_data,
		[game.ChatChannel.Horn] = self.chat_horn_data,
		[game.ChatChannel.Private] = self.chat_private_data,
		[game.ChatChannel.Group] = self.chat_group_data,
		[game.ChatChannel.Nearby] = self.chat_nearby_data,
	}

	--self:DoReadPrivateChat()
end

function ChatData:_delete()

end

function ChatData:OnChatPublic(data)
	local main_role_vo = game.Scene.instance:GetMainRoleVo()
	main_role_vo.id = main_role_vo.role_id

	data.is_self = true
	data.chat_body_type = game.ChatBodyType.Right
	data.time = global_time:GetServerTime()
	data.sender = main_role_vo

	data.content = self:ParseChatContent(data)

	self:AddChatData(data)
end

function ChatData:OnChatPublicNotify(data)
	data.is_self = false
	data.chat_body_type = data.chat_body_type or game.ChatBodyType.Left

	data.content = self:ParseChatContent(data)
	
	self:AddChatData(data)
end

function ChatData:Parse(str_text)
    str_text = string_gsub(str_text, "#%d+#", function(s)
        local idx = string_gsub(s, "#", "")

        return string_format("<img asset=\'ui_emoji_chat:%s\' width=0 height=0 />", idx)
    end)

    return str_text
end

function ChatData:AddChatData(data, no_fire)
	data.content = self:Parse(data.content)

	local list_table = self.channel_to_data_tb[data.channel] or {}
	for _,v in ipairs(list_table) do
		local max_count = v.max_count or 30
		if #v >= max_count then
			table_remove(v,1)
		end
		table_insert(v, data)
	end

	if not no_fire then
		self:FireEvent(game.ChatEvent.UpdateNewChat, data)
	end
end

function ChatData:GetChatData(chat_channel, fliter_func)
	local data = self.chat_channel_data[chat_channel]
	if fliter_func then
		local fliter_data = {}
		for _,v in ipairs(data) do
			if fliter_func(v) then
				table_insert(fliter_data, v)
			end
		end
		return fliter_data
	end
	return data
end

function ChatData:OnRumorNew(data)
	local chat_data = {
		is_self = false,
		chat_body_type = game.ChatBodyType.Sys,
		time = global.Time:GetServerTime(),
		channel = data.channel,
		content = "",
		sender = {
			gender = 1,
			name = "",
		},
		is_rumor = true,
		main_panel = data.main_panel,
	}

	chat_data.content = data.content
	self:AddChatData(chat_data)
end

function ChatData:OnChatHorn(data)
	local channel = game.ChatChannel.Horn
	local chat_data = {
		is_self = true,
		chat_body_type = game.ChatBodyType.Right,
		time = global.Time:GetServerTime(),
		channel = channel,
		content = "",
		sender = data.sender,
		voice = "",
		voice_time = 0,
		extra = data.extra,
		is_horn = true,
	}

	chat_data.content = data.content	
	self:AddChatData(chat_data)
end

function ChatData:OnChatHornNotify(data)
	local channel = game.ChatChannel.Horn
	local chat_data = {
		is_self = false,
		chat_body_type = game.ChatBodyType.Left,
		time = data.time,
		channel = channel,
		content = "",
		sender = data.sender,
		voice = "",
		voice_time = 0,
		extra = data.extra,
		is_horn = true,
	}

	chat_data.content = data.content	
	self:AddChatData(chat_data)
end

function ChatData:ParseChatContent(data)
	local res,content = self:ParseChatFuncs(data)
	if res then
		return content
	end

	if not data.extra or data.extra == "" then
		return data.content
	end

	local params = string_split(data.extra, "|")

	local show_id = tonumber(params[1])
	local show_cfg = config.chat_show[show_id]

	if not show_cfg then
		error(debug.traceback())
		return data.content
	end

	return string_gsub(show_cfg.show, "%[%d+%]", function(arg)
			local func_id = tonumber(string_sub(arg, string_find(arg,"%d+")))
			params[1] = func_id

	        local func_cfg = config.rumor_func[func_id] or {}

	        local str = ""
	        if func_cfg.parse_func then
	        	str = func_cfg.parse_func(params)
	        else        	
		        local herf_params = table_concat(params,"|")
		        str = string_format("<font color='#%s'><a href='%s'>%s</a></font>", func_cfg.color, herf_params, func_cfg.click_word)
	        end

	        return str
		end)
end

function ChatData:ParseChatFuncs(data)
	if string_find(data.content, "#f#") then
		return true,self:ParseQuickChat(data)
	end

	local res = false
	if string_find(data.content, "#i#") then
		res = true
		data.content = self:ParseChatItem(data)
	end

	if string_find(data.content, "#s#") then
		res = true
		data.content = self:ParseMapPos(data)
	end

	if string_find(data.content, "#p#") then
		res = true
		data.content = self:ParseChatPet(data)
	end

	if string_find(data.content, "#@#") then
		res = true
		data.content = self:ParseChatAt(data)
	end

	return res,data.content
end

function ChatData:ParseChatItem(data)
	if not data.extra or data.extra=="" then
		return string_gsub(data.content, "#i#", "")
	end

	local parse_tb = string_split(data.extra, "$")
	local item_extra = ""
	for _,v in ipairs(parse_tb) do
		if string_find(v, "extra_item") then
			item_extra = v
			break
		end
	end

	if item_extra == "" then
		return
	end

	local rumor_func_id = 1011
	local tb = string_split(item_extra, "|")
	local item_id = tonumber(tb[2])
	local extra = string_format("%s|%s", rumor_func_id, tb[3])

	local item_cfg = config.goods[item_id]
	return string_gsub(data.content, "#i#", function(s)
		return string_format("<font color='#%s'><a href='%s'>[%s]</a></font>", game.ItemColor[item_cfg.color], extra, item_cfg.name)
	end)
end

function ChatData:ParseQuickChat(data)
	local content = string_gsub(data.content, "#f#", "")
	local tb = string_split(content, "|")
	if not tb[1] then
		return ""
	end

	local quick_chat_id = tonumber(tb[1])
	local name = tb[2]
	local gender = tonumber(tb[3])

	local gender_color = game.ChatGenderColor[gender]
    name = string_format("<font color='#%s'>%s</font>", gender_color, name)

	local quick_chat_cfg = config.quick_chat[quick_chat_id]
	return string_gsub(quick_chat_cfg.content, "#name#", name)
end

function ChatData:ParseMapPos(data)
	if not data.extra or data.extra=="" then
		return string_gsub(data.content, "#s#", "")
	end

	local parse_tb = string_split(data.extra, "$")
	local pos_extra = ""
	for _,v in ipairs(parse_tb) do
		if string_find(v, "extra_pos") then
			pos_extra = v
			break
		end
	end

	if pos_extra == "" then
		return
	end

	local tb = string_split(pos_extra, "|")

	local pos_info = unserialize(tb[2])

	local str_pos = string_format(config.words[1326], pos_info.name, pos_info.line, pos_info.lx, pos_info.ly)

	local rumor_func_id = 1012
	local extra = string_format("%s|%s", rumor_func_id, tb[2])

	return string_gsub(data.content, "#s#", function(s)
		return string_format("<font color='#%s'><a href='%s'>%s</a></font>", game.ColorString.Green, extra, str_pos)
	end)
end

local PetStarColor = {
    [0] = game.ColorString.Green,
    [1] = game.ColorString.NavyBlue,
    [2] = game.ColorString.NavyBlue,
    [3] = game.ColorString.NavyBlue,
    [4] = game.ColorString.Purple,
    [5] = game.ColorString.Purple,
    [6] = game.ColorString.Purple,
    [7] = game.ColorString.Orange,
    [8] = game.ColorString.Orange,
    [9] = game.ColorString.Orange,
}

function ChatData:ParseChatPet(data)
	if not data.extra or data.extra=="" then
		return string_gsub(data.content, "#p#", "")
	end

	local parse_tb = string_split(data.extra, "$")
	local pet_extra = ""
	for _,v in ipairs(parse_tb) do
		if string_find(v, "extra_pet") then
			pet_extra = v
			break
		end
	end

	if pet_extra == "" then
		return
	end

	local rumor_func_id = 1007
	local tb = string_split(pet_extra, "|")
	local pet_name = tb[2]
	local pet_star = tonumber(tb[3])
	local extra = string_format("%s|%s", rumor_func_id, tb[4])
	local color = PetStarColor[pet_star] or PetStarColor[0]

	local item_cfg = config.goods[item_id]
	return string_gsub(data.content, "#p#", function(s)
		return string_format("<font color='#%s'><a href='%s'>[%s]</a></font>", color, extra, pet_name)
	end)
end

function ChatData:ParseChatAt(data)
	if not data.extra or data.extra=="" then
		return string_gsub(data.content, "#@#", "")
	end

	local parse_tb = string_split(data.extra, "$")
	local extra = ""
	for _,v in ipairs(parse_tb) do
		if string_find(v, "extra_@") then
			extra = v
			break
		end
	end

	if extra == "" then
		return
	end

	local tb = string_split(extra, "|")
	local str_name = tb[2]
	local str_id = tb[3]
	local color = game.ColorString.NavyBlue

	local id_list = {}
	local id_tb = string_split(str_id, "&")
	for _,v in ipairs(id_tb) do
		id_list[tonumber(v)] = 1
	end

	local main_role_id = game.Scene.instance:GetMainRoleID()
	if id_list[main_role_id] then
		table.insert(self.chat_at_data, data)

		self:FireEvent(game.ChatEvent.RevcieveChatAt, id_list, data)
	end

	return string_gsub(data.content, "#@#", function(s)
		return string_format("<font color='#%s'>@%s</font>", color, str_name)
	end)
end


-- 私聊
function ChatData:OnChatPrivate(data)
	--[[
        "target__U|CltChatRole|",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
    ]]
    --[[
		"channel__C",
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
    ]]

    local main_role_vo = game.Scene.instance:GetMainRoleVo()
    data.channel = game.ChatChannel.Private
    data.time = global.Time:GetServerTime()
    data.target_id = data.target.id
    data.sender = {
    	id = main_role_vo.role_id,
    	name = main_role_vo.name,
    	gender = main_role_vo.gender,
    	level = main_role_vo.level,
    	career = main_role_vo.career,
    	platform = "",
    	svr_num = main_role_vo.server_num,
    	icon = main_role_vo.icon,
    	frame = main_role_vo.frame,
    	bubble = main_role_vo.bubble,
	}
	data.receiver = data.target

	data.is_self = true
	data.chat_body_type = game.ChatBodyType.Right

	data.content = self:ParseChatContent(data)
	
	self:AddChatData(data)
end

function ChatData:OnChatPrivateNotify(data)
	--[[
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
	]]
    data.channel = game.ChatChannel.Private
    data.target_id = game.Scene.instance:GetMainRoleID()

    data.is_self = false
	data.chat_body_type = game.ChatBodyType.Left

	data.content = self:ParseChatContent(data)
	
	self:AddChatData(data)
end

function ChatData:OnChatCache(data)
	 --[[
        "offline_time__I",
        "pub__T__cache@U|CltChatPublicCache|",
        "pri__T__cache@U|CltChatPrivateCache|",
    ]]

    local pub_cache = data.pub
    local pri_cache = data.pri
    local group_cache = data.group

    --[[
        "sender__U|CltChatRole|",
        "time__I",
        "content__s",
        "voice__s",
        "voice_time__H",
        "extra__s",
    ]]

    local his_chat_data = {}
    local main_role_vo = game.Scene.instance:GetMainRoleVo()
    local main_role_id = main_role_vo.role_id
    for _,v in ipairs(pub_cache) do
    	local channel = v.cache.channel
    	local target = v.cache.target
    	local history = v.cache.history

    	for _,cv in ipairs(history) do
    		local sender = cv.item.sender
    		local chat_data = cv.item.item

    		chat_data.channel = channel
    		chat_data.target = target
    		chat_data.sender = sender

    		chat_data.is_self = (sender.id==main_role_id)
			chat_data.chat_body_type = (chat_data.is_self and game.ChatBodyType.Right or game.ChatBodyType.Left)

			chat_data.content = self:ParseChatContent(chat_data)

    		table.insert(his_chat_data, chat_data)
    	end
    end

    for _,v in ipairs(pri_cache) do
    	local sender = v.cache.sender
    	local history = v.cache.history

    	for _,cv in ipairs(history) do
    		local chat_data = cv.item

    		chat_data.channel = game.ChatChannel.Private

    		local is_self = (chat_data.role == 1)
    		if is_self then
    			chat_data.target_id = sender.id

    			chat_data.sender = {
	    			platform = "",
	    			level = main_role_vo.level,
	    			gender = main_role_vo.gender,
	    			career = main_role_vo.career,
	    			name = main_role_vo.name,
	    			svr_num = main_role_vo.server_num,
	    			id = main_role_vo.role_id,
	    			icon = main_role_vo.icon,
	    			frame = main_role_vo.frame,
	    			bubble = main_role_vo.bubble,
				}
				chat_data.receiver = sender
	    	else
	    		chat_data.sender = sender
	    		chat_data.target_id = main_role_vo.role_id
    		end

    		chat_data.is_self = is_self
			chat_data.chat_body_type = (is_self and game.ChatBodyType.Right or game.ChatBodyType.Left)

			chat_data.content = self:ParseChatContent(chat_data)

			table.insert(his_chat_data, chat_data)
    	end
    end

    for _,v in ipairs(group_cache or game.EmptyTable) do

    end

    local function sort_func(v1,v2)
    	return v1.time<v2.time
    end
    table.sort(his_chat_data, sort_func)

    local target_num = (#his_chat_data - 2)
    for k,v in ipairs(his_chat_data) do
    	v.is_cache = true
    	self:AddChatData(v, true)
	end
	
	self:FireEvent(game.ChatEvent.AddHisChatData, his_chat_data)
end

function ChatData:OnChatClearCache(data)
	
end

function ChatData:GetChatPrivateData(role_id)
	local main_role_id = game.Scene.instance:GetMainRoleID()
	return self:GetChatData(game.ChatChannel.Private, function(data)
		local res = (data.target_id==role_id and data.sender.id==main_role_id)
        if not res then
            res = (data.target_id==main_role_id and data.sender.id==role_id)
        end
        return res
	end)
end

function ChatData:GetChatGroupData(group_id)
	return self:GetChatData(game.ChatChannel.Group, function(data)
        return data.target==group_id
	end)
end

function ChatData:GetChatCacheData()
	local cache_data = {}
	for k,v in pairs(self.chat_channel_data or {}) do
		for ck,cv in ipairs(v) do
			if cv.is_cache and (not cache_data[cv]) then
				cache_data[cv] = 1
				table_insert(cache_data, cv)
			end
		end
	end
	return cache_data
end

function ChatData:GetChatAtData()
	return self.chat_at_data
end

return ChatData
