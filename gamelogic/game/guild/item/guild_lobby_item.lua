local GuildLobbyItem = Class(game.UITemplate)

function GuildLobbyItem:_init(ctrl)
    self.ctrl = game.GuildCtrl.instance
end

function GuildLobbyItem:_delete()

end

function GuildLobbyItem:OpenViewCallBack()
    self:Init()
end

function GuildLobbyItem:CloseViewCallBack()
end

function GuildLobbyItem:Init()
    self.txt_index = self._layout_objs["txt_index"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_level = self._layout_objs["txt_level"]
    self.txt_chief = self._layout_objs["txt_chief"]
    self.txt_num = self._layout_objs["txt_num"]

    self.img_bg = self._layout_objs.img_bg
    self.img_bg2 = self._layout_objs.img_bg2

    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event(self.item_info, self.idx)
        end
    end)
end

function GuildLobbyItem:SetItemInfo(item_info, idx)
    self.item_info = item_info
    self.idx = idx

    self.txt_index:SetText(item_info.num)
    self.txt_name:SetText(item_info.name)
    self.txt_level:SetText(item_info.level)
    self.txt_chief:SetText(item_info.chief_name)
    self.txt_num:SetText(string.format("%d/%d", item_info.mem_num, item_info.max_num))

    self.img_bg:SetVisible(idx % 2 == 1)
    self.img_bg2:SetVisible(idx % 2 == 0)
end

function GuildLobbyItem:AddClickEvent(event)
    self.click_event = event
end

return GuildLobbyItem