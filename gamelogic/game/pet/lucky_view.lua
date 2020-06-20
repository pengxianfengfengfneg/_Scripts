local LuckyView = Class(game.BaseView)

function LuckyView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "lucky_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function LuckyView:OnEmptyClick()
    self:Close()
end

function LuckyView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1529])

    self._layout_objs["common_bg/btn_close"]:SetVisible(false)
    self._layout_objs["common_bg/btn_back"]:SetVisible(false)
end

return LuckyView
