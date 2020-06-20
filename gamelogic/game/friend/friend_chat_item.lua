local FriendChatItem = Class(game.UITemplate)

function FriendChatItem:_init(parent)
	self.parent = parent

	self.ctrl = game.FriendCtrl.instance
	self.friend_data = game.FriendCtrl.instance:GetData()
end

function FriendChatItem:OpenViewCallBack()
	self.touch_com = self._layout_objs["touch_com"]
	self.touch_com:AddClickCallBack(function()
		self:OnClick()
	end)

	self.set_btn = self._layout_objs["set_btn"]
	self.set_btn:AddClickCallBack(function()
		if self.is_group then
			local data = {
				group = self.group_info	
			}
			self:FireEvent(game.FriendEvent.ShowGroupDetail, true, data)
		else
			local block_idx = self.friend_data:GetBlockIdByRoleId(self.role_info.unit.id) or 5
			local data = {
				role_id = self.role_info.unit.id,
				type_index = block_idx,
				oper_type = (block_idx<5 and 0 or 1),
			}
			if self.role_info.unit.stat == 0 then
				data.role_info = self.role_info
			end
			self:FireEvent(game.FriendEvent.ShowFriendDetail, true, data)
		end
	end)

	if self._layout_objs["head_icon"] then
		self.head_icon = self:GetIconTemplate("head_icon")
	end

	self.img_career = self._layout_objs["career_img"]

	self.txt_name = self._layout_objs["role_name"]
	self.txt_chat = self._layout_objs["txt1"]
	self.txt_relation = self._layout_objs["txt2"]

	self.txt_lv = self._layout_objs["n3"]

	self.group_msg = self._layout_objs["n9"]
	self.txt_message_num = self._layout_objs["message_num"]
	
	self.txt_group_name = self._layout_objs["group_name"]
	self.txt_group_type = self._layout_objs["group_type"]
	self.img_my_create = self._layout_objs["my_create_img"]
end

function FriendChatItem:UpdateData(data)
	self.item_data = data

	self.is_group = false
	if data.channel == game.ChatChannel.Private then
		self:UpdatePrivateData(data)
	else
		self.is_group = true
		self:UpdateGroupData(data)
	end
end

function FriendChatItem:UpdatePrivateData(data)
	local is_self = data.is_self

    local role_id = data.target_id
    if not is_self then
    	role_id = data.sender.id
    end

    if role_id ~= self.parent:GetOpenTargetId() then
	    local chat_data = game.ChatCtrl.instance:GetChatPrivateData(role_id)
	    local min_id = math.min(data.target_id, data.sender.id)
	    local max_id = math.max(data.target_id, data.sender.id)
	    local key = string.format("%s_%s_time", min_id, max_id)
	    local last_time = global.ChatRecord:GetInt(key, 0)

	    local new_chat_num = 0
	    for _,v in ipairs(chat_data) do
	    	if v.time > last_time then
	    		new_chat_num = new_chat_num + 1
	    	end
	    end
	    self.group_msg:SetVisible(new_chat_num>0)
	    self.txt_message_num:SetText(new_chat_num)
	end

    local role_info = self.friend_data:GetRoleInfoById(role_id)
	if not role_info then
		local unit_info = {stat = 0}
		local target = is_self and data.receiver or data.sender
		for k, v in pairs(target) do
			unit_info[k] = v
		end
		role_info = {unit = unit_info}
    end
	
	self.role_info = role_info

	local name = role_info.unit.name
	local lv = role_info.unit.level
	local career = role_info.unit.career
	local icon = role_info.unit.icon
	local frame = role_info.unit.frame
	local stat = role_info.unit.stat

	local res = game.CareerRes[career]
	local relation_name = game.FriendRelationName[stat]

	local content = string.gsub(data.content, "width=0 height=0", function()
            return "width=34 height=34"
        end)

	self.txt_name:SetText(name)
	self.txt_lv:SetText(lv)
	self.img_career:SetSprite("ui_main", res)
	self.txt_chat:SetText(content)
	self.txt_relation:SetText(relation_name)

	if self.head_icon then
		self.head_icon:UpdateData(role_info.unit)
	end
end

function FriendChatItem:UpdateGroupData(data)
	local group_info = self.friend_data:GetGroupData(data.target)
	if not group_info then
		return
	end

	self.group_info = group_info

	local group_id = group_info.id
	if group_id ~= self.parent:GetOpenGroupId() then
	    local chat_data = game.ChatCtrl.instance:GetChatGroupData(group_id)
	    local key = string.format("%s_time", group_id)
	    local last_time = global.ChatRecord:GetInt(key, 0)

	    local new_chat_num = 0
	    for _,v in ipairs(chat_data) do
	    	if v.time > last_time then
	    		new_chat_num = new_chat_num + 1
	    	end
	    end
	    self.group_msg:SetVisible(new_chat_num>0)
	    self.txt_message_num:SetText(new_chat_num)
	end

	local content = string.gsub(data.content, "width=0 height=0", function()
            return "width=34 height=34"
        end)

	local online_num = 0
	for _,v in ipairs(group_info.mem_list) do
		local info = self.friend_data:GetRoleInfoById(v.roleId)
		if info and info.unit.offline <= 0 then
			online_num = online_num + 1
		end
	end
	local group_name = string.format("%s(%s/%s)", group_info.name, online_num, #group_info.mem_list)
	self.txt_group_name:SetText(group_name)
	self.txt_group_type:SetText(content)
end

function FriendChatItem:OnClick()
	if self.group_msg then
		self.group_msg:SetVisible(false)
	end

	if self.img_apply_rp then
		self.img_apply_rp:SetVisible(false)
	end

	if self.is_group then
		local group_info = self.friend_data:GetGroupData(self.item_data.target)
	    local chat_info = {
	        channel = game.ChatChannel.Group,
	        group_info = group_info,
	    }

	    game.ChatCtrl.instance:OpenFriendChatView(chat_info)
	    return
	end

    local role_info = self.role_info
    local server_num = game.Scene.instance:GetServerNum()

    local chat_info = {
        id = role_info.unit.id,
        name = role_info.unit.name,
        career = role_info.unit.career,
        gender = role_info.unit.gender,
        channel = game.ChatChannel.Private,
        lv = role_info.unit.level,
        svr_num = server_num,
        stat = role_info.unit.stat,           --两人关系 参考 game.FriendRelationName
        offline = role_info.unit.offline,     --0表示在线
        vip = role_info.unit.vip,   
    }

    game.ChatCtrl.instance:OpenFriendChatView(chat_info)
end

function FriendChatItem:GetTargetId()
	local is_self = self.item_data.is_self
	local target_id = self.item_data.target_id
	if not is_self then
		target_id = self.item_data.sender.id
	end
	return target_id
end

function FriendChatItem:GetGroupId()
	return self.item_data.target
end

return FriendChatItem