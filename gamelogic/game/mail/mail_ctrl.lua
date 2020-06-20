local MailCtrl = Class(game.BaseCtrl)

function MailCtrl:_init()
    if MailCtrl.instance ~= nil then
        error("MailCtrl Init Twice!")
    end
    MailCtrl.instance = self

    self.mail_view = require("game/mail/mail_view").New(self)
    self.mail_content_view = require("game/mail/mail_content_view").New(self)
    self.data = require("game/mail/mail_data").New(self)

    self:RegisterAllProtocal()
    self:RegisterAllEvents()
end

function MailCtrl:_delete()
    self.mail_view:DeleteMe()
    self.mail_content_view:DeleteMe()
    self.data:DeleteMe()
    MailCtrl.instance = nil
end

function MailCtrl:RegisterAllProtocal()
    local proto = {
        [40302] = "OnGetMailList",
        [40303] = "OnMailNotifyNew",
        [40304] = "OnMailNotifyExpired",
        [40306] = "OnMailGetAttach",
        [40308] = "OnMailDelete",
        [40310] = "OnMailOneKeyGetAttach",
        [40312] = "OnMailOneKeyDelete",
    }
    for id, func_name in pairs(proto) do
        self:RegisterProtocalCallback(id, func_name)
    end
end

function MailCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginRoleRet, handler(self, self.OnLoginRoleRet)},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MailCtrl:OpenView()
    self.mail_view:Open()
    self:FireEvent(game.MailEvent.OpenView)
end

function MailCtrl:CloseView()
    self.mail_view:Close()
end

function MailCtrl:IsOpenView()
    if self.mail_view then
        return self.mail_view:IsOpen()
    else
        return false
    end
end

function MailCtrl:OpenMailContentView(...)
    self.mail_content_view:Open(...)
end

function MailCtrl:OpenMailItemView(...) 
    self.mail_item_view:Close()
    self.mail_item_view:Open(...)
end

function MailCtrl:SendGetMailList()
    self:SendProtocal(40301)
end

function MailCtrl:SendMailGetAttach(mail_id)
    self:SendProtocal(40305, {id = mail_id})
end

function MailCtrl:SendMailDelete(mail_id)
    self:SendProtocal(40307, {id = mail_id})
end

function MailCtrl:SendMailOneKeyGetAttach()
    self:SendProtocal(40309)
end

function MailCtrl:SendMailOneKeyDelete()
    self:SendProtocal(40311)
end

function MailCtrl:SendMailMarkAsRead(mail_id)
    self:SendProtocal(40313, {id = mail_id})
end

function MailCtrl:OnLoginRoleRet(value)
    if value then
        self:SendGetMailList()
    end
end

--获取邮件列表
function MailCtrl:OnGetMailList(mails)
    self.data:SetData(mails)
end

--新邮件到达
function MailCtrl:OnMailNotifyNew(mails)
    self.data:NewMail(mails)
end

--邮件过期
function MailCtrl:OnMailNotifyExpired(data)
    self.data:DeleteMailList(data.list)
end

--领取附件
function MailCtrl:OnMailGetAttach(data)
    self.data:SetAttachGet(data.id)
end

--删除邮件
function MailCtrl:OnMailDelete(data)
    self.data:DeleteMail(data.id)
end

--一键领取
function MailCtrl:OnMailOneKeyGetAttach(mails)
    self.data:SetAttachListGet(mails.list)
end

--一键删除
function MailCtrl:OnMailOneKeyDelete(mails)
    self.data:DeleteMailList(mails.list)
end

function MailCtrl:GetMailList()
    return self.data:GetMailList()
end

function MailCtrl:GetMail(id)
    return self.data:GetMail(id)
end

function MailCtrl:IsAllRead()
    return self.data:IsAllRead()
end

game.MailCtrl = MailCtrl

return MailCtrl