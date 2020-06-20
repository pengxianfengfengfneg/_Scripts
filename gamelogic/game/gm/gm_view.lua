local GmView = Class(game.BaseView)

function GmView:_init(ctrl)
    self._package_name = "ui_gm"
    self._com_name = "gm_view"

    self._ui_order = game.UIZOrder.UIZOrder_Tips-1
    self._view_level = game.UIViewLevel.Standalone

    self.ctrl = ctrl
end

function GmView:OpenViewCallBack()
end

function GmView:CloseViewCallBack()
    for _,v in ipairs(self.list_array or {}) do
        v:DeleteMe()
    end
    self.list_array = {}
end

return GmView
