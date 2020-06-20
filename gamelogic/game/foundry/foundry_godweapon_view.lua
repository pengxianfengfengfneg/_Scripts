local FoundryGodweaponView = Class(game.BaseView)

function FoundryGodweaponView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_godweapon_view2"

    self.ctrl = ctrl
end

function FoundryGodweaponView:_delete()
end

function FoundryGodweaponView:OpenViewCallBack(template_index)

    self.ctrl:CsArtifactGetInfo()

    self:InitTemplates()

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1252])

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
    end)

    local time = 1
    self.timer = global.TimerMgr:CreateTimer(0.5,
        function()
            time = time - 1
            if time <= 0 then
                self.tab_controller:SetSelectedIndexEx((template_index and template_index -1) or 0)
                self:DelTimer()
            end
        end)
end

function FoundryGodweaponView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function FoundryGodweaponView:CloseViewCallBack()
    self:DelTimer()
end

function FoundryGodweaponView:InitTemplates()
    
    self._layout_objs["list_page"]:SetHorizontalBarTop(true)

    self.template1 = self:GetTemplateByObj("game/foundry/foundry_godweapon_forge_template", self._layout_objs["list_page"]:GetChildAt(0))
    self.template2 = self:GetTemplateByObj("game/foundry/foundry_godweapon_huanhua_template", self._layout_objs["list_page"]:GetChildAt(1))
end

function FoundryGodweaponView:SetCombat(val)
    self._layout_objs["combat_txt"]:SetText(val)
end

return FoundryGodweaponView
