local MailItem = Class(game.UITemplate)

function MailItem:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        self:OnItemClick()
    end)
end

function MailItem:Refresh(idx)
    local mail_info = game.MailCtrl.instance:GetMailList()[idx]
    self._layout_objs["txt_mail_title"]:SetText(mail_info.title)
    self:SetTimeText(mail_info.time)
    self:SetIconImage(mail_info)
    self.mail_info = mail_info
    self:SetBg(idx)
end

function MailItem:SetTimeText(mail_time)
    local time = os.date("%Y-%m-%d", mail_time)
    self._layout_objs["txt_mail_time"]:SetText(time)
end

function MailItem:SetIconImage(mail_info)
    local icon_name = ""
    if mail_info.state == 0 then
        icon_name = "yj_01"
    elseif mail_info.state == 2 or mail_info.state == 3 then
        icon_name = "yj_02"
    elseif mail_info.state == 1 or mail_info.state >= 4 then
        icon_name = "yj_03"
    end
    self._layout_objs["img_icon"]:SetSprite("ui_common", icon_name)
end

function MailItem:OnItemClick()
    local refresh_tag = false
    local mail_info = self.mail_info
    if mail_info.state == 0 or mail_info.state == 2 then
        mail_info.state = mail_info.state + 1
        self:SetIconImage(mail_info)
        game.MailCtrl.instance:SendMailMarkAsRead(mail_info.id)
        refresh_tag = mail_info.state == 1
    end
    game.MailCtrl.instance:OpenMailContentView(self.mail_info)
    if refresh_tag then
        self:FireEvent(game.MailEvent.RefreshView)
    end
end

function MailItem:SetBg(idx)
    idx = idx % 2
    if idx == 0 then
        idx = 2
    end
    self._layout_objs.img_bg:SetSprite("ui_common", "009_" .. idx)
end

return MailItem