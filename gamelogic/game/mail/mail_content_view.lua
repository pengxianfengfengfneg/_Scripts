local MailContentView = Class(game.BaseView)

function MailContentView:_init(ctrl)
    self._package_name = "ui_mail"
    self._com_name = "mail_content_view"
    self.ctrl = ctrl
    self._show_money = true
    self._view_level = game.UIViewLevel.Second
end

function MailContentView:OpenViewCallBack(mail_info)
    self.mail_info = mail_info
    self.goods_list = mail_info.goods.list
    self:Init(mail_info)
end

function MailContentView:Init(mail_info)
    self:GetFullBgTemplate("common_bg"):SetTitleName(config.func[game.OpenFuncId.Mail_Main].name)
    self._layout_objs["txt_mail_title"]:SetText(mail_info.title)
    self._layout_objs["txt_content"]:SetText(mail_info.content)
    self:SetTimeText(mail_info.time)

    self._layout_objs["btn_get_attach"]:AddClickCallBack(function()
        self:OnGetAttachmentClick()
    end)

    self:InitAttachList()
    self:InitController(mail_info)
    self:BindEvent(game.MailEvent.GetAttach, function(id)
        self:OnGetAttachEvent(id)
    end)
end

function MailContentView:SetTimeText(mail_time)
    local time = os.date("%Y.%m.%d   %H:%M", mail_time)
    self._layout_objs["txt_mail_time"]:SetText(time)
end

function MailContentView:InitAttachList()
    local attach_list = self:CreateList("list_attach", "game/bag/item/goods_item", true)
    attach_list:SetRefreshItemFunc(function(item, idx)
        local goods = self.goods_list[idx].goods
        item:SetItemInfo({ id = goods.id, num = goods.num, bind = goods.bind })
        item:SetShowTipsEnable(true)
    end)
    attach_list:SetItemNum(table.nums(self.goods_list))
end

function MailContentView:InitController(mail_info)
    if mail_info.state >= 4 then
        self:SetAttachController(1)
    elseif mail_info.state == 0 or mail_info.state == 1 then
        self:SetAttachController(2)
    else
        self:SetAttachController(0)
    end
end

function MailContentView:SetAttachController(index)
    self:GetRoot():GetController("ctrl_get_attach"):SetSelectedIndexEx(index)
end

function MailContentView:OnGetAttachmentClick()
    self.ctrl:SendMailGetAttach(self.mail_info.id)
end

function MailContentView:OnGetAttachEvent(id)
    if id == self.mail_info.id then
        self:SetAttachController(1)
    end
end

return MailContentView
