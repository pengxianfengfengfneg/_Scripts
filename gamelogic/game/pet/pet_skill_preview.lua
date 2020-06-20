local PetSkillPreview = Class(game.BaseView)

function PetSkillPreview:_init()
    self._package_name = "ui_pet"
    self._com_name = "skill_preview"
    self._view_level = game.UIViewLevel.Third
    self._show_money = true
end

function PetSkillPreview:OpenViewCallBack()
    self:InitBg()
    self:InitTemplate()
end

function PetSkillPreview:InitBg()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1503])
end

function PetSkillPreview:InitTemplate()
    for i = 1, 2 do
        self:GetTemplateByObj("game/pet/pet_skill_preview_template", self._layout_objs.list_page:GetChildAt(i - 1), i)
    end

    self._layout_objs.list_page:SetHorizontalBarTop(true)
end

return PetSkillPreview
