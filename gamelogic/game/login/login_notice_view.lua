
local LoginNoticeView = Class(game.BaseView)

function LoginNoticeView:_init(ctrl)
	self._package_name = "ui_login"
    self._com_name = "notice_view"
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
    self._ui_order = game.UIZOrder.UIZOrder_Tips
	self.ctrl = ctrl
end

function LoginNoticeView:OpenViewCallBack()
    self:Init()
    game.ServiceMgr:RequestServerNotice(function(json_data)
        self:SetTitleText(json_data.data.title)
        self:SetContentText(json_data.data.content)
    end)
end

function LoginNoticeView:CloseViewCallBack()
    
end

function LoginNoticeView:Init()
    self.txt_title = self._layout_objs["txt_title"]
    self.content_com = self._layout_objs["list_content"]:GetChildAt(0)

    self._layout_objs["btn_ok"]:AddClickCallBack(function()
        self:Close()
    end)
end

function LoginNoticeView:SetContentText(content)
    self.content_com:SetText(content)
    self._layout_objs["list_content"]:ScrollToView(0)
end

function LoginNoticeView:SetTitleText(title)
    self.txt_title:SetText(title)
end

return LoginNoticeView
