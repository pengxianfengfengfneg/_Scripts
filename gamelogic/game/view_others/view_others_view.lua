local ViewOthersView = Class(game.BaseView)

function ViewOthersView:_init()
    self._package_name = "ui_view_others"
    self._com_name = "view_others"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self:AddPackage("ui_pet")
    self:AddPackage("ui_role")
    self:AddPackage("ui_foundry")
    self:AddPackage("ui_hero")
    self:AddPackage("ui_heroicon")
end

function ViewOthersView:OnEmptyClick()
    self:Close()
end

function ViewOthersView:OpenViewCallBack(info)
    self.info = info
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3301])
    self:InitTemplate()
end

function ViewOthersView:InitTemplate()
    self.role_template = self:GetTemplate("game/view_others/role_template", "n17", self.info.info)
    self.pet_template = self:GetTemplate("game/view_others/pet_template", "n18", self.info.pet_list)
    self.futi_template = self:GetTemplate("game/view_others/futi_template", "n19", self.info)
    self.pulse_template = self:GetTemplate("game/view_others/pulse_template", "n20", self.info)
    self.smelt_template = self:GetTemplate("game/view_others/smelt_template", "n21", self.info)

end

return ViewOthersView
