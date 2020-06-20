local GuildEventItem = Class(game.UITemplate)

function GuildEventItem:_init(ctrl)
    self.ctrl = ctrl
end

function GuildEventItem:OpenViewCallBack()
    self:Init()
end

function GuildEventItem:Init()
    self.txt_date = self._layout_objs["txt_date"]
    self.txt_content = self._layout_objs["txt_content"]
    self.img_bg = self._layout_objs["img_bg"]
end

function GuildEventItem:SetItemInfo(item_info, idx)
    self:SetContentText(item_info.time, item_info.log)
    self:SetBgSprite(idx)
end

function GuildEventItem:SetContentText(time, content)
    local text = os.date("%y-%m-%d", time) .. "  " .. content
    self.txt_content:SetText(text)
end

function GuildEventItem:SetBgSprite(idx)
    self.img_bg:SetVisible(idx % 2 == 1)
end

return GuildEventItem