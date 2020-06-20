local GrowthFoundTemplate = Class(game.UITemplate)

local _cfg_info = config.grow_fund_info
local _cfg_fund = config.grow_fund

function GrowthFoundTemplate:_init()
    self._package_name = "ui_reward_hall"
    self._com_name = "growth_fund_template"
end

local open_recharge_tips = function(price_type)
    local money_name = config.money_type[price_type].name
    local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(string.format(config.words[1621], money_name))
    tips_view:SetBtn1(nil, function()
        game.RechargeCtrl.instance:OpenView()
    end)
    tips_view:Open()
end

function GrowthFoundTemplate:OpenViewCallBack()
    self:InitList()
    self:BindEvent(game.RewardHallEvent.UpdateGrowthFundInfo, function()
        self:SetGrowthFund()
    end)
    self:SetGrowthFund()

    --购买成长基金
    self._layout_objs.btn_buy:AddClickCallBack(function()
        local cur_money = game.ShopCtrl.instance:GetMoneyByType(25)
        if cur_money < 880 then
            open_recharge_tips(25)
        else
            game.RewardHallCtrl.instance:SendBuyFundReward()
        end
    end)
end

function GrowthFoundTemplate:InitList()
    self.list = self:CreateList("list", "game/reward_hall/item/growth_fund_item")
    self.list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo(self.fund_items[idx])
        item:SetBG(idx % 2 == 1)
    end)
end

function GrowthFoundTemplate:SetGrowthFund()
    local info = game.RewardHallCtrl.instance:GetGrowthFundInfo()
    if info == nil then
        return
    end
    local grade = 0
    local buy_state = 1
    if info.grade == 0 then
        grade = 11
        buy_state = 0
    elseif info.grade == 11 then
        grade = info.grade
        if #info.get_list == #_cfg_fund[grade] then
            grade = 11
            buy_state = 0
        end
    --elseif info.grade == 12 then
    --    grade = info.grade
    --    if #info.get_list == #_cfg_fund[grade] then
    --        grade = 13
    --        buy_state = 0
    --    end
    --else
    --    grade = 13
    end

    local cfg = _cfg_info[grade]
    self._layout_objs.money:SetSprite("ui_reward_hall", cfg.money, true)
    self._layout_objs.mul:SetSprite("ui_reward_hall", cfg.mul, true)
    self._layout_objs.total:SetSprite("ui_reward_hall", cfg.total, true)
    self.fund_items = {}
    --table.insert(self.fund_items, { grade = grade, level = 0, buy_state = buy_state, bgold = cfg.gold })
    local total_gold = 0
    for i, v in ipairs(_cfg_fund[grade]) do
        total_gold = total_gold + v.bgold
        v.id = i
        table.insert(self.fund_items, v)
    end
    self.list:SetItemNum(#self.fund_items)

    local total_got = 0
    for _, v in pairs(info.get_list) do
        total_got = total_got + _cfg_fund[grade][v.id].bgold
    end
    self._layout_objs.got:SetText(total_got .. "/" .. total_gold)

end

return GrowthFoundTemplate