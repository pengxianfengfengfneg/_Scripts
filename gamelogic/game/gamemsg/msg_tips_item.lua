local MsgTipsItem = Class(game.UITemplate)

function MsgTipsItem:_init()
    self._package_name = "ui_game_msg"
    self._com_name = "msg_tips_item"
end

function MsgTipsItem:OpenViewCallBack()
	self.root = self:GetRoot()
	self.txt_desc = self._layout_objs["txt_desc"]

	self:SetVisible(false)

	self.play_callback = function()
		self:SetVisible(false)
	end
end

function MsgTipsItem:CloseViewCallBack()
    
end

function MsgTipsItem:UpdateData(data)
	self.txt_desc:SetText(data)
	self:PlayTransition()
end

function MsgTipsItem:PlayTransition()
	self:SetVisible(true)
	self.root:PlayTransition("t0", self.play_callback)
end

function MsgTipsItem:Stop()
	self:SetVisible(false)
end

function MsgTipsItem:SetVisible(val)
	if self.is_visible == val then
		return
	end

	self.is_visible = val
	self.root:SetVisible(val)
end

return MsgTipsItem
