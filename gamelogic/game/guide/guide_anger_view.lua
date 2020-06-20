local GuideAngerView = Class(game.BaseView)

local handler = handler

function GuideAngerView:_init(ctrl)
	self._package_name = "ui_guide"
    self._com_name = "ui_guide_anger_view"

    self._layer_name = game.LayerName.UIDefault
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.First

    self._ui_order = game.UIZOrder.UIZOrder_Common_Below

    self.ctrl = ctrl
end

function GuideAngerView:OpenViewCallBack()
	self.node_effect = self._layout_objs["effect"]
	self.node_effect:SetVisible(true)

	self.ui_effect = nil

	self.action_callback = function()
		self:ShowGuangbaoEffect(true)
	end

	self.play_action = self:GetRoot():GetTransition("t0")
	self.play_action:SetHook("last", self.action_callback)
	self.play_action:Play(10000, 0, nil)

	self:ShowGuangbaoEffect(true)

	self:RegisterAllEvents()
end

function GuideAngerView:CloseViewCallBack()
	self.play_action:Stop()
end

function GuideAngerView:RegisterAllEvents()
	local events = {
		{game.SceneEvent.OnPlayBigSkill, handler(self,self.OnPlayBigSkill)},
		{game.ViewEvent.ShowSkillCom, handler(self,self.OnShowSkillCom)}
	}
	for _,v in ipairs(events) do
		self:BindEvent(v[1], v[2])
	end
end

function GuideAngerView:ShowGuangbaoEffect(is_play)
	if not self.ui_effect then
		self.ui_effect = self:CreateUIEffect(self.node_effect, "effect/ui/shiyongyindao.ab")
		self.ui_effect:SetLoop(true)
	end

	if is_play then
		self.ui_effect:Replay()
	end
end

function GuideAngerView:OnPlayBigSkill(skill_id)
	self:Close()
end

function GuideAngerView:OnShowSkillCom(val)
	self:GetRoot():SetVisible(val)
end

return GuideAngerView