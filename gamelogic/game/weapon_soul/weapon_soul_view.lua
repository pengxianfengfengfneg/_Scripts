local WeaponSoulView = Class(game.BaseView)

function WeaponSoulView:_init(ctrl)
    self._package_name = "ui_weapon_soul"
    self._com_name = "weapon_soul_view"

    self._show_money = true

    self.ctrl = ctrl
end

function WeaponSoulView:_delete()
end

function WeaponSoulView:OpenViewCallBack(tab_index)

	self._layout_objs["list_page"]:SetHorizontalBarTop(true)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6100])

    self:GetTemplateByObj("game/weapon_soul/weapon_soul_jz_template", self._layout_objs["list_page"]:GetChildAt(0), self)
    self:GetTemplateByObj("game/weapon_soul/weapon_soul_sx_template", self._layout_objs["list_page"]:GetChildAt(1), self)
    self:GetTemplateByObj("game/weapon_soul/weapon_soul_nh_template", self._layout_objs["list_page"]:GetChildAt(2), self)
    self:GetTemplateByObj("game/weapon_soul/weapon_soul_jp_template", self._layout_objs["list_page"]:GetChildAt(3), self)

    tab_index = tab_index or 1
    self:GetRoot():GetController("c1"):SetSelectedIndexEx(tab_index-1)
end

function WeaponSoulView:CloseViewCallBack()
    self:FireEvent(game.WeaponSoulEvent.RefreshMainUI)
end

function WeaponSoulView:SetTabRedPoint(ui_name, visible)
    self._layout_objs[ui_name]:SetVisible(visible)
end

return WeaponSoulView