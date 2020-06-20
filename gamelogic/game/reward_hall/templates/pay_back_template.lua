local PayBackTemplate = Class(game.UITemplate)

function PayBackTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "pay_back_template"
end

function PayBackTemplate:OpenViewCallBack()
    self:InitList()

    local payback_info = game.RewardHallCtrl.instance:GetPayBackInfo()
    if payback_info then
        self._layout_objs.text1:SetText(string.format(config.words[3056], payback_info.leave_num))

        self._layout_objs.list:SetVisible(payback_info.leave_num > 0)
        self._layout_objs.group_null:SetVisible(payback_info.leave_num == 0)
    end

    local pioneer_lv = game.MainUICtrl.instance:GetPioneerLv()
    local role_lv = game.Scene.instance:GetMainRoleLevel()
    local ratio = config_help.ConfigHelpLevel.GetPioneerLvRatio(role_lv, pioneer_lv)
    ratio = math.floor(ratio * 100)
    if ratio > 0 then
        self._layout_objs.text2:SetText(string.format(config.words[3057], ratio + 100))
    else
        self._layout_objs.text2:SetText("")
    end
end

function PayBackTemplate:InitList()
    local list = self:CreateList("list", "game/reward_hall/item/pay_back_item")
    list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(config.mon_retrieve[idx])
    end)
    list:SetItemNum(#config.mon_retrieve)
end

return PayBackTemplate