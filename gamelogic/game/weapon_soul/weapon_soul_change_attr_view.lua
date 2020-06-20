local WeaponSoulChangeAttrView = Class(game.BaseView)

function WeaponSoulChangeAttrView:_init(ctrl)
    self._package_name = "ui_weapon_soul"
    self._com_name = "weapon_soul_change_attr_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function WeaponSoulChangeAttrView:_delete()
end

function WeaponSoulChangeAttrView:OpenViewCallBack(params)
    
    self.params = params

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[6106])

    local btn_index = params.btn_index
    local attr_types = config.weapon_soul_base[1]["attr"..btn_index]

    for i = 1, 6 do
        local attr_type = attr_types[i]
        if attr_type then
            local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)

            if attr_type == params.cur_attr_id then
                self._layout_objs["txt"..i]:SetText(attr_name ..config.words[6107])
            else
                self._layout_objs["txt"..i]:SetText(attr_name)
            end

            self._layout_objs["pannel"..i]:SetVisible(true)
        else
            self._layout_objs["pannel"..i]:SetVisible(false)
        end

        self._layout_objs["n"..i]:SetTouchDisabled(false)
        self._layout_objs["n"..i]:AddClickCallBack(function()
            self:OnSelect(i)
        end)
    end

    self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs["n27"])
    self.cost_item:Open()

    local cost_item_id = config.weapon_soul_base[1].change_attr_items[1]
    local cost_item_num = config.weapon_soul_base[1].change_attr_items[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

    self.cost_item:SetItemInfo({ id = cost_item_id, num = cost_item_num})
    self.cost_item:SetNumText(cur_num.."/"..cost_item_num)

    if cur_num >= cost_item_num then
        self.cost_item:SetColor(224, 214, 189)
        self.cost_item:SetShowTipsEnable(true)
    else
        self.cost_item:SetColor(255, 0, 0)
        self.cost_item:SetShowTipsEnable(true)
    end

    self._layout_objs["btn_change"]:AddClickCallBack(function()
        if self.select_attr_index then
            game.WeaponSoulCtrl.instance:CsWarriorSoulChangeAttr(params.type, params.cur_attr_id, self.select_attr_type)
            self:Close()
        end
    end)

    self:OnSelect(1)
end

function WeaponSoulChangeAttrView:CloseViewCallBack()
    if self.cost_item then
        self.cost_item:DeleteMe()
        self.cost_item = nil
    end
end

function WeaponSoulChangeAttrView:OnSelect(index)

    local btn_index = self.params.btn_index
    local attr_types = config.weapon_soul_base[1]["attr"..btn_index]
    local attr_type = attr_types[index]
    for i = 1, 6 do
        self._layout_objs["sel"..i]:SetVisible(i==index)
    end

    self.select_attr_index = index

    self.select_attr_type = attr_type
end

return WeaponSoulChangeAttrView