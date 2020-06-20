local FoundrySmeltSetView = Class(game.BaseView)

function FoundrySmeltSetView:_init(ctrl)
    self._package_name = "ui_foundry"
    self._com_name = "foundry_smelt_set_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
end

function FoundrySmeltSetView:_delete()
end

function FoundrySmeltSetView:OpenViewCallBack()

    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
        self:FireEvent(game.FoundryEvent.UpdateSmeltColor)
    end)

    self._layout_objs["btn1"]:AddClickCallBack(function()
        self.ctrl:SetSmelData(self.color)
        self:Close()
        self:FireEvent(game.FoundryEvent.UpdateSmeltColor)
    end)

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
    	self.color = idx+1
    end)

    local smelt_data = self.ctrl:GetSmeltData()
    local color = smelt_data.value
    if color == 0 then
    	color = 1
    end
    self.color = color
    self.tab_controller:SetSelectedIndexEx(color-1)
end

function FoundrySmeltSetView:CloseViewCallBack()

end

return FoundrySmeltSetView
