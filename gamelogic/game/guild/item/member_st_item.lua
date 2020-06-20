local MemberStItem = Class(game.UITemplate)

local ColorIndex = {
    Brown = 0,
    Gray = 1,
}

function MemberStItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function MemberStItem:OpenViewCallBack()
    self:Init()
end

function MemberStItem:Init()
   self.txt_name = self._layout_objs["txt_name"] 
   self.txt_pos = self._layout_objs["txt_pos"] 
   self.txt_level = self._layout_objs["txt_level"] 
   self.txt_fight = self._layout_objs["txt_fight"] 
   self.txt_week_live = self._layout_objs["txt_week_live"]

   self.img_bg = self._layout_objs["img_bg"]
   self.img_bg2 = self._layout_objs["img_bg2"]
   self.ctrl_color = self:GetRoot():GetController("ctrl_color")

   self:GetRoot():AddClickCallBack(handler(self, self.OnClick))
end

function MemberStItem:SetItemInfo(item_info, idx)
    self.item_info = item_info

    self.txt_name:SetText(item_info.name)
    self.txt_pos:SetText(config.guild_pos[1][item_info.pos].name)
    self.txt_level:SetText(item_info.level)
    self.txt_fight:SetText(item_info.fight)
    self.txt_week_live:SetText(item_info.weekly_live)

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)

    self.ctrl_color:SetSelectedIndexEx(item_info.offline == 0 and ColorIndex.Brown or ColorIndex.Gray)
end

function MemberStItem:OnClick()
    if self.item_info.id ~= game.Scene.instance:GetMainRoleID() then
        self.ctrl:OpenGuildMemberOperateView(self.item_info)
    end
end

return MemberStItem