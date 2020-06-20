local PetQualityView = Class(game.BaseView)

function PetQualityView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_quality_view"
    self._view_level = game.UIViewLevel.Third
    self._show_money = true

    self.ctrl = ctrl
end

function PetQualityView:OpenViewCallBack(info)
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1504])

    self:InitTemplate(info)

    self._layout_objs.list_tab:SetVisible(info.quality ~= 2)
    self._layout_objs.god_list_tab:SetVisible(info.quality == 2)
end

function PetQualityView:InitTemplate(info)
    for i = 1, 4 do
        self:GetTemplateByObj("game/pet/pet_quality_template", self._layout_objs.list_page:GetChildAt(i - 1), {info, i})
    end

    self._layout_objs.list_page:SetHorizontalBarTop(true, 21)
end

return PetQualityView
