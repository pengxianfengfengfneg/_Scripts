local GrowthFundItem = Class(game.UITemplate)

function GrowthFundItem:OpenViewCallBack()
    self._layout_objs.btn:AddClickCallBack(function()
        if self.info.level ~= 0 then
            game.RewardHallCtrl.instance:SendGrowthFundGet(self.info.grade, self.info.id)
        end
    end)
end

function GrowthFundItem:SetItemInfo(info)
    self.info = info
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    if info.level == 0 then
        self._layout_objs.text:SetText(config.words[3043])
        self._layout_objs.type:SetSprite("ui_common", config.money_type[2].icon)
        self._layout_objs.btn:SetGray(info.buy_state == 1)
        self._layout_objs.btn:SetTouchEnable(info.buy_state == 0)
        if info.buy_state == 1 then
            self._layout_objs.btn:SetText(config.words[3045])
        else
            self._layout_objs.btn:SetText(config.words[3046])
        end
    else
        self._layout_objs.text:SetText(string.format(config.words[3044], info.level))
        self._layout_objs.type:SetSprite("ui_common", config.money_type[3].icon)

        local flag = false
        local fund_info = game.RewardHallCtrl.instance:GetGrowthFundInfo()
        for _, v in pairs(fund_info.get_list) do
            if v.id == info.id then
                flag = true
                break
            end
        end
        self._layout_objs.btn:SetGray(flag or role_lv < info.level or info.grade ~= fund_info.grade)
        self._layout_objs.btn:SetTouchEnable(not flag and role_lv >= info.level and info.grade == fund_info.grade)
        if flag then
            self._layout_objs.btn:SetText(config.words[3040])
        else
            self._layout_objs.btn:SetText(config.words[3047])
        end
    end
    self._layout_objs.money:SetText(info.bgold)
end

function GrowthFundItem:SetBG(val)
    if val then
        self._layout_objs.bg:SetSprite("ui_common", "009_1")
    else
        self._layout_objs.bg:SetSprite("ui_common", "009_2")
    end
end

return GrowthFundItem