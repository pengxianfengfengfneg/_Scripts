local WeaponSoulSkillPreView = Class(game.BaseView)

function WeaponSoulSkillPreView:_init(ctrl)
    self._package_name = "ui_weapon_soul"
    self._com_name = "skill_preview"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function WeaponSoulSkillPreView:_delete()
end

function WeaponSoulSkillPreView:OpenViewCallBack(params)
    local skill_id = params.skill_id
    local skill_lv = params.skill_lv

    local skill_cfg = config.skill[skill_id][skill_lv]

    self._layout_objs["skill_name"]:SetText(skill_cfg.name)

    self._layout_objs["skill_image"]:SetSprite("ui_skill_icon", skill_cfg.icon)

    self._layout_objs["lv"]:SetText(skill_lv)

    self._layout_objs["type_txt"]:SetText(game.GetSkillTypeName[skill_cfg.type])

    self._layout_objs["skill_desc"]:SetText(skill_cfg.desc)
end

function WeaponSoulSkillPreView:CloseViewCallBack()

end

function WeaponSoulSkillPreView:OnEmptyClick()
    self:Close()
end

return WeaponSoulSkillPreView