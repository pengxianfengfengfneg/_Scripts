local RoleTemplate = Class(game.UITemplate)

function RoleTemplate:_init(parent, info)
    self.parent_view = parent
    self.info = info
end

function RoleTemplate:OpenViewCallBack()
    self:InitTemlate()
end

function RoleTemplate:InitTemlate()
    self:GetTemplateByObj("game/view_others/role_base_com", self._layout_objs.list_page:GetChildAt(0), self.info)
    self:GetTemplateByObj("game/view_others/role_info_com", self._layout_objs.list_page:GetChildAt(1), self.info)
    self._layout_objs.list_page:SetHorizontalBarTop(true)
end

return RoleTemplate