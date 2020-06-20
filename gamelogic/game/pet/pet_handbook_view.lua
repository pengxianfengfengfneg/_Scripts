local PetHandbookView = Class(game.BaseView)

function PetHandbookView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_handbook_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self._show_money = true

    self.ctrl = ctrl
end

function PetHandbookView:OpenViewCallBack()
    self:InitBg()
    self:InitTemplate()
end

function PetHandbookView:InitBg()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[1504])
end

function PetHandbookView:InitTemplate()
    local idx = {1, 3, 2}
    for i = 1, 3 do
        self:GetTemplateByObj("game/pet/pet_handbook_template", self._layout_objs.page:GetChildAt(i - 1), idx[i])
    end

    self._layout_objs.page:SetHorizontalBarTop(true ,21)
end

return PetHandbookView
