local HistoryMessageTemplate = Class(game.UITemplate)

function HistoryMessageTemplate:_init()

end

function HistoryMessageTemplate:_delete()
	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
end

function HistoryMessageTemplate:OpenViewCallBack()
    self.ctrl = game.FriendCtrl.instance

	self._layout_objs["add_friend_btn"]:AddClickCallBack(function()
		game.FriendCtrl.instance:OpenFriendSearchView()
    end)

    self._layout_objs["set_btn"]:AddClickCallBack(function()
		game.FriendCtrl.instance:OpenFriendSettingView()
    end)

    self:InitList()

    self:RegisterAllEvents()
end

function HistoryMessageTemplate:RegisterAllEvents()
    local events = {
        {game.ChatEvent.UpdateNewChat, handler(self, self.OnUpdateNewChat)},
        {game.FriendEvent.OpenFriendChat, handler(self, self.OnOpenFriendChat)},
        {game.FriendEvent.CloseFriendChat, handler(self, self.OnCloseFriendChat)},
        {game.FriendEvent.RemoveGroup, handler(self, self.OnRemoveGroup)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function HistoryMessageTemplate:InitList()
	self.list_item = self._layout_objs["list"]

	self.ui_list = game.UIList.New(self.list_item)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local chat_item = require("game/friend/friend_chat_item").New(self)
        chat_item:SetVirtual(obj)
        chat_item:Open()

        return chat_item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetData(idx)
        item:UpdateData(data)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        local data = self:GetData(idx)
        if data.channel == game.ChatChannel.Group then
            return "ui_friend:group_info_template"
        else
            return "ui_friend:friend_info_template"
        end
    end)

    self:UpdateData()
end

function HistoryMessageTemplate:OnUpdateNewChat(data)
	if data.channel==game.ChatChannel.Private or data.channel==game.ChatChannel.Group then
		self:UpdateData()
	end
end

function HistoryMessageTemplate:UpdateData()
	local role_id = game.Scene.instance:GetMainRoleID()

    local pri_chat_data = game.ChatCtrl.instance:GetChatData(game.ChatChannel.Private)

    local tmp_data = {}
    for _,v in ipairs(pri_chat_data) do
    	local sender_id = v.sender.id
    	local target_id = v.target_id

    	if sender_id == role_id then
    		tmp_data[target_id] = v
	    end

	    if target_id == role_id then
	    	tmp_data[sender_id] = v
	    end
    end

    local group_chat_data = game.ChatCtrl.instance:GetChatData(game.ChatChannel.Group)
    for _,v in ipairs(group_chat_data) do
    	local target_id = v.target or 0
        local group_info = self.ctrl:GetData():GetGroupData(target_id)
        if group_info then
    		tmp_data[target_id] = v
        end
    end

    self.sort_data = {}
    for k,v in pairs(tmp_data) do
    	table.insert(self.sort_data, v)
    end

    table.sort(self.sort_data, function(v1,v2)
    	return v1.time>v2.time
	end)

	local item_num = #self.sort_data
	self.ui_list:SetItemNum(item_num)
end

function HistoryMessageTemplate:GetData(idx)
	return self.sort_data[idx]
end

function HistoryMessageTemplate:OnOpenFriendChat(chat_info)
	self.open_group_id = nil
	self.open_target_id = nil

	local is_group_chat = (chat_info.channel==game.ChatChannel.Group)
	if is_group_chat then
        if chat_info.group_info then
    		self.open_group_id = chat_info.group_info.id
        end

		self.ui_list:Foreach(function(item)
			local group_id = item:GetGroupId()

		end)
	else
		self.open_target_id = chat_info.id
	end
end

function HistoryMessageTemplate:OnCloseFriendChat(chat_info)
	self.open_group_id = nil
	self.open_target_id = nil
end

function HistoryMessageTemplate:GetOpenGroupId()
	return self.open_group_id
end

function HistoryMessageTemplate:GetOpenTargetId()
	return self.open_target_id
end

function HistoryMessageTemplate:OnRemoveGroup(data)
    for _,v in ipairs(self.sort_data) do
        if v.target == data.id then
            self:UpdateData()
            break
        end
    end
end

return HistoryMessageTemplate