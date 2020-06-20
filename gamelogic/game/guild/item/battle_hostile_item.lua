local BattleHostileItem = Class(game.UITemplate)

function BattleHostileItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function BattleHostileItem:OpenViewCallBack()
    self:Init()
end

function BattleHostileItem:CloseViewCallBack()

end

function BattleHostileItem:Init()
    self.txt_index = self._layout_objs.txt_index
    self.txt_name = self._layout_objs.txt_name
    self.txt_level = self._layout_objs.txt_level
    self.txt_rob = self._layout_objs.txt_rob

    self.btn_delete = self._layout_objs.btn_delete
    self.btn_delete:AddClickCallBack(function()
        if self.item_info then
            self.ctrl:SendGuildHostileCancel(self.item_info.guild_id)
        end
    end)
        
    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2
end

function BattleHostileItem:SetItemInfo(item_info, idx)
    self.item_info = item_info

    self.txt_index:SetText(item_info.num)
    self.txt_name:SetText(item_info.guild_name)
    self.txt_level:SetText(item_info.guild_lv)
    self.txt_rob:SetText(item_info.rob .. "%")

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)
end

return BattleHostileItem