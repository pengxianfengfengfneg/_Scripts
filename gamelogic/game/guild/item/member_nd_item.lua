local MemberNdItem = Class(game.UITemplate)

local ColorIndex = {
    Brown = 0,
    Gray = 1,
}

function MemberNdItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function MemberNdItem:OpenViewCallBack()
    self:Init()
end

function MemberNdItem:Init()
   self.txt_name = self._layout_objs["txt_name"] 
   self.txt_cont = self._layout_objs["txt_cont"] 
   self.txt_week_funds = self._layout_objs["txt_week_funds"] 
   self.txt_week_military = self._layout_objs["txt_week_military"] 
   self.txt_military = self._layout_objs["txt_military"] 

   self.img_bg = self._layout_objs["img_bg"]
   self.img_bg2 = self._layout_objs["img_bg2"]
   self.ctrl_color = self:GetRoot():GetController("ctrl_color")

   self:GetRoot():AddClickCallBack(handler(self, self.OnClick))
end

function MemberNdItem:SetItemInfo(item_info, idx)
    self.item_info = item_info
    
    self.txt_name:SetText(item_info.name)
    self.txt_cont:SetText(item_info.contri)
    self.txt_week_funds:SetText(item_info.weekly_funds)

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)

    self.ctrl_color:SetSelectedIndexEx(item_info.offline == 0 and ColorIndex.Brown or ColorIndex.Gray)
end

function MemberNdItem:OnClick()
    if self.item_info.id ~= game.Scene.instance:GetMainRoleID() then
        self.ctrl:OpenGuildMemberOperateView(self.item_info)
    end
end

return MemberNdItem