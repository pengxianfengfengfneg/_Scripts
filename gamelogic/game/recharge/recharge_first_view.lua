local RechargeFirstView = Class(game.BaseView)

local StateIndex = {
    Recharge = 0,
    Reward = 1,
}

--首充装备属性
local attr ={
    [1] = {key = 101,value = 18,},
    [2] = {key = 102,value = 18,},
    [3] = {key = 103,value = 18,},
    [4] = {key = 104,value = 18,},
    [5] = {key = 105,value = 10,},
}

function RechargeFirstView:_init(ctrl)
    self._package_name = "ui_recharge"
    self._com_name = "first_recharge_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First
end

function RechargeFirstView:_delete()
    
end

function RechargeFirstView:OpenViewCallBack()
    self:Init()
end

function RechargeFirstView:CloseViewCallBack()

end

function RechargeFirstView:Init()
    self.list_item = self:CreateList("list_item", "game/bag/item/goods_item")
    self.list_item:SetRefreshItemFunc(function(item, idx)
        local item_info = self.item_list_data[idx]
        if idx == 3 or idx == 4 then
            item:SetItemInfo({id = item_info[1], num = item_info[2], bind = item_info[3], paris = 0 ,attr = attr , val = true})
            item:SetShowTipsEnable(true)
        else
            item:SetItemInfo({id = item_info[1], num = item_info[2], bind = item_info[3]})
            item:SetShowTipsEnable(true)
        end
    end)

    local drop_id = config.sys_config["first_charge_reward"].value
    self.item_list_data = config.drop[drop_id].client_goods_list
    self.list_item:SetItemNum(#self.item_list_data)

    self._layout_objs.btn_recharge:AddClickCallBack(function()
        self.ctrl:OpenView()
    end)

    self._layout_objs.btn_get:AddClickCallBack(function()
        self.ctrl:SendChargeConsumeFirstReward()
        self:Close()
    end)

    self._layout_objs.btn_close:AddClickCallBack(function()
        self:Close()
    end)

    self.ctrl_state = self:GetRoot():GetController("ctrl_state")
    self:SetState()

    self:BindEvent(game.RechargeEvent.OnConsumeFlagChange, function()
        self:SetState()
    end)
end

function RechargeFirstView:SetState()
    self.ctrl_state:SetSelectedIndexEx((self.ctrl:GetFlag() == 0) and StateIndex.Recharge or StateIndex.Reward)
end

return RechargeFirstView
