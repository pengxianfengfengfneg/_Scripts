local SkillInfoView = Class(game.BaseView)

function SkillInfoView:_init(ctrl)
    self._package_name = "ui_common"
    self._com_name = "skill_info_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function SkillInfoView:OnEmptyClick()
    self:Close()
end

function SkillInfoView:OpenViewCallBack(info)
    local level = info.lv or 1
    local skill_cfg = config.skill[info.id][level]
    self._layout_objs.name:SetText(skill_cfg.name)
    self._layout_objs.level:SetText(level .. config.words[1217])
    if skill_cfg.type == 3 then
        self._layout_objs.type:SetText(config.words[1536])
    else
        self._layout_objs.type:SetText(config.words[1535])
    end
    if config.pet_skill_desc[info.id] then
        local skill_desc = config.pet_skill_desc[info.id][level]
        self._layout_objs.desc:SetText(string.format(skill_desc.desc, table.unpack(skill_desc.param)))
    else
        self._layout_objs.desc:SetText(skill_cfg.desc)
    end
    local skill_item = self:GetTemplate("game/skill/item/skill_item_rect", "skill_item")
    skill_item:SetItemInfo({ id = info.id })
end

return SkillInfoView
