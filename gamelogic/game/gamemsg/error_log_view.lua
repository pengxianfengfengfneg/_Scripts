local ErrorLogView = Class(game.BaseView)

function ErrorLogView:_init(ctrl)
    self._package_name = "ui_game_msg"
    self._com_name = "error_log_view"

    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Top

    self._layer_name = game.LayerName.UIDefault

    self.ctrl = ctrl
end

function ErrorLogView:OpenViewCallBack()
    self:GetFullBgTemplate("common_bg"):SetTitleName("ERROR LOG")
    self.content = self._layout_objs.list:GetChildAt(0):GetChild("content")
    self:UpdateContent()
end

function ErrorLogView:CloseViewCallBack()
    self.ctrl:RemoveErrorLog()
end

function ErrorLogView:UpdateContent()
    local error_stack = self.ctrl.error_stack
    local error_str = ""
    for _, v in ipairs(error_stack) do
        error_str = error_str .. v .. "\n"
    end
    self.content:SetText(error_str)
end

return ErrorLogView