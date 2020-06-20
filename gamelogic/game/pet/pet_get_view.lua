local PetGetView = Class(game.BaseView)

function PetGetView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "pet_get_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetGetView:OnEmptyClick()
    self:Close()
end

function PetGetView:OpenViewCallBack(info)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1530])

    self._layout_objs.name:SetText(info.name)
    self._layout_objs.ratio:SetText(config.words[1531] .. "：" .. info.growup_rate)

    for i = 1, 9 do
        self._layout_objs["star" .. i]:SetVisible(info.star >= i)
    end

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.pet, game.BodyType.Monster)
    self.model:SetPosition(0, -0.85, 3.5)
    self.model:SetRotation(0, 140, 0)
    local pet_cfg = config.pet[info.cid]
    self.model:SetPosition(0, 0 - pet_cfg.height, 2.5)
    self.model:SetScale(pet_cfg.scale)
    self.model:SetModel(game.ModelType.Body, self.ctrl:GetPetModel(info))
    self.model:PlayAnim(game.ObjAnimName.Idle)
end

function PetGetView:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

return PetGetView