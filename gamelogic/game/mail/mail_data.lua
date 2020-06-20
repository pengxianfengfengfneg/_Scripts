local MailData = Class(game.BaseData)

function MailData:_init(ctrl)
    self.mail_info = {}
    self.ctrl = ctrl
end

function MailData:_delete()
end

function MailData:SetData(data)
    local mail_info = self.mail_info
    for i, mail in pairs(data.mails) do
        mail_info[mail.id] = mail
    end
    self:FireEvent(game.MailEvent.RefreshView)
end

function MailData:GetMailList()
    local mail_list = self:GetNotReadMailList()
    local read_list = self:GetReadMailList()
    for i, mail in pairs(read_list) do
        table.insert(mail_list, mail)
    end
    return mail_list
end

function MailData:GetReadMailList()
    local read_list = {}
    for i, mail in pairs(self.mail_info) do
        if not self:IsNotRead(mail)  then
            table.insert(read_list, mail)
        end
    end
    table.sort(read_list, function(m, n) return m.time > n.time end)
    return read_list
end

function MailData:GetNotReadMailList()
    local not_read_list = {}
    for i, mail in pairs(self.mail_info) do
        if self:IsNotRead(mail) then
            table.insert(not_read_list, mail)
        end
    end
    table.sort(not_read_list, function(m, n) return m.time > n.time end)
    return not_read_list
end

function MailData:IsNotRead(mail)
    return mail.state == 0 or mail.state == 2 or mail.state == 3
end

function MailData:IsAllRead()
    for i, mail in pairs(self.mail_info) do
        if self:IsNotRead(mail) then
            return false
        end
    end
    return true
end

function MailData:NewMail(data)
    self:SetData(data)
    self:FireEvent(game.MailEvent.NewMail)
end

function MailData:GetMail(id)
    return self.mail_info[id]
end

function MailData:DeleteMail(id)
    if self.mail_info[id] ~= nil then
        self.mail_info[id] = nil
        self:FireEvent(game.MailEvent.RefreshView)
    end
end

function MailData:DeleteMailList(id_list)
    for i, v in pairs(id_list) do
        self.mail_info[v.id] = nil
    end
    self:FireEvent(game.MailEvent.RefreshView)
end

function MailData:SetAttachGet(id)
    self.mail_info[id].state = 4
    self:FireEvent(game.MailEvent.GetAttach, id)
    self:FireEvent(game.MailEvent.RefreshView, id)
end

function MailData:SetAttachListGet(id_list)
    for i, v in pairs(id_list) do
        self.mail_info[v.id].state = 4
    end
    self:FireEvent(game.MailEvent.RefreshView)
end

return MailData