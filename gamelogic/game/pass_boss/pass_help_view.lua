local PassHelpView = Class(game.BaseView)

function PassHelpView:_init(ctrl)
    self._package_name = "ui_pass_boss"
    self._com_name = "pass_help_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
end

function PassHelpView:OpenViewCallBack(pass_id)
    self:Init(pass_id)
    self:InitBg()
    self:InitBtns()

end

function PassHelpView:CloseViewCallBack()

end

function PassHelpView:Init(pass_id)
    self.pass_id = pass_id


end

function PassHelpView:InitBtns()
    self.btn_world = self._layout_objs["btn_world"]
    self.btn_world:AddClickCallBack(function()

    end)

    self.btn_guild = self._layout_objs["btn_guild"]
    self.btn_guild:AddClickCallBack(function()

    end)
end

function PassHelpView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1657]):HideBtnBack()
end

function PassHelpView:OnEmptyClick()
    self:Close()
end


return PassHelpView
