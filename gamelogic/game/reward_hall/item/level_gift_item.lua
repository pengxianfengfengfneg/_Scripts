local LevelGiftItem = Class(game.UITemplate)

function LevelGiftItem:OpenViewCallBack()
    self._layout_objs.btn:AddClickCallBack(function()
        game.RewardHallCtrl.instance:SendLevelGiftGet(self.info.level)
    end)
end

function LevelGiftItem:SetItemInfo(info)
    self.info = info
    self._layout_objs.text:SetText(info.level .. config.words[3036])
    local drop_info = config.drop[info.reward].client_goods_list
    local list = self:CreateList("list", "game/bag/item/goods_item")
    list:SetRefreshItemFunc(function(item, idx)
        local info = drop_info[idx]
        item:SetItemInfo({ id = info[1], num = info[2] })
        item:SetShowTipsEnable(true)
    end)
    list:SetItemNum(#drop_info)
end

function LevelGiftItem:SetState(val)
    if val then
        self.state = val.state
    else
        self.state = 0
    end
    self._layout_objs.btn:SetGray(self.state == 0)
    self._layout_objs.btn:SetTouchEnable(self.state == 1)
end

function LevelGiftItem:SetBG(val)
    if val then
        self._layout_objs.bg:SetSprite("ui_common", "009_1")
    else
        self._layout_objs.bg:SetSprite("ui_common", "009_2")
    end
end

return LevelGiftItem