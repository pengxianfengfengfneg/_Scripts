local ChatSettingBase = Class(game.UITemplate)

function ChatSettingBase:_init()
	
end

function ChatSettingBase:OpenViewCallBack()
	self:Init()

end

function ChatSettingBase:CloseViewCallBack()
	

end

function ChatSettingBase:Init()
	self:GetRoot():SetVisible(true)

	self.img_mic = self._layout_objs["img_mic"]
	self.img_cancel = self._layout_objs["img_cancel"]

end

return ChatSettingBase
