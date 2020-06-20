local MoneyTemplate = Class(game.UITemplate)

local MoneyConfig = require("game/main/money_config")

function MoneyTemplate:_init(view)
    
    self.parent_view = view
end

function MoneyTemplate:OpenViewCallBack()
    self:InitMoney()

    self:RegisterAllEvents()
end

function MoneyTemplate:CloseViewCallBack()
    
end

function MoneyTemplate:RegisterAllEvents()
    self:BindEvent(game.MoneyEvent.Change, function(change_list)
        self:OnMoneyChange(change_list)
    end)
end

local NumConfig = {
    [2] = {gap=140, font_size=22},
    [3] = {gap=85, font_size=22},
    [4] = {gap=16, font_size =20},
    [5] = {gap=8, font_size=18},
}

local DefaultMoney = {
    game.MoneyType.Copper,
    game.MoneyType.Gold,
    game.MoneyType.BindGold,
}

function MoneyTemplate:InitMoney()
    self.list_item = self._layout_objs["n17"]
    
    self:UpdateMoneyStyle(DefaultMoney)
end

function MoneyTemplate:OnMoneyChange(change_list)
    for k,v in pairs(self.item_obj_list) do
        local change = change_list[k]
        if change then
            v:SetText(change)
        end
    end
end

function MoneyTemplate:UpdateMoneyStyle(money_list)
    self.item_obj_list = {}

    local item_num = #money_list
    self.list_item:SetItemNum(item_num)

    local num_cfg = NumConfig[item_num] or NumConfig[3]
    self.list_item.columnGap = num_cfg.gap

    local bag_ctrl = game.BagCtrl.instance
    for k,v in ipairs(money_list) do
        local info = MoneyConfig[v]
        if info then
            local obj = self.list_item:GetChildAt(k-1)
            local icon = obj:GetChild("icon")
            icon:SetSprite("ui_common", info.icon)

            if info.click_func then
                obj:AddClickCallBack(info.click_func)
            end

            local title = obj:GetChild("title")
            title:SetFontSize(num_cfg.font_size)
            obj:GetChild("img_add"):SetVisible(info.is_add)
            self.item_obj_list[v] = obj

            local num = bag_ctrl:GetMoneyByType(v)
            obj:SetText(num)
        end
    end
end

return MoneyTemplate
