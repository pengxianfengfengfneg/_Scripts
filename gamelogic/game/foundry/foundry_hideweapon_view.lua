local FoundryHideweaponView = Class(game.BaseView)

function FoundryHideweaponView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_hideweapon_view"
    self._show_money = true
    self.ctrl = ctrl
end

function FoundryHideweaponView:_delete()
end

function FoundryHideweaponView:OpenViewCallBack(template_index)

	self:GetBgTemplate("common_bg"):SetTitleName(config.words[1257])

    self._layout_objs["n9"]:SetHorizontalBarTop(true, 20)

    self:InitTabList()

    self.tab_controller = self:GetRoot():AddControllerCallback("tab_ctrl", function(idx)
        self.select_view_index = idx+1
    end)

    if not template_index then
        self.tab_controller:SetSelectedIndex((self.select_view_index and self.select_view_index -1) or 0, true)
    else
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
end

function FoundryHideweaponView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function FoundryHideweaponView:CloseViewCallBack()
    self:DelTimer()
end

function FoundryHideweaponView:InitTabList()
    self:GetTemplateByObj("game/foundry/foundry_hideweapon_practice_template", self._layout_objs["n9"]:GetChildAt(0))
    self:GetTemplateByObj("game/foundry/foundry_hideweapon_forge_template", self._layout_objs["n9"]:GetChildAt(1))
    self:GetTemplateByObj("game/foundry/foundry_hideweapon_upgrade_template", self._layout_objs["n9"]:GetChildAt(2))
    self:GetTemplateByObj("game/foundry/foundry_hideweapon_skill_template", self._layout_objs["n9"]:GetChildAt(3))
end

function FoundryHideweaponView:SetBtnLabelName(val)

    if val == 2 then
        self._layout_objs["btn_1"]:SetText(config.words[1265])
    else
        self._layout_objs["btn_1"]:SetText(config.words[1264])
    end
end

return FoundryHideweaponView
