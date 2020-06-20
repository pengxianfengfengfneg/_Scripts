local NeidanUpgradeView = Class(game.BaseView)

function NeidanUpgradeView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "neidan_upgrade_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function NeidanUpgradeView:OnEmptyClick()
    self:Close()
end

function NeidanUpgradeView:OpenViewCallBack(zhenfa, grid)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1539])

    self:BindEvent(game.PetEvent.AttachChange, function()
        self:UpdateView(zhenfa, grid)
    end)

    self._layout_objs.btn_upgrade:AddClickCallBack(function()
        self.ctrl:SendUpgradeNeidan(zhenfa, grid)
    end)

    self._layout_objs.btn_forget:AddClickCallBack(function()
        local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[1471])
        tips_view:SetBtn1(nil, function()
            self.ctrl:SendRemoveNeidan(zhenfa, grid)
            self:Close()
        end)
        tips_view:SetBtn2(config.words[101])
        tips_view:Open()
    end)

    self.dan_item = self:GetTemplate("game/bag/item/goods_item", "skill_item")
    self.dan_item:SetShowTipsEnable(true)

    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.goods_item:SetShowTipsEnable(true)

    self:UpdateView(zhenfa, grid)
end

function NeidanUpgradeView:UpdateView(zhenfa, grid)
    local attach_info = self.ctrl:GetAttach(zhenfa)

    local dan_info
    for _, v in pairs(attach_info.internals) do
        if v.grid == grid then
            dan_info = v
        end
    end

    local pet_info = self.ctrl:GetPetInfoById(attach_info.pet_grid)
    self._layout_objs.tips:SetText("")
    local cur_value, next_value = 0, 0
    if pet_info then
        local pet_cfg = config.pet[pet_info.cid]
        cur_value = self:CalcVaule(dan_info, pet_info)
        if pet_cfg.quality ~= 2 and pet_cfg.carry_lv < config.internal_hole[grid] then
            self._layout_objs.tips:SetText(string.format(config.words[1486], config.internal_hole[grid]))
        end
    end

    local dan_cfg = config.pet_internal[dan_info.internal]
    local goods_id =  dan_cfg.material
    self.dan_item:SetItemInfo({id = goods_id, num = dan_info.lv})
    self._layout_objs.name:SetText(config.goods[goods_id].name)

    self.goods_item:SetItemInfo({id = goods_id})
    local level_cfg = config.pet_internal_level[dan_info.lv]

    if level_cfg.cost_num == 0 then
        self._layout_objs.btn_upgrade:SetTouchEnable(false)
        self._layout_objs.btn_upgrade:SetGray(false)
        self._layout_objs.btn_upgrade:SetText(config.words[2201])
        self.goods_item:SetNumText("")
        self._layout_objs.ratio:SetText("")
        if cur_value > 0 then
            self._layout_objs.desc:SetText(config.goods[goods_id].desc .. "\n" .. string.format(config.words[1478], config.combat_power_battle[dan_cfg.bt_attr].name, cur_value))
        else
            self._layout_objs.desc:SetText(config.goods[goods_id].desc)
        end
    else
        local own = game.BagCtrl.instance:GetNumById(goods_id)
        local num = level_cfg.cost_num
        self.goods_item:SetNumText(own .. "/" .. num)
        self._layout_objs.btn_upgrade:SetText(config.words[2770])
        self._layout_objs.btn_upgrade:SetTouchEnable(own >= num)
        self._layout_objs.btn_upgrade:SetGray(own < num)
        self._layout_objs.ratio:SetText(string.format(config.words[1510], math.floor(level_cfg.upgrade_rate / 100)))
        if cur_value > 0 then
            next_value = self:CalcVaule({internal = dan_info.internal, lv = dan_info.lv + 1}, pet_info)
            self._layout_objs.desc:SetText(config.goods[goods_id].desc .. "\n" .. string.format(config.words[1479], config.combat_power_battle[dan_cfg.bt_attr].name, cur_value, next_value))
        else
            self._layout_objs.desc:SetText(config.goods[goods_id].desc)
        end
    end
end

local function potential(init_val, star_add, savvy_add)
    return math.floor(init_val * (1 + star_add / 10000) * (1 + savvy_add / 10000))
end

function NeidanUpgradeView:CalcVaule(attach_info, pet_info)
    local star_add = config.pet_star[pet_info.star] or 0
    local savvy_cfg = config.pet_savvy[pet_info.savvy_lv]
    local qua = {}
    qua[1] = potential(pet_info.potential.power, star_add, savvy_cfg.potential_addon)
    qua[2] = potential(pet_info.potential.anima, star_add, savvy_cfg.potential_addon)
    qua[3] = potential(pet_info.potential.energy, star_add, savvy_cfg.potential_addon)
    qua[4] = potential(pet_info.potential.concent, star_add, savvy_cfg.potential_addon)
    qua[5] = potential(pet_info.potential.method, star_add, savvy_cfg.potential_addon)

    local dan_cfg = config.pet_internal[attach_info.internal]
    local attr_cfg = config.pet_internal_attr[dan_cfg.bt_attr]
    return math.floor((pet_info.growup_rate * attr_cfg.growup_fact + math.max(qua[attr_cfg.poten1], qua[attr_cfg.poten2]) * attr_cfg.poten_fact) * math.max(pet_info.level, 55) * config.pet_internal_level[attach_info.lv].level_fact * dan_cfg.quality)
end

return NeidanUpgradeView