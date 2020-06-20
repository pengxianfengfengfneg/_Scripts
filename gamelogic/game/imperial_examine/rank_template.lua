local RankTemplate = Class(game.UITemplate)

local min_item_num = 10

function RankTemplate:_init()
    self.ctrl = game.DailyTaskCtrl.instance   
end

function RankTemplate:OpenViewCallBack()
    self:InitRankList()
    self:RegisterAllEvents()
end

function RankTemplate:InitRankList()
    self.list_rank = self:CreateList("list_rank", "game/daily_task/item/examine_rank_item")
    self.list_rank:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.list_rank_data[idx], idx)
    end)
    self.list_rank_data = {}
    self.list_rank:SetItemNum(min_item_num)
end

function RankTemplate:UpdateRankList(list_rank_data)
    self.list_rank_data = list_rank_data or {}
    self.list_rank:SetItemNum(math.max(#self.list_rank_data, min_item_num))
end

function RankTemplate:OnActived()
    self.ctrl:SendExamineRank()
end

function RankTemplate:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.UpdateExamineRankInfo] = function(data)
            self:UpdateRankList(data)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return RankTemplate