local GuildLogsItem = Class(game.UITemplate)

function GuildLogsItem:_init(ctrl)
    self.ctrl = ctrl
end

function GuildLogsItem:_delete()

end

function GuildLogsItem:OpenViewCallBack()
    self:Init()
end

function GuildLogsItem:CloseViewCallBack()
end

function GuildLogsItem:Init()
    self.txt_date = self._layout_objs["txt_date"]
    self.txt_content = self._layout_objs["txt_content"]
    self.img_bg = self._layout_objs["img_bg"]
end

function GuildLogsItem:SetItemInfo(item_info, idx)
    self:SetDateText(item_info.time)
    self:SetContentText(item_info.log)
    self:SetBgSprite(idx)
end

function GuildLogsItem:SetDateText(time)
    local text = ""
    if time then
        text = os.date("%y-%m-%d", time)
    end
    self.txt_date:SetText(text)
end

function GuildLogsItem:SetContentText(content)
    self.txt_content:SetText(content)
end

function GuildLogsItem:SetBgSprite(idx)
    self.img_bg:SetVisible(idx % 2 == 1)
end

return GuildLogsItem