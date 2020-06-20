local LuckyMoneyRankView = Class(game.BaseView)

local min_rank_num = 5

function LuckyMoneyRankView:_init(ctrl)
    self._package_name = "ui_lucky_money"
    self._com_name = "lucky_money_rank_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function LuckyMoneyRankView:OpenViewCallBack(info)
    self:Init(info)
    self:InitBg()
end

function LuckyMoneyRankView:RegisterAllEvents()
    local events = {
        {game.GuildEvent.OnGuildMoneyChange, handler(self, self.OnGuildMoneyChange)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function LuckyMoneyRankView:Init(info)
    self.info = info

    self.lucky_money_com = self:GetTemplate("game/lucky_money/lucky_money_com", "lucky_money_com")
    self.lucky_money_com:RefreshGuildLuckyMoney(info)
    self.lucky_money_com:SetDetailVisible(false)

    self.list_rank = self:CreateList("list_rank", "game/lucky_money/item/lucky_money_rank_item")
    self.list_rank:SetRefreshItemFunc(function(item, idx)
        local item_info = self.rank_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)

    self:UpdateRankList(info.list)
end

function LuckyMoneyRankView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5959])
end

function LuckyMoneyRankView:UpdateRankList(rank_list_data)
    self.rank_list_data = rank_list_data or game.EmptyTable

    table.sort(self.rank_list_data, function(m, n)
        return m.rank < n.rank
    end)
    self.list_rank:SetItemNum(math.max(min_rank_num, #self.rank_list_data))
end

function LuckyMoneyRankView:OnGuildMoneyChange(info)
    if info.id == self.info.id then
        self.info = info
        self:UpdateRankList(info.list)
        
        self.lucky_money_com:RefreshGuildLuckyMoney(info)
    end
end

return LuckyMoneyRankView
