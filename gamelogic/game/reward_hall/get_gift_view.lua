local GetGiftView = Class(game.BaseView)

function GetGiftView:_init(ctrl)
    self._package_name = "ui_reward_hall"
    self._com_name = "get_gift_view"
    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
end

function GetGiftView:OpenViewCallBack(info)
    self.info = info
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3053])
    local show_rewards = {}
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    for _, v in ipairs(info.reward) do
        if role_lv >= v[2] then
            table.insert(show_rewards, v)
        end
    end
    local list = self:CreateList("list", "game/reward_hall/item/get_gift_item")
    list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(show_rewards[idx])
        item:SetGrade(info.grade)
    end)
    list:SetItemNum(#show_rewards)
end


return GetGiftView