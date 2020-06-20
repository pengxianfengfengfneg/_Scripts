local BattleWarTemplate = Class(game.UITemplate)

function BattleWarTemplate:_init(view)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
end

function BattleWarTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self.ctrl:SendGuildDeclareList()
end

function BattleWarTemplate:RegisterAllEvents()
    local events = {
        {game.GuildEvent.OnGuildDeclareList, handler(self, self.UpdateWarList)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function BattleWarTemplate:Init()
    self.list_war = self:CreateList("list_guild", "game/guild/item/battle_war_item")
    self.list_war:SetRefreshItemFunc(function(item, idx)
        local item_info = self.war_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)

    self.btn_war = self._layout_objs.btn_war
    self.btn_war:AddClickCallBack(function()
        self.ctrl:OpenGuildLobbyView(2)
    end)

    self.btn_exploit = self._layout_objs.btn_exploit
    self.btn_exploit:AddClickCallBack(function()

    end)
end

function BattleWarTemplate:UpdateWarList(data)
    self.war_list_data = {}
    for k, v in ipairs(data.declare) do
        table.insert(self.war_list_data, v)
    end
    for k, v in ipairs(data.back) do
        table.insert(self.war_list_data, v)
    end
    self.list_war:SetItemNum(#self.war_list_data)
end

return BattleWarTemplate