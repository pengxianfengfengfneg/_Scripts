local ChangePotentialView = Class(game.BaseView)

function ChangePotentialView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "change_potential_view"
    self._view_level = game.UIViewLevel.Fouth

    self.ctrl = ctrl
end

function ChangePotentialView:OpenViewCallBack(pulse_id, cur_info)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3123])
    self._layout_objs["common_bg/btn_back"]:SetVisible(false)

    self:BindEvent(game.HeroEvent.HeroAttrSelect, function(data)
        self:SetSelectAttr(data)
    end)

    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.goods_item:SetShowTipsEnable(true)

    self._layout_objs.btn_train:AddClickCallBack(function()
        self.ctrl:SendChangePotential(pulse_id, cur_info.type, self.info.id)
        self:Close()
    end)

    self.list = self:CreateList("list", "game/hero/item/attr_item")
    local potential_list = {}
    for i, v in pairs(config.pulse_potential) do
        if v.type == cur_info.type then
            table.insert(potential_list, v)
        end
    end
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = potential_list[idx]
        item:SetItemInfo(info)
    end)
    self.list:SetItemNum(#potential_list)

    self:SetSelectAttr(cur_info)

    self:SetCostItem()
end

function ChangePotentialView:OnEmptyClick()
    self:Close()
end

function ChangePotentialView:SetSelectAttr(info)
    self.info = info
    self.list:Foreach(function(obj)
        obj:SetSelect(info)
    end)
end

function ChangePotentialView:SetCostItem()
    local cost = config.sys_config.channel_change_potential_cost.value[1]
    self.goods_item:SetItemInfo({ id = cost[1] })
    local own = game.BagCtrl.instance:GetNumById(cost[1])
    self.goods_item:SetNumText(own .. "/" .. cost[2])
    self._layout_objs.btn_train:SetTouchEnable(own >= cost[2])
    self._layout_objs.btn_train:SetGray(own < cost[2])
end

return ChangePotentialView