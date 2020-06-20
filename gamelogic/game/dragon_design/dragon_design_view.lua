local DragonDesignView = Class(game.BaseView)

function DragonDesignView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_design_view"

    self._show_money = true

    self.ctrl = ctrl

    self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignView:_delete()
end

function DragonDesignView:OpenViewCallBack(template_index)
    
    self._layout_objs["list_page"]:SetHorizontalBarTop(true)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6143])

    self:GetTemplateByObj("game/dragon_design/dragon_design_attr_template", self._layout_objs["list_page"]:GetChildAt(0), self)
    self:GetTemplateByObj("game/dragon_design/dragon_design_upgrade_template", self._layout_objs["list_page"]:GetChildAt(1), self)
    self:GetTemplateByObj("game/dragon_design/dragon_design_blood_template", self._layout_objs["list_page"]:GetChildAt(2), self)
    self:GetTemplateByObj("game/dragon_design/dragon_design_meta_template", self._layout_objs["list_page"]:GetChildAt(3), self)

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
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
                    self.tab_controller:SetSelectedIndex((template_index and template_index -1) or 0, true)
                    self:DelTimer()
                end
            end)
    end
end

function DragonDesignView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function DragonDesignView:CloseViewCallBack()
    self:DelTimer()
end

return DragonDesignView