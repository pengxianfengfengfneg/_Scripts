local HeroItem = Class(game.UITemplate)
local _carbon_id = 550

function HeroItem:OpenViewCallBack()
end

function HeroItem:SetItemInfo(info)
    self.item_info = info

    self._layout_objs.fight:SetText(info.fight)
    local my_fight = game.RoleCtrl.instance:GetCombatPower()
    local clr = cc.White
    if my_fight < info.fight then
        clr = cc.Red
    end
    self._layout_objs.fight:SetColor(clr.x, clr.y, clr.z, 255)
    local boss_id = info.pass_cond[1][2][1][1]
    local cfg = config.monster[boss_id]
    self._layout_objs.name:SetText(cfg.name)
    self._layout_objs.head:SetSprite("ui_headicon", tostring(cfg.icon_id), true)

    local dunge_data = game.CarbonCtrl.instance:GetData()
    self.hero_dun_data = dunge_data:GetDungeDataByID(_carbon_id)
    local flag = true
    for _, v in pairs(self.hero_dun_data.first_reward) do
        if v.lv == info.level then
            flag = false
        end
    end
    self._layout_objs.reward:SetVisible(info.first_award ~= 0 and flag)
    self._layout_objs.box_bg:SetVisible(info.first_award ~= 0 and flag)
    local play_action = self:GetRoot():GetTransition("t0")
    if info.first_award ~= 0 and flag and self.hero_dun_data.max_lv > info.level then
        play_action:Play(-1, 0, nil)
    else
        play_action:Stop()
        self._layout_objs.reward:SetRotation(0)
    end
    self._layout_objs.head:SetGray(self.hero_dun_data.now_lv < info.level)

    self:GetRoot():AddClickCallBack(function()
        if info.first_award ~= 0 and flag then
            game.DailyTaskCtrl.instance:OpenRewardShowView(_carbon_id, info.level)
        end
    end)
end

function HeroItem:SetSelect(val)
    self._layout_objs.select:SetVisible(val)
    self._layout_objs.group_fight:SetVisible(val)
end

return HeroItem