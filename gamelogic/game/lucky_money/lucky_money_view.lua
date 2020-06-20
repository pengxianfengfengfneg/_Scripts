local LuckyMoneyView = Class(game.BaseView)

local config_guild_lucky_money = config.guild_lucky_money
local config_guild_lucky_money_info = config.guild_lucky_money_info

function LuckyMoneyView:_init(ctrl)
    self._package_name = "ui_lucky_money"
    self._com_name = "lucky_money_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function LuckyMoneyView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
    self:Refresh()
    game.MainUICtrl.instance:SendGetCommonlyKeyValue(game.CommonlyKey.DailyGetLuckyMoneyTimes)
end

function LuckyMoneyView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.UpdateGuildLuckyMoneyList, handler(self, self.Refresh)},
        {game.SceneEvent.CommonlyValueRespon, handler(self, self.OnCommonlyKeyValue)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function LuckyMoneyView:OnCommonlyKeyValue(data)
    if data.key == game.CommonlyKey.DailyGetLuckyMoneyTimes then
        local times = config_guild_lucky_money_info.max_times - data.value
        self.txt_num:SetText(string.format(config.words[5958], times))
    end
end

function LuckyMoneyView:Init()
    self.list_lucky_money = self:CreateList("list_lucky_money", "game/lucky_money/item/lucky_money_item")
    self.list_lucky_money:SetRefreshItemFunc(function(item, idx)
        local data = self.lucky_money_data[idx].info
        local cfg = config_guild_lucky_money[data.cid]

        local item_info = {
            name = data.sender,
            desc = cfg.name,
        }
        for k, v in pairs(data) do
            item_info[k] = v
        end

        item:SetItemInfo(item_info)

        local is_receive = game.GuildCtrl.instance:IsReceiveLuckyMoney(data)
        local can_receive = #data.list < cfg.times
        item:SetEnable(not is_receive and can_receive)

        item:SetReceiveState(game.GuildCtrl.instance:GetReceiveState(data))
        item:AddClickEvent(handler(self, self.OnItemClick))
    end)

    self.txt_num = self._layout_objs.txt_num
    self.ctrl_index = self:GetRoot():GetController("ctrl_index")
end

function LuckyMoneyView:UpdateList(lucky_money_data)
    self.lucky_money_data = lucky_money_data
    self.list_lucky_money:SetItemNum(#self.lucky_money_data)
    self.ctrl_index:SetSelectedIndexEx((#self.lucky_money_data>0) and 0 or 1)
end

function LuckyMoneyView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5957])
end

function LuckyMoneyView:OnItemClick(item_info)
    if item_info then
        self.ctrl:OpenLuckyMoneyOpenView(item_info)
    end
end

function LuckyMoneyView:Refresh()
    local guild_ctrl = game.GuildCtrl.instance
    local lucky_money_data = game.GuildCtrl.instance:GetLuckyMoney()

    table.sort(lucky_money_data, function(m, n)
        local state1 = guild_ctrl:GetReceiveState(m.info)
        local state2 = guild_ctrl:GetReceiveState(n.info)

        state1 = math.min(2, state1)
        state2 = math.min(2, state2)

        if state1 ~= state2 then
            return state1 < state2
        else
            return m.info.expire_time > n.info.expire_time
        end
    end)

    self:UpdateList(lucky_money_data)
end

return LuckyMoneyView
