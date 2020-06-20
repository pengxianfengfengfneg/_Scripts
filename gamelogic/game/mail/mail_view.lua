local MailView = Class(game.BaseView)

function MailView:_init(ctrl)
    self._package_name = "ui_mail"
    self._com_name = "mail_view"
    self.ctrl = ctrl
    self._show_money = true
    self._view_level = game.UIViewLevel.First
end

function MailView:OpenViewCallBack()
    self:Init()
    self:RegisterEvent()
    self.ctrl:SendGetMailList()
end

function MailView:CloseViewCallBack()
    self.mail_list = nil
end

function MailView:Init()
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.func[game.OpenFuncId.Mail_Main].name)
    self._layout_objs["btn_read_all"]:AddClickCallBack(function()
        self.ctrl:SendMailOneKeyGetAttach()
    end)
    self._layout_objs["btn_delete_all"]:AddClickCallBack(function()
        self.ctrl:SendMailOneKeyDelete()
    end)
    self:InitList()
end

function MailView:InitList()
    self.mail_list = self:CreateList("list", "game/mail/item/mail_item", true)
    self.mail_list:SetRefreshItemFunc(function(item, idx)
        item:Refresh(idx)
    end)
end

function MailView:RegisterEvent()
    self:BindEvent(game.MailEvent.RefreshView, function()
        self:RefreshView()
    end)
end

function MailView:RefreshView()
    local num = table.nums(self.ctrl:GetMailList())
    self.mail_list:SetItemNum(num)
end

return MailView
