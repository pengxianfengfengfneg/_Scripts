local BattleHostileTemplate = Class(game.UITemplate)

local max_times = config.carry_common.rob_times

function BattleHostileTemplate:_init(view)
    self.parent = view
    self.ctrl = game.GuildCtrl.instance
end

function BattleHostileTemplate:OpenViewCallBack()
    self:Init()
    self:RegisterAllEvents()
    self.ctrl:SendGuildHostileList()
end

function BattleHostileTemplate:RegisterAllEvents()
    local events = {
        {game.GuildEvent.OnGuildHostileList, handler(self, self.UpdateHostileList)},
        {game.GuildEvent.YunbiaoInfoChange, handler(self, self.SetTimesText)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function BattleHostileTemplate:Init()
    self.list_hostile = self:CreateList("list_hostile", "game/guild/item/battle_hostile_item")
    self.list_hostile:SetRefreshItemFunc(function(item, idx)
        local item_info = self.hostile_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)

    self.txt_times = self._layout_objs.txt_times

    self.btn_add = self._layout_objs.btn_add
    self.btn_add:AddClickCallBack(function()
        self.ctrl:OpenGuildLobbyView(3)
    end)

    self:SetTimesText()
end

function BattleHostileTemplate:UpdateHostileList()
    self.hostile_list_data = self.ctrl:GetHostileList()
    table.sort(self.hostile_list_data, function(m, n)
        return m.num < n.num
    end)
    self.list_hostile:SetItemNum(#self.hostile_list_data)
end

function BattleHostileTemplate:SetTimesText()
    self.txt_times:SetText(string.format(config.words[4788], self.ctrl:GetCarryLeftRobTimes(), max_times))
end

return BattleHostileTemplate