local FirstEnterTips = Class(game.BaseView)

function FirstEnterTips:_init(ctrl)
	self._package_name = "ui_guide"
    self._com_name = "ui_first_enter_tips"
    self._view_level = game.UIViewLevel.Fouth
    self._ui_order = game.UIZOrder.UIZOrder_Top

    self.ctrl = ctrl
end

function FirstEnterTips:OpenViewCallBack(guide_step_info)

	self._layout_objs["n5"]:AddClickCallBack(function()
		self:Close()
    end)

    self:AddModel()

    self:GetRoot():PlayTransition("t0")
end

function FirstEnterTips:CloseViewCallBack()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function FirstEnterTips:AddModel()

	self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs["model"], game.BodyType.Monster)
    self.model:SetRotation(0, 140, 0)
    self.model:SetPosition(0, -1.2, 3)
    self.model:SetModel(game.ModelType.Body, 2001)
    self.model:PlayAnim(game.ObjAnimName.Idle)
    self._layout_objs["model"]:SetVisible(true)
end

return FirstEnterTips