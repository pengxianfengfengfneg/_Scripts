local GuildEventView = Class(game.BaseView)

function GuildEventView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_event_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildEventView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self.ctrl:SendGuildLogs()
end

function GuildEventView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateLogsList, handler(self, self.UpdateEventList)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildEventView:Init()  
    self.list_event = self:CreateList("list_event", "game/guild/item/guild_event_item")
    self.list_event:SetRefreshItemFunc(function(item, idx)
        local item_info = self.event_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)
end

function GuildEventView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2331])
end

function GuildEventView:UpdateEventList(event_list_data)
    event_list_data = event_list_data or {}
    local sort_list = game.Utils.Sort(event_list_data, function(m, n)
        local v1, v2 = m.v, n.v
        return v1.time > v2.time
    end)
    self.event_list_data = sort_list
    self.list_event:SetItemNum(#event_list_data)
end

return GuildEventView
