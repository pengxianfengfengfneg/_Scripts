local GatherBarView = Class(game.BaseView)

function GatherBarView:_init()
    self._package_name = "ui_main"
    self._com_name = "gather_bar_view"
    self._view_level = game.UIViewLevel.Standalone
    self._mask_type = game.UIMaskType.None

    self._ui_order = game.UIZOrder.UIZOrder_Common_Beyond

end

function GatherBarView:OpenViewCallBack(txt, time, vitality_str)
    self._layout_objs["gather_bar/txt"]:SetText(txt)
    self._layout_objs.gather_bar:SetProgressValue(0)
    self._layout_objs.gather_bar:SetProgressValueTween(100, time)

    self._layout_objs["gather_bar/group_engry"]:SetVisible(vitality_str ~= nil)
    if vitality_str then
        self._layout_objs["gather_bar/txt_enrgy"]:SetText(vitality_str)
    end
end

return GatherBarView
