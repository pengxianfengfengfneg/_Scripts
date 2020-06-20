local PulseTemplate = Class(game.UITemplate)

function PulseTemplate:_init(parent, info)
    self.parent_view = parent
    self.info = info
end

function PulseTemplate:OpenViewCallBack()
    self:InitTemlate()
end

function PulseTemplate:InitTemlate()
    self:GetTemplateByObj("game/view_others/pulse_view_com", self._layout_objs.list_page:GetChildAt(0), self.info)
    self:GetTemplateByObj("game/view_others/pulse_attr_com", self._layout_objs.list_page:GetChildAt(1), self.info)
    self._layout_objs.list_page:SetHorizontalBarTop(true)
end

return PulseTemplate