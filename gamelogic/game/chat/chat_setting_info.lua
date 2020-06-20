local ChatSettingInfo = Class(game.UITemplate)

function ChatSettingInfo:_init()
	
end

function ChatSettingInfo:OpenViewCallBack()
	self:Init()

	self:RegisterAllEvents()
end

function ChatSettingInfo:CloseViewCallBack()
	

end

function ChatSettingInfo:RegisterAllEvents()
	local events = {
		{game.ChatEvent.RevcieveChatAt, handler(self,self.OnRevcieveChatAt)}
	}
	for _,v in ipairs(events) do
		self:BindEvent(v[1],v[2])
	end
end

function ChatSettingInfo:Init()
	self.btn_checkbox = self._layout_objs["btn_checkbox"]
    self.btn_checkbox:AddClickCallBack(function()

    end)

	self.ui_list = self:CreateList("list_item", "game/chat/chat_setting_info_item", true)

	self.ui_list:SetRefreshItemFunc(function(item, idx)
        local data = self:GetData(idx)
        item:UpdateData(data)
    end)

	self.main_role_id = game.Scene.instance:GetMainRoleID()

	self.ctrl = game.ChatCtrl.instance

	self:UpdateList()
end

function ChatSettingInfo:GetData(idx)
	return self.item_data[idx]
end

function ChatSettingInfo:OnRevcieveChatAt(id_list, data)
	if not id_list[self.main_role_id] then
		return
	end

	self:UpdateList()
end

function ChatSettingInfo:UpdateList()
	self.item_data = self.ctrl:GetChatAtData()
	
	self.ui_list:SetItemNum(#self.item_data)
end

return ChatSettingInfo
