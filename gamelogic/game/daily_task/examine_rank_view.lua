local ExamineRankView = Class(game.BaseView)

function ExamineRankView:_init(ctrl)
    self._package_name = "ui_daily_task"
    self._com_name = "examine_rank_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function ExamineRankView:_delete()
    
end

function ExamineRankView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitRankList()
    self:RegisterAllEvents()
    self.ctrl:SendExamineRank()
end

function ExamineRankView:CloseViewCallBack()
    
end

function ExamineRankView:Init()
    self._layout_objs["txt_rank"]:SetText(config.words[5137])
    self._layout_objs["txt_name"]:SetText(config.words[5138])
end

function ExamineRankView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5128])
end

function ExamineRankView:InitRankList()
    self.list_rank = self:CreateList("list_rank", "game/daily_task/item/examine_rank_item")
    self.list_rank:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.list_rank_data[idx], idx)
    end)
end

function ExamineRankView:UpdateRankList(list_rank_data)
    self.list_rank_data = list_rank_data or {}
    self.list_rank:SetItemNum(#self.list_rank_data)
end

function ExamineRankView:RegisterAllEvents()
    local events = {
        [game.DailyTaskEvent.UpdateExamineRankInfo] = function(data)
            self:UpdateRankList(data)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return ExamineRankView
