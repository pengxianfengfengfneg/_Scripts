local GuildWelfareTemplate = Class(game.UITemplate)


function GuildWelfareTemplate:_init(view)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance   
end

function GuildWelfareTemplate:OpenViewCallBack()
    self:Init()
end

function GuildWelfareTemplate:Init()
    self.list_welfare = self:CreateList("list_welfare", "game/guild/item/guild_welfare_item")
    self.list_welfare:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.guild_welfare_data[idx], idx)
    end)
    
    self.guild_welfare_data = {}
    for k, v in pairs(config.guild_welfare) do
        table.insert(self.guild_welfare_data, v)
    end
    table.sort(self.guild_welfare_data, function(m, n)
        return m.sort < n.sort
    end)
    self.list_welfare:SetItemNum(#self.guild_welfare_data)
end

return GuildWelfareTemplate