local RewardRankItem = Class(game.UITemplate)

function RewardRankItem:_init(ctrl)
    self.ctrl = game.CareerBattleCtrl.instance
end

function RewardRankItem:_delete()

end

function RewardRankItem:OpenViewCallBack()
    self.txt_times = self._layout_objs["txt_times"]

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")

    self:GetRoot():AddClickCallBack(function()
        if self.state == 0 then
            self.ctrl:SendCareerBattleReward(self.item_info.times)
        end
    end)

    self:SetStateCtrl(0)
end

function RewardRankItem:CloseViewCallBack()
    
end

function RewardRankItem:SetItemInfo(item_info)
    self.item_info = item_info
    self.txt_times:SetText(item_info.times)

    local drop_id = item_info.reward
    local goods_info = config.drop[drop_id].client_goods_list[1]
    self.goods_item:SetItemInfo({id = goods_info[1], num = goods_info[2], x=115, y=20})
    self.goods_item:SetShowTipsEnable(true)

    self:SetRedPoint(item_info.is_red)
    self:SetStateCtrl(item_info.state)
end

function RewardRankItem:GetTimes()
    if self.item_info then
        return self.item_info.times
    end
end

function RewardRankItem:SetStateCtrl(index)
    self.state = index
    self.ctrl_state:SetSelectedIndexEx(index)
end

function RewardRankItem:SetRedPoint(is_red)
    game_help.SetRedPoint(self:GetRoot(), is_red)
end

return RewardRankItem