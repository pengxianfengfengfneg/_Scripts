local CareerBattleRewardRankView = Class(game.BaseView)

function CareerBattleRewardRankView:_init(ctrl)
    self._package_name = "ui_career_battle"
    self._com_name = "reward_rank_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function CareerBattleRewardRankView:_delete()
    
end

function CareerBattleRewardRankView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitRewardList()
    self:RegisterAllEvents()
    self.ctrl:SendCareerBattleLoungeInfo()
end

function CareerBattleRewardRankView:CloseViewCallBack()

end

function CareerBattleRewardRankView:Init()
    self.txt_battle_times = self._layout_objs["txt_battle_times"]
    self.txt_leave_times = self._layout_objs["txt_leave_times"]
    self.txt_last_win_times = self._layout_objs["txt_last_win_times"]
    self.txt_score = self._layout_objs["txt_score"]

    self._layout_objs["label_battle_times"]:SetText(config.words[4812])
    self._layout_objs["label_leave_times"]:SetText(config.words[4813])
    self._layout_objs["label_last_win_times"]:SetText(config.words[4814])
    self._layout_objs["label_score"]:SetText(config.words[4815])
    self._layout_objs["label_info"]:SetText(config.words[4816])

    self.btn_battle_rank = self._layout_objs["btn_battle_rank"]
    self.btn_battle_rank:SetText(config.words[4806])
    self.btn_battle_rank:AddClickCallBack(function()
        self.ctrl:OpenFightRankView(game.RoleCtrl.instance:GetCareer())
    end)
end

function CareerBattleRewardRankView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4811]):HideBtnBack()
end

function CareerBattleRewardRankView:InitRewardList()
    self.list_reward = self:CreateList("list_reward", "game/career_battle/item/reward_rank_item")
    self.list_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.reward_list_data[idx]
        item_info.state = self:GetRewardState(item_info.times)
        item_info.is_red = (item_info.state==0) and (self.lounge_info.battle_times>=item_info.times)
        item:SetItemInfo(item_info)
    end)
end

function CareerBattleRewardRankView:UpdateRewardList()
    local grade = self.ctrl:GetGrade()
    self.reward_list_data = game.Utils.SortByKey(config.career_battle_times[grade])
    self.list_reward:SetItemNum(#self.reward_list_data)
end

function CareerBattleRewardRankView:GetRewardState(times)
    local reward_list = self.lounge_info.reward_list
    for _, v in pairs(reward_list or {}) do
        if v.times == times then
            return 1
        end
    end
    return 0
end

function CareerBattleRewardRankView:OnCareerBattleReward(times)
    self.list_reward:Foreach(function(item)
        if item:GetTimes() == times then
            item:SetStateCtrl(1)
            item:SetRedPoint(false)
        end
    end)
end

function CareerBattleRewardRankView:Refresh()
    self.txt_battle_times:SetText(self.lounge_info.battle_times)
    self.txt_leave_times:SetText(self.lounge_info.leave_times)
    self.txt_last_win_times:SetText(self.lounge_info.last_win_times)
    self.txt_score:SetText(self.lounge_info.score)

    self:UpdateRewardList()
end

function CareerBattleRewardRankView:RegisterAllEvents()
    local events = {
        [game.CareerBattleEvent.UpdateLoungeInfo] = function(lounge_info)
            self.lounge_info = lounge_info
            self:Refresh()
        end,
        [game.CareerBattleEvent.CareerBattleReward] = function(times)
            self:OnCareerBattleReward(times)
        end,
    }
    for k, v in pairs(events) do
        self:BindEvent(k, v)
    end
end

return CareerBattleRewardRankView
