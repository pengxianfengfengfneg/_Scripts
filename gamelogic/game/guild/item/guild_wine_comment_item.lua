local GuildWineCommentItem = Class(game.UITemplate)

function GuildWineCommentItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildWineCommentItem:_delete()

end

function GuildWineCommentItem:OpenViewCallBack()
    self:Init()
end

function GuildWineCommentItem:CloseViewCallBack()
    
end

function GuildWineCommentItem:Init()
    self.head_icon = self:GetIconTemplate("head_icon")
    self.img_lucky = self._layout_objs["img_lucky"]

    self.txt_like_value = self._layout_objs["txt_like_value"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_dice_num = self._layout_objs["txt_dice_num"]
    self.txt_gift = self._layout_objs["txt_gift"]

    self.btn_like = self._layout_objs["btn_like"]
    self.btn_like:AddClickCallBack(function()
        if self.item_info then
            self.ctrl:SendGuildWineActGiveComment(self.item_info.role_id, 1)
        end
    end)
    self.btn_dislike = self._layout_objs["btn_dislike"]
    self.btn_dislike:AddClickCallBack(function()
        if self.item_info then
            self.ctrl:SendGuildWineActGiveComment(self.item_info.role_id, 2)
        end
    end)
end

function GuildWineCommentItem:SetItemInfo(item_info)
    self.item_info = item_info

    self.txt_like_value:SetText(item_info.like_value)
    self.txt_name:SetText(item_info.name)
    self.txt_dice_num:SetText(string.format(config.words[4749], item_info.dice_num))

    if item_info.type == 1 then
        self.img_lucky:SetSprite("ui_guild", "xjl_05")
        self.txt_gift:SetText(config.words[4750])
    else
        self.img_lucky:SetSprite("ui_guild", "xjl_06")
        self.txt_gift:SetText(config.words[4751])
    end

    self.head_icon:UpdateData(item_info)
end

function GuildWineCommentItem:SetLikeValue(value)
    self.txt_like_value:SetText(value)
end

function GuildWineCommentItem:GetRoleId()
    if self.item_info then
        return self.item_info.role_id
    end
end

return GuildWineCommentItem