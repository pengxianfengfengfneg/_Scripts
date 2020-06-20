local ChatSettingEmoji = Class(game.UITemplate)

function ChatSettingEmoji:_init()
	
end

function ChatSettingEmoji:OpenViewCallBack()
	self:Init()

end

function ChatSettingEmoji:CloseViewCallBack()
	

end

function ChatSettingEmoji:Init()
	self:GetRoot():SetVisible(true)

	self.img_mic = self._layout_objs["img_mic"]
	self.img_cancel = self._layout_objs["img_cancel"]

end

return ChatSettingEmoji
