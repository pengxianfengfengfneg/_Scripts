local CarbonView = Class(game.BaseView)

function CarbonView:_init(ctrl)
	self._package_name = "ui_carbon"
    self._com_name = "carbon_view"

    self._show_money = true

	self.ctrl = ctrl
end

function CarbonView:_delete()
	
end

function CarbonView:CloseViewCallBack()
end

function CarbonView:OpenViewCallBack(template_index)

    self.open_time = global.Time:GetServerTime()

	

    self:InitTemplates()

	self.tab_controller = self:GetRoot():AddControllerCallback("btn_tab", function(idx)

        local cur_time = global.Time:GetServerTime()
        if cur_time > self.open_time + 1 then
            for i = 1, 3 do
                self["template"..i]:StopCountTime()
            end
        end
    end)

	self._layout_objs["btn_close"]:AddClickCallBack(function()
        self.ctrl:CloseView()
    end)

    self._layout_objs["btn_back"]:AddClickCallBack(function()
        self.ctrl:CloseView()
    end)

    self.tab_controller:SetSelectedIndexEx((template_index and template_index -1) or 0)

    if game.IsZhuanJia then
    	self._layout_objs["btn_label1"]:SetVisible(false)

    	for i=2,4 do
    		local btn = self._layout_objs["btn_label" .. i]
    		btn:SetPosition(8+(i-2)*154, 1083)
    	end

    	self.tab_controller:SetSelectedIndexEx((template_index and template_index -1) or 1)
    end
end

function CarbonView:InitTemplates()

	self:GetTemplate("game/carbon/carbon_material_template", "material_template")
	self.template1 = self:GetTemplate("game/carbon/carbon_sjz_template", "sjz_template")
	self.template2 = self:GetTemplate("game/carbon/carbon_treasure_template", "treasure_template")
	self.template3 = self:GetTemplate("game/carbon/carbon_trial_template", "trial_template")

end

return CarbonView