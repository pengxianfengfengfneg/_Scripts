local GuildMemberItem = Class(game.UITemplate)

function GuildMemberItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildMemberItem:_delete()
end

function GuildMemberItem:OpenViewCallBack()
    self:Init()
end

function GuildMemberItem:CloseViewCallBack()
end

function GuildMemberItem:Init()
    self.label_contribute = self._layout_objs["label_contribute"]
    self.label_fight = self._layout_objs["label_fight"]

    self.txt_pos_name = self._layout_objs["txt_pos_name"]
    self.txt_member_name = self._layout_objs["txt_member_name"]
    self.txt_offline = self._layout_objs["txt_offline"]
    self.txt_contribute = self._layout_objs["txt_contribute"]
    self.txt_fight = self._layout_objs["txt_fight"]
    
    self.img_avatar =  self._layout_objs["img_avatar"]
    self.btn_operate = self._layout_objs["btn_operate"]
    
    self.label_contribute:SetText(config.words[2344])
    self.label_fight:SetText(config.words[2345])

    if self.btn_operate then
        self.btn_operate:SetText(config.words[2346])
        self.btn_operate:AddClickCallBack(handler(self, self.Operate))
    end
end

function GuildMemberItem:SetItemInfo(item_info)
    self.txt_pos_name:SetText(string.format(config.words[2343], config.guild_pos[1][item_info.pos].name))
    self.txt_member_name:SetText(item_info.name)
    self.txt_contribute:SetText(item_info.contri)
    self.txt_fight:SetText(item_info.fight)
    -- self.img_avatar:SetSprite("ui_main", item_info.avatar)
    self:SetOfflineText(item_info.offline)
    self.member_info = item_info
end

function GuildMemberItem:SetOfflineText(offline)
    local text = offline == 0 and config.words[2347] or config.words[2348]
    self.txt_offline:SetText(text)
end

function GuildMemberItem:Operate()
    self.ctrl:OpenGuildMemberOperateView(self.member_info)
end

return GuildMemberItem