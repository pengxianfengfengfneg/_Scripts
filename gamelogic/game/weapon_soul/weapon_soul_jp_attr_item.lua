local WeaponSoulJPAttrView = Class(game.UITemplate)

function WeaponSoulJPAttrView:_init(parent)
    self.parent = parent
end

function WeaponSoulJPAttrView:OpenViewCallBack()

end

function WeaponSoulJPAttrView:CloseViewCallBack()

end

function WeaponSoulJPAttrView:RefreshItem(idx)
    local list_data = self.parent:GetListData()
    local data = list_data[idx]
    local attr_type = data.attr_type
    local attr_value = data.attr_value

    local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
    self._layout_objs["attr_name"]:SetText(attr_name)

    self._layout_objs["attr_value"]:SetText(attr_value)
end

return WeaponSoulJPAttrView