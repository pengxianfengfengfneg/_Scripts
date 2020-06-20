local GuildMemberInfoItem = Class(game.UITemplate)

function GuildMemberInfoItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildMemberInfoItem:_delete()
end

function GuildMemberInfoItem:OpenViewCallBack()
    self:Init()
end

function GuildMemberInfoItem:CloseViewCallBack()
end

function GuildMemberInfoItem:Init()
   self.txt_name = self._layout_objs["txt_name"] 
   self.txt_pos = self._layout_objs["txt_pos"] 
   self.txt_fight = self._layout_objs["txt_fight"] 
   self.txt_week_live = self._layout_objs["txt_week_live"] 
   self.txt_week_funds = self._layout_objs["txt_week_funds"] 
   self.txt_week_cond = self._layout_objs["txt_week_cond"] 

   self.img_bg = self._layout_objs["img_006"]

   self.ctrl_state = self:GetRoot():GetController("ctrl_state")

   self:GetRoot():AddClickCallBack(handler(self, self.OnClick))
end

function GuildMemberInfoItem:SetItemInfo(item_info, idx)
    self.item_info = item_info
    self.txt_name:SetText(item_info.name)
    self.txt_pos:SetText(config.guild_pos[1][item_info.pos].name)
    self.txt_fight:SetText(item_info.fight)
    self.txt_week_live:SetText(item_info.weekly_live)
    self.txt_week_funds:SetText(item_info.weekly_funds)
    self.txt_week_cond:SetText(item_info.weekly_cont)

    self.img_bg:SetVisible(idx % 2 == 0)

    self.ctrl_state:SetSelectedIndexEx(item_info.offline == 0 and 0 or 1)
end

function GuildMemberInfoItem:OnClick()
    if self.item_info.id ~= game.Scene.instance:GetMainRoleID() then
        self.ctrl:OpenGuildMemberOperateView(self.item_info)
    end
end

return GuildMemberInfoItem