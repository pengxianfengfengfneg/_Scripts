local DragonDesignEatSetView = Class(game.BaseView)

function DragonDesignEatSetView:_init(ctrl)
    self._package_name = "ui_dragon_design"
    self._com_name = "dragon_eat_set_view"
    self._view_level = game.UIViewLevel.Fouth
    self.ctrl = ctrl

    self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignEatSetView:_delete()
end

function DragonDesignEatSetView:OpenViewCallBack()
    
    self._layout_objs["btn_close"]:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs["btn1"]:AddClickCallBack(function()
        self.ctrl:SetEatColor(self.color)
        self:Close()
        self:FireEvent(game.DragonDesignEvent.UpdateSetColor)
    end)

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
    	self.color = idx+1
    end)

    local color = self.ctrl:GetEatColor()
    self.color = color
    self.tab_controller:SetSelectedIndexEx(color-1)
end

return DragonDesignEatSetView