local CareerBattleFightRankRewardView = Class(game.BaseView)

function CareerBattleFightRankRewardView:_init(ctrl)
    self._package_name = "ui_career_battle"
    self._com_name = "fight_rank_reward_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function CareerBattleFightRankRewardView:_delete()
    
end

function CareerBattleFightRankRewardView:OpenViewCallBack(drop_id)
    self:InitBg()
    self:InitRewardList()
    self:UpdateRewardList(drop_id)
end

function CareerBattleFightRankRewardView:CloseViewCallBack()
    
end

function CareerBattleFightRankRewardView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4833]):HideBtnBack()
end

function CareerBattleFightRankRewardView:InitRewardList()
    self.list_reward = self:CreateList("list_reward", "game/bag/item/goods_item")
    self.list_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.reward_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)
end

function CareerBattleFightRankRewardView:UpdateRewardList(drop_id)
    self.reward_list_data = config.drop[drop_id].client_goods_list
    self.list_reward:SetItemNum(#self.reward_list_data)
end

function CareerBattleFightRankRewardView:OnEmptyClick()
    self:Close()
end

return CareerBattleFightRankRewardView
