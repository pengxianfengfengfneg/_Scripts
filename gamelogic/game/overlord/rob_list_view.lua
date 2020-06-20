local RobListView = Class(game.BaseView)

function RobListView:_init(ctrl)
    self._package_name = "ui_overlord"
    self._com_name = "rob_score_view"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function RobListView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[4604])

    local list = self:CreateList("list", "game/overlord/item/rob_score_item")
    local rank_data = self.ctrl:GetRankData()
    if rank_data then
        local item_list = rank_data.role
        list:SetRefreshItemFunc(function(item, idx)
            local item_data = item_list[idx]
            item:SetItemInfo(item_data)
        end)
        list:SetItemNum(#item_list)
    end
end

function RobListView:OnEmptyClick()
    self:Close()
end

return RobListView
