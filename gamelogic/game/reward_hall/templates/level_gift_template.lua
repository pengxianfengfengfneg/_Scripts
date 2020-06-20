local LevelGiftTemplate = Class(game.UITemplate)

function LevelGiftTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "level_gift_template"
    self.ctrl = game.RewardHallCtrl.instance
end

function LevelGiftTemplate:OpenViewCallBack()
    self:BindEvent(game.RewardHallEvent.UpdateLevelGift, function()
        self:UpdateList()
    end)
    self.list = self:CreateList("list", "game/reward_hall/item/level_gift_item")
    self.ctrl:SendLevelGiftInfo()
end

function LevelGiftTemplate:UpdateList()
    local info = game.RewardHallCtrl.instance:GetLevelGiftData()
    if info == nil then
        return
    end
    local get_state = {}
    for _, v in pairs(info.states) do
        get_state[v.lv] = v
    end
    local show_lv_cfg = {}
    for _, v in ipairs(config.level_gift) do
        if get_state[v.level] and get_state[v.level].state ~= 2 then
            table.insert(show_lv_cfg, v)
        end
    end
    self.list:SetRefreshItemFunc(function(item, idx)
        local item_info = show_lv_cfg[idx]
        item:SetItemInfo(item_info)
        item:SetState(get_state[item_info.level])
        item:SetBG(idx % 2 == 1)
    end)
    self.list:SetItemNum(#show_lv_cfg)
end

return LevelGiftTemplate