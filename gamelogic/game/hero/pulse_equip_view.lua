local PulseEquipView = Class(game.BaseView)

function PulseEquipView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "equip_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PulseEquipView:OpenViewCallBack(id, pos)
    self.pulse_id = id
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[3124])

    self.list = self:CreateList("list", "game/bag/item/goods_item", true)
    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.equip_list[idx]
        if info then
            item:SetItemInfo(info)
            item:AddClickEvent(function()
                self:SetSelectEquip(info)
            end)
        else
            item:ResetItem()
        end
    end)

    self:SetList(pos)
end

function PulseEquipView:OnEmptyClick()
    self:Close()
end

function PulseEquipView:SetList(pos)
    local goods_list = game.BagCtrl.instance:GetGoodsBagByBagId(1)
    self.equip_list = {}
    for _, v in pairs(goods_list.goods) do
        local equip_cfg = config.equip_attr[v.goods.id]
        if config.pulse_equip[v.goods.id] and equip_cfg.pos == pos then
            table.insert(self.equip_list, v.goods)
        end
    end

    local bag_equips_num = #self.equip_list
    if bag_equips_num < 42 then
        bag_equips_num = 42
    elseif bag_equips_num % 6 ~= 0 then
        bag_equips_num = bag_equips_num + 6 - bag_equips_num % 6
    end

    self.list:SetItemNum(bag_equips_num)
end

function PulseEquipView:SetSelectEquip(info)
    self.ctrl:OpenEquipInfoView(self.pulse_id, info.pos, info.id, true, true)
end

return PulseEquipView
