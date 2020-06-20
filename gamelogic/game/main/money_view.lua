local MoneyView = Class(game.BaseView)

local MoneyConfig = require("game/main/money_config")

local OrderStack = {}
local MoneyStyleStack = {}

local NumConfig = {
    [2] = {gap=140, font_size=22},
    [3] = {gap=85, font_size=22},
    [4] = {gap=16, font_size =20},
    [5] = {gap=8, font_size=18},
}

local DefaultMoneyStyle = {
    game.MoneyType.Copper,
    game.MoneyType.Silver,
    game.MoneyType.Gold,
    game.MoneyType.BindGold,
}

local MoneyNumFunc = {
    [game.MoneyType.Gold] = function()
        return game.BagCtrl.instance:GetCombineGold()
    end,
}

local MoneyTypeTranfer = {
    [game.MoneyType.BackupGold] = game.MoneyType.Gold
}

function MoneyView:_init(ctrl)
    self._package_name = "ui_main"
    self._com_name = "money_template"

    self._mask_type = game.UIMaskType.None
    self._view_level = game.UIViewLevel.Standalone
    self.not_add_mgr = true

    self.orign_order = game.UIZOrder.UIZOrder_Main_UI
    self._ui_order = self.orign_order

    table.insert(OrderStack, self._ui_order)
    table.insert(MoneyStyleStack, DefaultMoneyStyle)

    self.ctrl = ctrl
end

function MoneyView:OpenViewCallBack()
    self:InitMoney()

    self:RegisterAllEvents()
end

function MoneyView:CloseViewCallBack()
    
end

function MoneyView:RegisterAllEvents()
    local events = {
        {game.MoneyEvent.Change, handler(self,self.OnMoneyChange)},
        {game.ViewEvent.OpenView, handler(self,self.OnOpenView)},
        {game.ViewEvent.CloseView, handler(self,self.OnCloseView)},

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1],v[2])
    end
end

function MoneyView:InitMoney()
    self.list_item = self._layout_objs["list_money"]
    
    self:UpdateMoneyStyle(DefaultMoneyStyle)

    self.is_log_view_name = N3DClient.GameConfig.GetClientConfigBool("LogViewName", false)
    if self.is_log_view_name then
        self.txt_log = self._layout_objs["txt_log"]
        self.txt_log:SetVisible(true)

        self.list_item:SetVisible(false)
    end

    self:HideLayout()
end

function MoneyView:OnMoneyChange(change_list)
    for k,v in pairs(change_list) do
        local money_type = k
        if MoneyTypeTranfer[money_type] then
            money_type = MoneyTypeTranfer[money_type]
        end

        local change = v
        for k,cv in ipairs(self.money_item_list or {}) do
            if money_type == cv:GetMoneyType() then
                local num_func = MoneyNumFunc[money_type]
                if num_func then
                    change = num_func()
                end
                cv:SetMoney(change)
                break
            end
        end
    end

end

function MoneyView:ClearMoneyItemList()
    for _,v in ipairs(self.money_item_list or {}) do
        v:DeleteMe()
    end
    self.money_item_list = {}
end

function MoneyView:UpdateMoneyStyle(money_list)
    self.item_obj_list = {}

    self:ClearMoneyItemList()

    local item_num = #money_list
    self.list_item:SetItemNum(item_num)

    local num_cfg = NumConfig[item_num] or NumConfig[3]
    self.list_item.columnGap = num_cfg.gap

    local bag_ctrl = game.BagCtrl.instance
    local item_class = require("game/main/money_item")
    for k,v in ipairs(money_list) do
        local info = MoneyConfig[v]
        if info then
            local obj = self.list_item:GetChildAt(k-1)
            local item = item_class.New(info, num_cfg, v)
            item:SetVirtual(obj)
            item:Open()

            local money_num = bag_ctrl:GetMoneyByType(v)
            local num_func = MoneyNumFunc[v]
            if num_func then
                money_num = num_func()
            end
            item:SetMoney(money_num)

            table.insert(self.money_item_list, item)
        end
    end
end

function MoneyView:OnOpenView(view)
    if view._show_money then
        local order = view._ui_order or self._ui_order
        table.insert(OrderStack, order)

        self._ui_order = order
        self:ShowLayout()

        if view._money_style then
            table.insert(MoneyStyleStack, view._money_style)
            self:UpdateMoneyStyle(view._money_style)
        end
    end

    if self.is_log_view_name then
        self.txt_log:SetText(view:GetName())
    end
end

function MoneyView:OnCloseView(view)
    if view._show_money then
        table.remove(OrderStack, #OrderStack)

        local order = OrderStack[#OrderStack]
        self._ui_order = order or self._ui_order

        if self._ui_order == self.orign_order then
            self:HideLayout()
        else
            self:ShowLayout()
        end

        if view._money_style then
            table.remove(MoneyStyleStack, #MoneyStyleStack)

            local money_style = MoneyStyleStack[#MoneyStyleStack]
            self:UpdateMoneyStyle(money_style)
        end
    end
end

return MoneyView
