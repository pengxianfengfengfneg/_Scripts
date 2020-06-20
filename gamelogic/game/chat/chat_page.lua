local ChatPage = Class(game.UITemplate)

local et = {}

local ChatBodyPackage = {
    [game.ChatBodyType.Left] = "ui_chat:chat_item_left",
    [game.ChatBodyType.Right] = "ui_chat:chat_item_right",
    [game.ChatBodyType.Sys] = "ui_chat:chat_item_sys",
}

local ChatRecord = global.ChatRecord

function ChatPage:_init(ctrl, chat_channel, is_chat, target_role_id, target_group_id)
    self.ctrl = ctrl
    
    self.chat_channel = chat_channel
    self.is_chat = is_chat

    self.target_role_id = target_role_id
    self.target_group_id = target_group_id

    self.main_role_id = game.Scene.instance:GetMainRoleID()
end

function ChatPage:OpenViewCallBack()
	self:Init()
end

function ChatPage:CloseViewCallBack()
    if self.ui_list then
    	self.ui_list:DeleteMe()
    	self.ui_list = nil
    end
end

function ChatPage:Init()
	self.new_chat_num = 0
	self.cur_chat_item_num = 0

    self.is_show_func = false

	self.chat_data = {}

	self.list_chat = self._layout_objs["list_chat"]	
    self.list_chat:AddClickCallBack(function()
        if self.parent_view then
            self.parent_view:HideFuns()
        end
    end)

	self.ui_list = game.UIList.New(self.list_chat)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local chat_item = require("game/chat/chat_item").New(self.ctrl)
        chat_item:SetVirtual(obj)
        chat_item:Open()

        return chat_item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetChatData(idx)
        item:UpdateData(data)
    end)

    
    self.ui_list:AddItemProviderCallback(function(idx)
        local data = self:GetChatData(idx) or et

        local package = ChatBodyPackage[data.chat_body_type] or ChatBodyPackage[game.ChatBodyType.Sys]

        return package
    end)

    self.scroll_perc_y = 1
    self.ui_list:AddScrollEndCallback(function(perc_x, perc_y)
        self.scroll_perc_y = perc_y

        if self.scroll_perc_y>=(1-0.05) then
            self:ScrollToBottom()
        end
    end)
end

function ChatPage:GetChatData(idx)
    return self.chat_data[idx]
end

function ChatPage:ScrollToBottom()
    self.new_chat_num = 0
    self.list_chat:ScrollToView(self.cur_chat_item_num - 1)

    self:ClearNewChatTips()
end

function ChatPage:OnUpdateNewChat()
	if not self:IsActive() then
		return
	end

    local fliter_func = nil
    if self.target_role_id then
        fliter_func = function(data)
            local res = (data.target_id==self.target_role_id and data.sender.id==self.main_role_id)
            if not res then
                res = (data.target_id==self.main_role_id and data.sender.id==self.target_role_id)
            end
            return res
        end
    end

    if self.target_group_id then
        fliter_func = function(data)
            return (data.target==self.target_group_id)
        end
    end

    self.chat_data = self.ctrl:GetChatData(self.chat_channel, fliter_func) or et

    -- 标记已读
    if fliter_func then
        local last_data = self.chat_data[#self.chat_data]
        if last_data then
            if self.target_group_id then
                local key = string.format("%s_time", self.target_group_id)
                ChatRecord:SetInt(key, last_data.time)
            else
                local min_id = math.min(self.target_role_id, self.main_role_id)
                local max_id = math.max(self.target_role_id, self.main_role_id)
                local key = string.format("%s_%s_time", min_id, max_id)
                ChatRecord:SetInt(key, last_data.time)
            end
        end
    end

    local item_num = #self.chat_data
    self.cur_chat_item_num = item_num
    local last_data = self.chat_data[item_num]
    self.ui_list:SetItemNum(item_num)

    if (last_data and last_data.is_self) then
        self:ScrollToBottom()
    else
        if self.scroll_perc_y>=(1-0.05) then
            self:ScrollToBottom()
        else
            self.new_chat_num = self.new_chat_num + 1
            self:ShowNewChatTips(self.new_chat_num)
        end
    end
end

function ChatPage:ShowNewChatTips(num)
	-- 新消息未读
    -- self.group_new_chat:SetVisible(true)

    -- self.rtx_messege:SetText(string.format(config.words[1320], num))
end

function ChatPage:ClearNewChatTips()
    --self.group_new_chat:SetVisible(false)
end

function ChatPage:GetChatChannel()
    return self.chat_channel
end

function ChatPage:IsChat()
	return self.is_chat
end

function ChatPage:OnActived(val)
	if val then
		self:OnUpdateNewChat()

        local is_show_func = self.parent_view:IsShowFunc()
        self:OnShowFunc(is_show_func)
	end
end

function ChatPage:SetParentView(parent_view)
    self.parent_view = parent_view
end

local OrignSize = {680,864}
function ChatPage:OnShowFunc(val)
    if not self.is_chat then
        return
    end

    if not self.parent_view or self.is_show_func == val then
        return
    end

    self.is_show_func = val

    local width = OrignSize[1]
    local height = (val and 530 or OrignSize[2])
    self.list_chat:SetSize(width, height)

    self:ScrollToBottom()
end

function ChatPage:ScrollToData(data)
    local idx = nil
    for k,v in ipairs(self.chat_data) do
        if v == data then
            idx = k - 1
            break
        end
    end

    if idx then
        self.list_chat:ScrollToView(idx)
    end
end

return ChatPage
