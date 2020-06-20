local GuildResearchItem = Class(game.UITemplate)

function GuildResearchItem:_init()
    self.ctrl = game.GuildCtrl.instance
end

function GuildResearchItem:OpenViewCallBack()
    self:Init()
end

function GuildResearchItem:Init()
    self.img_circle = self._layout_objs.img_circle
    self.img_bg = self._layout_objs.img_bg
    self.img_icon = self._layout_objs.img_icon
    self.img_lock = self._layout_objs.img_lock
    self.img_select = self._layout_objs.img_select

    self:GetRoot():AddClickCallBack(function()
        if self.click_event then
            self.click_event(self.item_info, self.idx)
        end
    end)
end

function GuildResearchItem:SetItemInfo(item_info, idx)
    self.item_info = item_info
    self.idx = idx

    local info = config.guild_research_info[item_info.id]
    self.img_icon:SetSprite("ui_guild", info.icon)
    self.img_icon:SetGray(item_info.lv == 0)
end

function GuildResearchItem:SetLock(val)
    self.img_lock:SetVisible(val)
end

function GuildResearchItem:ShowCircle(val)
    self.img_circle:SetVisible(val)
end

function GuildResearchItem:GetItemInfo()
    return self.item_info
end

function GuildResearchItem:AddClickEvent(click_event)
    self.click_event = click_event
end

function GuildResearchItem:SetSelect(val)
    self.img_select:SetVisible(val)
end

return GuildResearchItem