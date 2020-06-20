local ChatSettingBarrage = Class(game.UITemplate)

function ChatSettingBarrage:_init()
	
end

function ChatSettingBarrage:OpenViewCallBack()
	self:Init()

end

function ChatSettingBarrage:CloseViewCallBack()
	

end

function ChatSettingBarrage:Init()
	self:GetRoot():SetVisible(true)

	self.img_mic = self._layout_objs["img_mic"]
	self.img_cancel = self._layout_objs["img_cancel"]

end

return ChatSettingBarrage
