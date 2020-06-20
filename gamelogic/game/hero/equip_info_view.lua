local EquipInfoView = Class(game.BaseView)

function EquipInfoView:_init(ctrl)
    self._package_name = "ui_hero"
    self._com_name = "equip_info_view"
    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function EquipInfoView:OpenViewCallBack(pulse, pos, id, state, btn_visible, in_bag)
    self._layout_objs.btn_wear:SetVisible(state)
    self._layout_objs.btn_takeoff:SetVisible(not state)
    self._layout_objs.btn_wear:AddClickCallBack(function()
        if pulse and pos then
            self.ctrl:SendWearEquip(pulse, pos)
        else
            self:OpenHeroPulse()
        end
        self:Close()
    end)

    self._layout_objs.btn_takeoff:AddClickCallBack(function()
        self.ctrl:SendTakeOffEquip(pulse, pos)
        self:Close()
    end)

    self._layout_objs.btn_smelt:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenSmeltSelectView(pos)
        self:Close()
    end)

    self._layout_objs.n65:SetVisible(btn_visible)

    self.icon = self:GetTemplate("game/bag/item/goods_item", "icon")

    self:SetEquipInfo(id)

    local controller = self:GetRoot():GetController("c1")
    local index = 0
    if in_bag == true then
        index = 1
    end
    controller:SetSelectedIndexEx(index)
end

function EquipInfoView:OnEmptyClick()
    self:Close()
end

function EquipInfoView:SetEquipInfo(id)
    local goods_cfg = config.goods[id]
    self._layout_objs.name:SetText(goods_cfg.name)
    local clr = cc.GoodsColor_light[goods_cfg.color]
    self._layout_objs.name:SetColor(clr.x, clr.y, clr.z, clr.w)
    self.icon:SetItemInfo({ id = id })
    self._layout_objs.desc:SetText(goods_cfg.desc)

    local equip_cfg = config.equip_attr[id]
    local pos_name = config.equip_pos[equip_cfg.pos].name
    self._layout_objs.pos:SetText(pos_name)
    local potential_name = ""
    for _, v in pairs(config.pulse_potential_pos) do
        if v.pos == equip_cfg.pos then
            potential_name = v.name
        end
    end
    self._layout_objs.potential:SetText(string.format(config.words[3137], potential_name, config.words[1242 + goods_cfg.color]))
    for i = 1, 9 do
        self._layout_objs["star" .. i]:SetVisible(equip_cfg.star >= i)
    end

    local heros = config.pulse_equip[id].heros
    local hero_name = ""
    for i, v in ipairs(heros) do
        hero_name = hero_name .. config.hero[v].name
        if i < #heros then
            hero_name = hero_name .. "、"
        end
    end
    if hero_name == "" then
        hero_name = config.words[1552]
    end
    self._layout_objs.hero:SetText(hero_name)
end

function EquipInfoView:OpenHeroPulse()
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local low_lv = 100
    for _, v in pairs(config.pulse) do
        if v.level < low_lv then
            low_lv = v.level
        end
    end
    if role_lv >= low_lv then
        game.HeroCtrl.instance:OpenView(2)
    else
        game.GameMsgCtrl.instance:PushMsg(config.words[3138] .. low_lv .. config.words[2101])
    end
end

return EquipInfoView
