local GuildInfoItem = Class(game.UITemplate)

function GuildInfoItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildInfoItem:OpenViewCallBack()
    self:Init()
end

function GuildInfoItem:CloseViewCallBack()

end

function GuildInfoItem:Init()
    self.txt_name = self._layout_objs.txt_name
    self.txt_level = self._layout_objs.txt_level
    self.txt_pos = self._layout_objs.txt_pos
    self.txt_fight = self._layout_objs.txt_fight

    self.img_bg = self._layout_objs.img_bg
end

function GuildInfoItem:SetItemInfo(item_info, index)
    self.txt_name:SetText(item_info.name)
    self.txt_level:SetText(item_info.level)
    self.txt_pos:SetText(config.guild_pos[1][item_info.pos].name)
    self.txt_fight:SetText(item_info.fight)

    self.img_bg:SetVisible(index%2==1)
end

return GuildInfoItem