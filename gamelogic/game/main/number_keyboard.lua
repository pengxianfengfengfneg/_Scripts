local NumberKeyboard = Class(game.BaseView)

function NumberKeyboard:_init()
    self._package_name = "ui_main"
    self._com_name = "number_keyboard"

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Fouth

end

function NumberKeyboard:OpenViewCallBack()
    self._layout_objs.bg:SetTouchDisabled(false)
    self._layout_objs.touch:AddClickCallBack(function()
        self:Close()
    end)

    for i = 0, 9 do
        self._layout_objs["n" .. i]:SetTouchDisabled(false)
        self._layout_objs["n" .. i]:AddClickCallBack(function()
            self:FireEvent(game.NumberKeyboardEvent.Number, i)
        end)
    end

    self._layout_objs.ok:SetTouchDisabled(false)
    self._layout_objs.ok:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.del:SetTouchDisabled(false)
    self._layout_objs.del:AddClickCallBack(function()
        self:FireEvent(game.NumberKeyboardEvent.Number, -1)
    end)

    self._layout_objs.group:SetPositionX(self.pos_x)
    self._layout_objs.group:SetPositionY(self.pos_y)
end

function NumberKeyboard:CloseViewCallBack()
    self:FireEvent(game.NumberKeyboardEvent.Close)
end

function NumberKeyboard:SetPos(x, y)
    self.pos_x = x or 158
    self.pos_y = y or 460
end

return NumberKeyboard
