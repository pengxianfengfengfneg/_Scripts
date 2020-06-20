local GuildLogsView = Class(game.BaseView)

function GuildLogsView:_init(ctrl)
    self._package_name = "ui_guild"
    self._com_name = "guild_logs_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function GuildLogsView:_delete()
end

function GuildLogsView:OpenViewCallBack()
    self:RegisterAllEvents()
    self:Init()
    self:InitBg()
end

function GuildLogsView:CloseViewCallBack()
    self.list_logs:DeleteMe()
    self.list_logs = nil
end

function GuildLogsView:Init()  
    self.list_logs = game.UIList.New(self._layout_objs["list_logs"]) 
    self.list_logs:SetCreateItemFunc(function(obj)
        local item = require("game/guild/item/guild_logs_item").New(self.ctrl)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)
    self.list_logs:SetRefreshItemFunc(function(item, idx)
        local item_info = self.logs_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)
    self.list_logs:SetVirtual(true)
    self.ctrl:SendGuildLogs()
end

function GuildLogsView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[2331])
end

function GuildLogsView:UpdateLogsList(logs_list_data)
    logs_list_data = logs_list_data or {}
    local sort_list = game.Utils.Sort(logs_list_data, function(m, n)
        local v1, v2 = m.v, n.v
        return v1.time > v2.time
    end)
    self.logs_list_data = sort_list
    self.list_logs:SetItemNum(#logs_list_data)
end

function GuildLogsView:OnEmptyClick()
    self:Close()
end

function GuildLogsView:RegisterAllEvents()
    local events = {
        [game.GuildEvent.UpdateLogsList] = function(logs)
            self:UpdateLogsList(logs)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return GuildLogsView
