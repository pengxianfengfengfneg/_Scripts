local QuickChatItem = Class(game.UITemplate)

function QuickChatItem:_init(data)
    self.quick_chat_data = data
    
end

function QuickChatItem:OpenViewCallBack()
	self:Init()
end

function QuickChatItem:CloseViewCallBack()
    
end

function QuickChatItem:Init()

	self:GetRoot():SetText(self.quick_chat_data.name)
end

function QuickChatItem:GetContent()
	return self.quick_chat_data.content
end

function QuickChatItem:GetId()
	return self.quick_chat_data.id
end

return QuickChatItem
