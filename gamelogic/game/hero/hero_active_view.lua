local HeroActiveView = Class(game.BaseView)

function HeroActiveView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "hero_active_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function HeroActiveView:OpenViewCallBack(id)
    --self:InitModel()

    local hero_cfg = config.hero[id]
    global.AudioMgr:PlaySound(hero_cfg.sound)
    self._layout_objs.desc:SetText(hero_cfg.desc)
    self._layout_objs.name_bg:SetSprite("ui_common", "yx_bg" .. hero_cfg.color)
    self._layout_objs.name:SetText(hero_cfg.name)
    self.hero_scale = hero_cfg.zoom
    self.hero_offset = hero_cfg.offset
    --self.model:SetModel(game.ModelType.Body, hero_cfg.hero_bg)
    --self.model:PlayAnim(game.ObjAnimName.Show1)
    local bundle_name = "npc_" .. hero_cfg.hero_bg
    local bundle_path = self:GetPackageBundle("npc/" .. bundle_name)
    local asset_name = hero_cfg.hero_bg
    self:SetSpriteAsync(self._layout_objs.hero, bundle_path, bundle_name, asset_name, true)
end

function HeroActiveView:CloseViewCallBack()
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function HeroActiveView:OnEmptyClick()
    self:Close()
end

function HeroActiveView:InitModel()
    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs.hero, game.BodyType.ModelSp)
    self.model:SetPosition(0, -9.46, 20)
    self.model:SetRotateEnable(false)
    self.model:SetModelChangeCallBack(function()
        self.model:SetScale(self.hero_scale)
        self.model:SetPosition(self.hero_offset[1], self.hero_offset[2], 20)
    end)
end

return HeroActiveView
