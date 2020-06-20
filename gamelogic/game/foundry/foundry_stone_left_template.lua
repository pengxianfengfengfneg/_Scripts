local FoundryStoneLeftTemplate = Class(game.UITemplate)

function FoundryStoneLeftTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "stone_left_template"
    self.parent = parent
end

function FoundryStoneLeftTemplate:OpenViewCallBack()

    self.equip_item = require("game/bag/item/goods_item").New()
    self.equip_item:SetVirtual(self._layout_objs["n0"])
    self.equip_item:Open()
    self.equip_item:SetTouchEnable(true)
    self.equip_item:ResetItem()
    self._layout_objs["n0/sub_btn"]:AddClickCallBack(function()
        if self.stone_pos then
            game.FoundryCtrl.instance:CsEquipInlayStone(self.stone_pos, 0)
        end
    end)

    self._layout_objs["n4"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenAdvanceView({self.stone_item_id, self.stone_pos})
    end)

end

function FoundryStoneLeftTemplate:CloseViewCallBack()

    if not self.equip_item then
        self.equip_item:DeleteMe()
        self.equip_item = nil
    end
end

function FoundryStoneLeftTemplate:RefreshItem(idx)

    self.idx = idx

    local equip_pos = self.parent:GetSelectIndex()
    local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(equip_pos)
    if equip_pos == 9 then
        equip_info = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    elseif equip_pos == 10 then
        equip_info = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    elseif equip_pos == 11 then
        equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    end

    local stone_pos = equip_pos*10 + idx    --宝石格子id
    local stone_item_id = 0

    if equip_info and equip_info.stones then

        for _, v in pairs(equip_info.stones) do
            if v.pos == stone_pos then
                stone_item_id = v.id
                break
            end
        end
    end

    self.stone_item_id = stone_item_id
    self.stone_pos = stone_pos

    --未镶嵌
    if stone_item_id == 0 then
        self.stone_pos = nil
        self.equip_item:ResetItem()
        self._layout_objs["n1"]:SetText("")
        self._layout_objs["n2"]:SetText("")
        self._layout_objs["n3"]:SetVisible(true)
        self._layout_objs["n4"]:SetVisible(false)
    else
        self.stone_pos = stone_pos
        local item_cfg = config.goods[stone_item_id]
        local cfg = self:GetStoneCfg(stone_item_id)
        local attr = cfg.attr
        local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[1])

        self._layout_objs["n1"]:SetText(item_cfg.name)

        self.equip_item:SetItemInfo({id = stone_item_id, num = 1})

        self._layout_objs["n2"]:SetText(string.format(config.words[1226], attr_name, attr[2]))
        self._layout_objs["n3"]:SetVisible(false)
        self._layout_objs["n4"]:SetVisible(true)
        self._layout_objs["n0/sub_btn"]:SetVisible(true)

        if cfg.next_id > 0 then
            self._layout_objs["n4"]:SetVisible(true)
        else
            self._layout_objs["n4"]:SetVisible(false)
        end
    end
end

function FoundryStoneLeftTemplate:SetSelect(val)
    self._layout_objs["select_img"]:SetVisible(val)
end

function FoundryStoneLeftTemplate:GetIndex()
    return self.idx
end

function FoundryStoneLeftTemplate:GetStoneCfg(stone_item_id)

    local cfg

    for k, v in pairs(config.equip_stone) do

        for item_id, v2 in pairs(v) do

            if item_id == stone_item_id then
                cfg = v2
                break
            end
        end

        if cfg then
            break
        end
    end

    return cfg
end

return FoundryStoneLeftTemplate