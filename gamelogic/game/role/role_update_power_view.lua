local RoleUpdatePowerView = Class(game.BaseView)

local handler = handler

function RoleUpdatePowerView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_update_power_view"

    self._ui_order = game.UIZOrder.UIZOrder_Top
    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Keep

    self.ctrl = ctrl
end

function RoleUpdatePowerView:OpenViewCallBack(from_power, to_power)
    self.from_power = from_power
    self.to_power = to_power
    if to_power > from_power then
        global.AudioMgr:PlaySound("qt008")
    end

    self:Init()
    self:DoAction()
end

function RoleUpdatePowerView:CloseViewCallBack()
    self:ClearAction()
    self:ClearCloseSeq()
end

function RoleUpdatePowerView:Init()
    self.txt_fight = self._layout_objs["txt_fight"]
    self.txt_fight_add = self._layout_objs["txt_fight_add"]

    self.delta_power = math.max(self.to_power - self.from_power, 0)

    self.txt_fight:SetText(self.from_power or "")
    self.txt_fight_add:SetText("+" .. self.delta_power or "")

    self:GetRoot():PlayTransition("t0")
end

function RoleUpdatePowerView:DoAction()
    local from_power = self.from_power
    local to_power = self.to_power

    local delta_time = 0.02

    local seq = DOTween.Sequence()
    seq:AppendInterval(delta_time)
    seq:AppendCallback(function()
        from_power = math.ceil(from_power + self.delta_power*delta_time*2)
        if from_power >= to_power then
            self:ClearAction()

            self:StartClose()
        end
        self.txt_fight:SetText(from_power)
    end)
    seq:SetLoops(-1)
    seq:SetAutoKill(false)

    self.action_seq = seq
end

function RoleUpdatePowerView:ClearAction()
    if self.action_seq then
        self.action_seq:Kill(false)
        self.action_seq = nil
    end
end

function RoleUpdatePowerView:StartClose()
    local delta_time = 0.5
    local seq = DOTween.Sequence()
    seq:AppendInterval(delta_time)
    seq:OnComplete(function()
        self.ctrl:CloseUpdatePowerView()
    end)

    self.close_seq = seq
end

function RoleUpdatePowerView:ClearCloseSeq()
    if self.close_seq then
        self.close_seq:Kill(false)
        self.close_seq = nil
    end
end

return RoleUpdatePowerView
