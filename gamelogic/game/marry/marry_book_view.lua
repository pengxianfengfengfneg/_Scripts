local MarryBookView = Class(game.BaseView)

function MarryBookView:_init(ctrl)
    self._package_name = "ui_marry"
    self._com_name = "marry_book_view"
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function MarryBookView:OpenViewCallBack()
    self.OnEmptyClick = function()
    end
    self._layout_objs.n0:SetTouchDisabled(false)
    self.tween = DOTween.Sequence()
    for i = 1, 7 do
        self._layout_objs["n" .. i]:SetFillAmount(0)
        self.tween:Append(self._layout_objs["n" .. i]:TweenFillValue(1, 1))
    end
    self.tween:AppendCallback(function()
        self.OnEmptyClick = function()
            self:Close()
        end
    end)
end

function MarryBookView:CloseViewCallBack()
    if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end
end

return MarryBookView
