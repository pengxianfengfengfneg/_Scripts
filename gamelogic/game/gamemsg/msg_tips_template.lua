local MsgTipsTemplate = Class(game.UITemplate)

local _max_tween_num = 6
local _msg_pos_y = 950
local _msg_delta_y = -50

function MsgTipsTemplate:_init()
	self._package_name = "ui_game_msg"
    self._com_name = "tips_item"
	self.add_to_view_mgr = false
end

function MsgTipsTemplate:_delete()
	
end

function MsgTipsTemplate:OpenViewCallBack()
	local node = self._layout_root

	if not self.show_tween then
		local sequence = DOTween.Sequence()
	    sequence:AppendInterval(1)
	    sequence:Append(node:TweenFade(0, 0.5))
	    sequence:SetAutoKill(false)
	    sequence:SetLoops(1)
	    sequence:OnComplete(function()
	    	if self.anim_finish_callback then
	    		self.anim_finish_callback(self.index)
	    	end
	    end)
	    sequence:Pause()
	    self.show_tween = sequence
	end

	self.move_tween_list = {}
	for i=0,_max_tween_num do
		local sequence = DOTween.Sequence()
	    sequence:Append(node:TweenMoveY(_msg_pos_y + _msg_delta_y * i, 0.3))
	    sequence:SetAutoKill(false)
	    sequence:SetLoops(1)
	    sequence:Pause()
	    self.move_tween_list[i] = sequence
	end
end

function MsgTipsTemplate:CloseViewCallBack()
	if self.show_tween then
		self.show_tween:Kill(false)
		self.show_tween = nil
	end

	for i,v in pairs(self.move_tween_list) do
		v:Kill(false)
	end
	self.move_tween_list = nil
end

function MsgTipsTemplate:Reset()
	if self.show_tween then
		self.show_tween:Pause()
	end
	
	for i,v in pairs(self.move_tween_list) do
		v:Pause()
	end
	
	self._layout_root:SetAlpha(0)
end

function MsgTipsTemplate:SetAnimFinishCallBack(callback)
	self.anim_finish_callback = callback
end

function MsgTipsTemplate:SetText(str)
	self._layout_objs["n1"]:SetText(str)
end

function MsgTipsTemplate:SetColor(clr)
	self._layout_objs["n1"]:SetColor(clr.x, clr.y, clr.z, 255.0)
end

function MsgTipsTemplate:SetAlpha(val)
	self._layout_objs["n1"]:SetAlpha(val)
end

function MsgTipsTemplate:SetIndex(idx, need_anim)
	self.index = idx

	if need_anim then
		self._layout_root:SetPositionY(_msg_pos_y + _msg_delta_y * (idx - 1))
		for i,v in pairs(self.move_tween_list) do
			if i == idx then
				v:Restart(true, -1)
			else
				v:Pause()
			end
		end
	else
		self._layout_root:SetPositionY(_msg_pos_y + _msg_delta_y * idx)
	end
end

function MsgTipsTemplate:PlayShowAnim()
	self.show_tween:Restart(true, -1)
end

return MsgTipsTemplate
