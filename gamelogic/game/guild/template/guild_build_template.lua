local GuildBuildTemplate = Class(game.UITemplate)

function GuildBuildTemplate:_init(view)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
end

function GuildBuildTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
end

function GuildBuildTemplate:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UdpateBuildInfo, handler(self, self.UpdateBuildList)},
        {game.GuildEvent.UpdateGuildInfo, handler(self, self.UpdateGuildInfo)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function GuildBuildTemplate:Init()
    self.txt_funds = self._layout_objs.txt_funds

    self.list_build = self:CreateList("list_build", "game/guild/item/guild_build_item")
    self.list_build:SetRefreshItemFunc(function(item, idx)
        local item_info = self.build_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)
end

function GuildBuildTemplate:UpdateBuildList()
    local build_info = self.ctrl:GetBuildInfo()

    self.build_list_data = {}
    for k, v in ipairs(build_info) do
        table.insert(self.build_list_data, v)
    end
    table.sort(self.build_list_data, function(m, n)
        return m.id < n.id
    end)

    self.list_build:SetItemNum(#self.build_list_data)
end

function GuildBuildTemplate:UpdateGuildInfo()
    self:UpdateBuildList()

    self.txt_funds:SetText(self.ctrl:GetGuildInfo().funds)
end

return GuildBuildTemplate