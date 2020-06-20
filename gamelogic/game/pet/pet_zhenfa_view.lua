local PetZhenFaView = Class(game.BaseView)

function PetZhenFaView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "futi_zhenfa_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetZhenFaView:OnEmptyClick()
    self:Close()
end

function PetZhenFaView:OpenViewCallBack(zhenfa)
    self.zhenfa = zhenfa
    self:GetBgTemplate("common_bg"):SetTitleName(zhenfa.name)

    self:BindEvent(game.PetEvent.AttachChange, function(data)
        if zhenfa.id == data.attach_id then
            self:SetPetList(data.attach_id)
        end
    end)

    self._layout_objs.btn_add:AddClickCallBack(function()
        if self.cur_pet then
            self.ctrl:SendPetAttack(zhenfa.id, self.cur_pet.grid)
        end
    end)

    self._layout_objs.btn_split:AddClickCallBack(function()
        self.ctrl:SendPetUnAttach(zhenfa.id)
    end)

    self.pet_power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)

    for i = 1, 8 do
        self._layout_objs["dan_name" .. i]:SetText("")
        self._layout_objs["level" .. i]:SetText("")
        self._layout_objs["attr" .. i]:SetText("")
        self._layout_objs["value" .. i]:SetText("")
    end

    self:InitPetList()
    self:SetPetList(zhenfa.id)
end

function PetZhenFaView:InitPetList()
    self.list = self:CreateList("list", "game/pet/item/pet_icon_item")

    self.list:SetRefreshItemFunc(function(item, idx)
        local info = self.pet_list[idx]
        item:SetItemInfo(info.pet)
    end)
    self.list:AddClickItemCallback(function(obj)
        local info = obj:GetItemInfo()
        if self.cur_pet and self.cur_pet.grid == info.grid then
            return
        end
        self:SetPetInfo(info)
    end)
end

function PetZhenFaView:SetPetList(id)
    self.pet_list = {}
    local pets = game.PetCtrl.instance:GetPetInfo()
    for i, v in pairs(pets) do
        if v.pet.star > 0 then
            table.insert(self.pet_list, v)
        end
    end
    local attach_info = self.ctrl:GetAttach(id)
    if attach_info and attach_info.pet_grid ~= 0 then
        self.pet_list = { { pet = self.ctrl:GetPetInfoById(attach_info.pet_grid) } }
        self._layout_objs.btn_add:SetVisible(false)
        self._layout_objs.btn_split:SetVisible(true)
    else
        self._layout_objs.btn_add:SetVisible(true)
        self._layout_objs.btn_split:SetVisible(false)
    end

    if self.pet_list and #self.pet_list > 0 then
        self.list:SetItemNum(#self.pet_list)
        self:SetPetInfo(self.pet_list[1].pet)
    else
        self.list:SetItemNum(0)
    end
end

local function potential(init_val, star_add, savvy_add)
    return math.floor(init_val * (1 + star_add / 10000) * (1 + savvy_add / 10000))
end

function PetZhenFaView:SetPetInfo(info)
    self.cur_pet = info
    self.list:Foreach(function(obj)
        local item_info = obj:GetItemInfo()
        obj:SetSelect(item_info.grid == info.grid)
    end)

    local fight = 0
    local attach_info = self.ctrl:GetAttach(self.zhenfa.id)
    if attach_info then

        local star_add = config.pet_star[info.star] or 0
        local savvy_cfg = config.pet_savvy[info.savvy_lv]
        local qua = {}
        qua[1] = potential(info.potential.power, star_add, savvy_cfg.potential_addon)
        qua[2] = potential(info.potential.anima, star_add, savvy_cfg.potential_addon)
        qua[3] = potential(info.potential.energy, star_add, savvy_cfg.potential_addon)
        qua[4] = potential(info.potential.concent, star_add, savvy_cfg.potential_addon)
        qua[5] = potential(info.potential.method, star_add, savvy_cfg.potential_addon)

        local pet_info = self.ctrl:GetPetInfoById(attach_info.pet_grid)
        for i, v in ipairs(attach_info.internals) do
            local dan_cfg = config.pet_internal[v.internal]
            self._layout_objs["dan_name" .. i]:SetText(config.goods[dan_cfg.material].name)
            self._layout_objs["attr" .. i]:SetText(config.combat_power_battle[dan_cfg.bt_attr].name)
            local attr_cfg = config.pet_internal_attr[dan_cfg.bt_attr]
            local value = math.floor((info.growup_rate * attr_cfg.growup_fact + math.max(qua[attr_cfg.poten1], qua[attr_cfg.poten2]) * attr_cfg.poten_fact) * math.max(info.level, 55) * config.pet_internal_level[v.lv].level_fact * dan_cfg.quality)
            self._layout_objs["value" .. i]:SetText(value)
            local extend = ""
            if pet_info == nil then
                pet_info = self.cur_pet
            end
            local pet_cfg = config.pet[pet_info.cid]
            if pet_cfg.quality == 2 or pet_cfg.carry_lv >= config.internal_hole[v.grid] then
                fight = fight + config.combat_power_battle[dan_cfg.bt_attr].pet_attach * value
            else
                extend = "[color=#db4734](" .. config.words[2850] .. ")[/color]"
            end
            self._layout_objs["level" .. i]:SetText(v.lv .. config.words[1217] .. extend)
        end
    end

    self.pet_power:SetText(math.floor(fight))
end

return PetZhenFaView