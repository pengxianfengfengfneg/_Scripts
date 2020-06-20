local MenterNoticeView = Class(game.BaseView)

function MenterNoticeView:_init(ctrl)
    self._package_name = "ui_mentor"
    self._com_name = "notice_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function MenterNoticeView:OpenViewCallBack(info)
    self:Init(info)
    self:InitBg()
end

function MenterNoticeView:CloseViewCallBack()

end

function MenterNoticeView:Init(info)
    self.txt_content = self._layout_objs["txt_content"]
    self.txt_content:SetText(config.words[6424])

    self.btn_cancel = self._layout_objs["btn_cancel"]
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        local content = self.txt_content:GetText()
        if game.Utils.CheckMaskChatWords(self.txt_content:GetText()) then
            game.GameMsgCtrl.instance:PushMsgCode(1413)
        else
            self.ctrl:SendMentorSendPost(info.role_id, content)
            self:OpenChatView(info)
            self:Close()
        end
    end)
end

function MenterNoticeView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6413])
end

function MenterNoticeView:OpenChatView(info)
    local chat_info = {
        id = info.role_id,
        name = info.name,
        lv = info.lv,
        career = info.career,
        svr_num = 1,
    }
    game.ChatCtrl.instance:OpenFriendChatView(chat_info)
end

return MenterNoticeView
