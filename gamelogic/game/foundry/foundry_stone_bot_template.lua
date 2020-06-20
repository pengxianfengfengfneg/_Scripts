local FoundryStoneBotTemplate = Class(game.UITemplate)

function FoundryStoneBotTemplate:_init(parent)
    self.parent = parent
end

function FoundryStoneBotTemplate:OpenViewCallBack()

end

function FoundryStoneBotTemplate:RefreshItem(idx)
	self.idx = idx

    local pos_list = self.parent.can_stone_pos
    local equip_pos = pos_list[idx]

    if not self.goods_item then
        self.goods_item =  require("game/bag/item/goods_item").New()
        self.goods_item:SetVirtual(self._layout_objs["item"])
        self.goods_item:Open()
    end

    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(equip_pos)
    if equip_pos == 9 then
        equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    elseif equip_pos == 10 then
        equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    elseif equip_pos == 11 then
        equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    end
    if equip_info and equip_info.id and equip_info.id ~= 0 then
        local item_id
        if equip_pos == 9 then
            local gw_id = equip_info.id
            local career = math.floor(gw_id/100)
            local gw_cfg = config.artifact_base[career][gw_id]
            item_id = gw_cfg.item_id
            self.goods_item:SetItemInfo({ id = item_id})
        elseif equip_pos == 10 then
            local model_id = equip_info.id
            item_id = config.anqi_model[model_id].icon
            self.goods_item:SetItemInfo({ id = item_id})
        elseif equip_pos == 11 then
            local star_lv = equip_info.star_lv
            item_id = config.weapon_soul_star_up[star_lv].icon
            self.goods_item:SetItemInfo({ id = item_id})
        else
            item_id = equip_info.id
            self.goods_item:SetItemInfo({ id = item_id})
        end

        local goods_cfg = config.goods[item_id]
        self._layout_objs["item_name"]:SetText(goods_cfg.name)
    else
        self.goods_item:ResetItem()
        local image = tostring(idx)
        self.goods_item:SetItemImage(image)
        self._layout_objs["item_name"]:SetText("")
    end


    --宝石信息
    if equip_info then
        for i = 1, 4 do
            local stone_info = equip_info.stones[i]
            if stone_info then
                local stone_item_id = stone_info.id
                local stone_pos = stone_info.pos
                local stone_cfg = config.goods[stone_item_id]
                self._layout_objs["inlay_img"..i]:SetSprite("ui_item", tostring(stone_cfg.icon))
                self._layout_objs["inlay_img"..i]:SetVisible(true)           
            else
                self._layout_objs["inlay_img"..i]:SetVisible(false)
            end
        end
    else
        for i = 1, 4 do
            self._layout_objs["inlay_img"..i]:SetVisible(false)
        end
    end

    local select_index = self.parent:GetSelectIndex()
    self:SetSelect(select_index == idx)
end

function FoundryStoneBotTemplate:SetSelect(val)
    self._layout_objs["select_img"]:SetVisible(val)
end

function FoundryStoneBotTemplate:SetRP(val)
    self._layout_objs["hd"]:SetVisible(val)
end


return FoundryStoneBotTemplate