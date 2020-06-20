local GiftItem = Class(game.UITemplate)

function GiftItem:_init()
    self.ctrl = game.RechargeCtrl.instance 
end

function GiftItem:OpenViewCallBack()
    self.txt_name = self._layout_objs.txt_name
    self.img_money = self._layout_objs.img_money

    self.btn_get = self._layout_objs.btn_get
    self.btn_get:SetText(config.words[2803])
    self.btn_get:AddClickCallBack(function()
        if self.get_event then
            self.get_event()
        end
    end)

    self.bar_progress = self._layout_objs.bar_progress
    self.txt_progress = self.bar_progress:GetChild("title")

    self.list_reward = self:CreateList("list_reward", "game/bag/item/goods_item")
    self.list_reward:SetRefreshItemFunc(function(item, idx)
        local item_info = self.reward_list_data[idx]
        item:SetItemInfo({id = item_info[1], num = item_info[2]})
        item:SetShowTipsEnable(true)
    end)

    self._layout_objs.img_money:SetSprite("ui_common", config.money_type[game.MoneyType.Gold].icon)

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
end

function GiftItem:SetItemInfo(item_info)
    self.item_info = item_info
    self.txt_name:SetText(item_info.name)

    self:UpdateRewardList()
end

function GiftItem:SetBarProgress(cur, total)
    self.bar_progress:SetProgressValue(cur / total * 100)
    self.txt_progress:SetText(string.format("%d/%d", cur, total))
end

function GiftItem:SetGetState(state)
    local word = (state == 0 or state == 2) and config.words[5710] or config.words[5711]
    self.btn_get:SetEnable(state == 0 or state == 2)
    game_help.SetRedPoint(self.btn_get, state==2)
    
    self.ctrl_state:SetSelectedIndexEx(state)
end

function GiftItem:AddGetEvent(get_event)
    self.get_event = get_event
end

function GiftItem:UpdateRewardList()
    local drop_id = self.item_info.reward
    self.reward_list_data = config.drop[drop_id].client_goods_list
    self.list_reward:SetItemNum(#self.reward_list_data)
end

return GiftItem
