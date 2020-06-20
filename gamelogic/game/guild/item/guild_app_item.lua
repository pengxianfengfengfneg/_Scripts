local GuildAppItem = Class(game.UITemplate)

function GuildAppItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildAppItem:_delete()
end

function GuildAppItem:OpenViewCallBack()
    self:Init()
end

function GuildAppItem:CloseViewCallBack()
end

function GuildAppItem:Init()
    self.head_icon = self:GetIconTemplate("head_icon")

    self.label_fight = self._layout_objs["label_fight"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_fight = self._layout_objs["txt_fight"]

    self.btn_approve = self._layout_objs["btn_approve"]
    self.btn_refuse = self._layout_objs["btn_refuse"]

    self.label_fight:SetText(config.words[2345])
    self.btn_approve:AddClickCallBack(handler(self, self.ApproveApp))
    self.btn_refuse:AddClickCallBack(handler(self, self.RefuselApp))
end

function GuildAppItem:SetItemInfo(item_info)
    self.app_info = item_info
    self.txt_name:SetText(item_info.name)
    self.txt_fight:SetText(item_info.fight)

    self.head_icon:UpdateData(item_info)
end

function GuildAppItem:ApproveApp()
    self.ctrl:SendGuildHandleReq(1, self.app_info.id)
end

function GuildAppItem:RefuselApp()
    self.ctrl:SendGuildHandleReq(2, self.app_info.id)
end

return GuildAppItem