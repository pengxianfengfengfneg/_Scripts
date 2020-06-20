local FoundryGodweaponPreView = Class(game.BaseView)

function FoundryGodweaponPreView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_godweapon_preview"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function FoundryGodweaponPreView:_delete()

end

function FoundryGodweaponPreView:OpenViewCallBack(need_show_anim)

	self._layout_objs["btn_close"]:AddClickCallBack(function ()
        game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_godweapon_preview/btn_close"})
        self:Close()
    end)

	local career = game.RoleCtrl.instance:GetCareer()
	local id = career*100 + 1
	local cfg = config.artifact_base[career][id]
    self.model_id = cfg.model

    if need_show_anim then
        self._layout_objs["weapon_name"]:SetVisible(false)
        self._layout_objs["n6"]:SetVisible(false)
        self._layout_objs["n12"]:SetVisible(false)
        self:SetAnim()
    else
        self._layout_objs["weapon_name"]:SetVisible(true)
        self._layout_objs["n6"]:SetVisible(true)
        self._layout_objs["n12"]:SetVisible(true)
        self:ShowModel(self.model_id)
    end

	self._layout_objs["weapon_name"]:SetSprite("ui_foundry", cfg.icon)
end

function FoundryGodweaponPreView:CloseViewCallBack()
	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end

    if self.model2 then
        self.model2:DeleteMe()
        self.model2 = nil
    end

    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end

    if self.tween2 then
        self.tween2:Kill(false)
        self.tween2 = nil
    end

    if self.tween3 then
        self.tween3:Kill(false)
        self.tween3 = nil
    end
end

function FoundryGodweaponPreView:ShowModel(weapon_id)

	if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end

    if self.tween2 then
        self.tween2:Kill(false)
        self.tween2 = nil
    end

    if self.tween3 then
        self.tween3:Kill(false)
        self.tween3 = nil
    end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs["model"], game.BodyType.Weapon)
    self.model:SetRotation(-12, 163.5, -6.88)
    self.model:SetModel(game.ModelType.WeaponUI, weapon_id, true)
    self.model:SetAlwaysAnim(true)
    self.model:PlayAnim(game.ObjAnimName.Show1, game.ModelType.WeaponUI)
    self.model:SetModelChangeCallBack(function()
        local cfg = config.artifact_show[weapon_id]
        local pos = cfg.ui_pos_yl
        self.model:SetPosition(pos[1], pos[2], pos[3])
        self.model:SetScale(cfg.ui_show_ratio_yl)

        self.tween2 = DOTween.Sequence()
        self.tween2:AppendInterval(0.5)
        self.tween2:AppendCallback(function()
            local show_effct = cfg.show_effect
            for k, v in pairs(show_effct) do
                self.model:SetEffect(v[1], v[2], game.ModelType.WeaponUI, true)
            end
            self._layout_objs["model"]:SetVisible(true)
        end)


	    self.tween = DOTween.Sequence()
	    self.tween:AppendInterval(3)
	    self.tween:AppendCallback(function()
	        self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.WeaponUI)
	        local idle_effect = cfg.idle_effect
		    for k, v in pairs(idle_effect) do
		    	self.model:SetEffect(v[1], v[2], game.ModelType.WeaponUI, true)
		    end
	    end)
    end)    
end

function FoundryGodweaponPreView:SetAnim()
    if self.model2 then
        self.model2:DeleteMe()
        self.model2 = nil
    end

    self._layout_objs["model2"]:SetVisible(true)
    self.model2 = require("game/character/model_template").New()
    self.model2:CreateDrawObj(self._layout_objs["model2"], game.BodyType.Monster)
    self.model2:SetPosition(-0.012, -0.809, 3.129)
    self.model2:SetRotation(-5.785, 265.711, 3.281)
    self.model2:SetModel(game.ModelType.Body, 5045)
    self.model2:PlayAnim(game.ObjAnimName.Show1)
    self.model2:SetAlwaysAnim(true)
    self.model2:SetModelChangeCallBack(function()

        self._layout_objs.effect:SetVisible(true)
        self:CreateUIEffect(self._layout_objs.effect, "effect/ui/hufu_show.ab")

        self.tween3 = DOTween.Sequence()
        self.tween3:AppendInterval(5)
        self.tween3:AppendCallback(function()
            self._layout_objs["model2"]:SetVisible(false)
            self._layout_objs["effect"]:SetVisible(false)
            self._layout_objs["weapon_name"]:SetVisible(true)
            self._layout_objs["n12"]:SetVisible(true)
            self:ShowModel(self.model_id)
        end)
    end)
end

return FoundryGodweaponPreView