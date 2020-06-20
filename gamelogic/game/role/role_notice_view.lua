local RoleNoticeView = Class(game.BaseView)

function RoleNoticeView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_notice_view"

    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
    self._show_money = false

    self.ctrl = ctrl
end

function RoleNoticeView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5593])

    self._layout_objs["ok_btn"]:AddClickCallBack(function()
        local txt = self._layout_objs["txt"]:GetText()
        if game.Utils.CheckMaskWords(txt) then
            game.GameMsgCtrl.instance:PushMsg(config.words[1005])
            return
        end
        self.ctrl:SendPersonalInfoChange(txt)
        self:Close()
    end)

    local txt = self.ctrl:GetPersonalInfo()
    self._layout_objs["txt"]:SetText(txt)

    self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        self:Close()
    end)
end

function RoleNoticeView:CloseViewCallBack()

end

return RoleNoticeView
