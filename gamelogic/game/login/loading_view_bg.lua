local LoadingViewBG = Class(game.BaseView)

function LoadingViewBG:_init()
    self._package_name = "ui_login"
    self._com_name = "loading_view_bg"
    self._ui_order = game.UIZOrder.UIZOrder_Low - 1
    self._layer_name = game.LayerName.UI2
end

return LoadingViewBG