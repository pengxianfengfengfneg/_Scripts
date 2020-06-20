local RewardHallView = Class(game.BaseView)

local reward_hall_config = {
    [1] = "game/reward_hall/templates/sign_template",
    [2] = "game/reward_hall/templates/daily_gift_template",
    [3] = "game/reward_hall/templates/month_card_template",
    [4] = "game/reward_hall/templates/growth_fund_template",
    [5] = "game/reward_hall/templates/online_template",
    [6] = "game/reward_hall/templates/level_gift_template",
    [7] = "game/reward_hall/templates/get_back_template",
    [8] = "game/reward_hall/templates/pay_back_template",
    [9] = "game/reward_hall/templates/reward_cdkey_template",
    [10] = "game/reward_hall/templates/reward_notice_template",
    [11] = "game/reward_hall/templates/seven_login_template",
    [12] = "game/reward_hall/templates/dividend_template",
}

local visible_config = {
    [2] = function()
        return false
    end,
    --[3] = function()
    --    return false
    --end,
    --[4] = function()
    --    return false
    --end,
    [11] = function()
        return game.RewardHallCtrl.instance:CanShowSevenLogin()
    end,
    [12] = function()
        return game.RewardHallCtrl.instance:CanShowDividend()
    end,
}

local red_config = {
    [1] = {
        check_func = function()
            return game.RewardHallCtrl.instance:GetSignTipState()
        end,
        update_event = {
            game.RewardHallEvent.UpdateAccInfo,
            game.RewardHallEvent.UpdateSignInfo,
        },
    },
    [5] = {
        check_func = function()
            return game.RewardHallCtrl.instance:GetOnlineTipState()
        end,
        update_event = {
            game.RewardHallEvent.UpdateOnlineInfo,
            game.RewardHallEvent.UpdateOnlinePray,
        },
    },
    [6] = {
        check_func = function()
            return game.RewardHallCtrl.instance:GetLevelGiftTipState()
        end,
        update_event = {
            game.RewardHallEvent.UpdateLevelGift,
        },
    },
    [7] = {
        check_func = function()
            return game.RewardHallCtrl.instance:GetGetBackTipState()
        end,
        update_event = {
            game.RewardHallEvent.UpdateGetBackInfo,
        },
    },
    [8] = {
        check_func = function()
            return game.RewardHallCtrl.instance:GetPayBackTipState()
        end,
        update_event = {
            game.RewardHallEvent.UpdatePayBackInfo,
        },
    },
    [11] = {
        check_func = function()
            return game.RewardHallCtrl.instance:GetSevenLoginRedVisible()
        end,
        update_event = {
            game.RewardHallEvent.OnSevenLoginInfo,
            game.RewardHallEvent.OnSevenLoginGet,
        },
    },
    [12] = {
        check_func = function()
            return game.RewardHallCtrl.instance:CheckDividendRedPoint()
        end,
        update_event = {
            game.RewardHallEvent.OnDividendLuckyInfo,
            game.RewardHallEvent.OnDividendLvGet,
            game.RewardHallEvent.OnDividendStoneChange,
            game.RewardHallEvent.OnDividendLuckyInfo,
        },
    },
}

function RewardHallView:_init(ctrl)
    self._package_name = "ui_reward_hall"
    self._com_name = "reward_hall_view"

    self._show_money = true

    self.ctrl = ctrl

    self:AddPackage("ui_lucky_money")
    self:AddPackage("ui_imperial_examine")
end

function RewardHallView:CloseViewCallBack()
    self.page_list:ClearList()
    self.tab_map = nil
end

function RewardHallView:OpenViewCallBack(template_index)
    template_index = template_index or 1
    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        local index = idx - 1
        if index < 0 then
            index = 0
        end
        self.tab_list:ScrollToView(index, true, true)
    end)

    self:GetFullBgTemplate("common_bg"):SetTitleName(config.words[3003])

    self:BindRedEvent()
    self:InitTemplates()

    global.TimerMgr:CreateTimer(0.1, function()
        local tab = self.tab_map[template_index]
        local open_idx = tab and tab.idx or 1
        self.tab_controller:SetSelectedIndexEx(open_idx - 1)
        return true
    end)
end

function RewardHallView:InitTemplates()
    self.tab_map = {}

    local template_cfg = {}
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    for k, v in pairs(config.reward_hall) do
        v.id = k
        if role_lv >= v.lv and self:CanShowTemplate(v.id) then
            table.insert(template_cfg, v)
        end
    end
    table.sort(template_cfg, function(a, b)
        return a.sort < b.sort
    end)

    self.tab_list = self:CreateList("list_tab")
    self.tab_list:SetCreateItemFunc(function(obj)
        return obj
    end)
    self.tab_list:SetRefreshItemFunc(function(obj, idx)
        local cfg = template_cfg[idx]
        obj:SetText(cfg.name)
        obj:SetIcon("ui_reward_hall", cfg.icon)
        if red_config[cfg.id] then
            local visible = red_config[cfg.id].check_func()
            game.Utils.SetTip(obj, visible, {x=123,y=5})
        end
        local tab = self.tab_map[cfg.id] or {}
        tab.obj = obj
        tab.idx = idx
        self.tab_map[cfg.id] = tab
    end)
    self.tab_list:SetItemNum(#template_cfg)

    self.page_list = game.UIList.New(self._layout_objs.list_page)
    for _, v in ipairs(template_cfg) do
        local template = require(reward_hall_config[v.id]).New()
        template:Open()
        self.page_list:AddItem(template)
    end
end

function RewardHallView:CanShowTemplate(id)
    local visible_func = visible_config[id]
    return not visible_func or visible_func()
end

function RewardHallView:UpdateRedPoint(id)
    local tab = self.tab_map[id]
    if tab then
        local visible = red_config[id].check_func()
        game.Utils.SetTip(tab.obj, visible, {x=123,y=5})
    end
end

function RewardHallView:BindRedEvent()
    for k, v in pairs(red_config) do
        for _, evt in ipairs(v.update_event) do
            self:BindEvent(evt, function()
                self:UpdateRedPoint(k)
            end)
        end
    end
end

return RewardHallView