
local MsgWaitingView = Class(game.BaseView)

function MsgWaitingView:_init()
	self._package_name = "ui_game_msg"
    self._com_name = "waiting_view"
	self._ui_order = game.UIZOrder.UIZOrder_Top
	self._cache_time = 300

	self._mask_type = game.UIMaskType.None
	self._view_level = game.UIViewLevel.Standalone

	self._layer_name = game.LayerName.UIDefault
end

function MsgWaitingView:_delete()
	
end

function MsgWaitingView:OpenViewCallBack(count_down)
	self:GetRoot():PlayTransition("t0")

	if count_down then
		self.tween = DOTween.Sequence()
		self.tween:AppendInterval(count_down)
		self.tween:AppendCallback(function()
			self.tween = nil
			self:Close()
		end)
	end
end

function MsgWaitingView:CloseViewCallBack()
	if self.tween then
		self.tween:Kill(false)
		self.tween = nil
	end
end

return MsgWaitingView