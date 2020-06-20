local RoleBaseTemplate = Class(game.UITemplate)

function RoleBaseTemplate:_init(parent, info)
    self.parent_view = parent
    self.info = info
end

function RoleBaseTemplate:OpenViewCallBack()
    self:InitRoleModel()
    self:InitEquipList()
    self:RefreshEquipList()
    self:RefreshGodweapon()
    self:RefreshHideweapon()
    self:RefreshWeaponSoul()
    self:RefreshDragonDesign()

    self:InitInfo()
    self:SetHonor()

    self._layout_objs["btn_bs"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenStoneSuitAttrView(self.info.career, self:GetAllEquipStoneMinLv())
    end)
    self._layout_objs["btn_zb"]:AddClickCallBack(function()
        local lv, list = self:GetStrenSuitLv()
        game.FoundryCtrl.instance:OpenStrenSuitAttrView(self.info.career, list)
    end)

end

function RoleBaseTemplate:CloseViewCallBack()
    self:ClearEquipList()
    self:ClearRoleModel()
end

function RoleBaseTemplate:InitInfo()
    local cfg = config.career_init[self.info.career]
    self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. self.info.career)
    self._layout_objs["role_info_txt"]:SetText(string.format(config.words[1267], self.info.level, cfg.name, cfg.element, cfg.atk_type_name))
    self._layout_objs["name_txt"]:SetText(self.info.name)
end

function RoleBaseTemplate:InitEquipList()
    self.equip_list = {}
    for i = 1, 12 do
        local equip_item = require("game/bag/item/goods_item").New()
        equip_item:SetVirtual(self._layout_objs["equip" .. i])
        equip_item:SetShowTipsEnable(true)
        equip_item:Open()
        equip_item:AddClickEvent(function()
            local equip_info
            if i == 9 then
                equip_info = self.info.artifact
            elseif i == 10 then
                equip_info = self.info.anqi
            elseif i == 11 then
                equip_info = self.info.warrior_soul
                equip_info.id = self.info.warrior_soul.lv
            elseif i == 12 then
                equip_info = self:GetEquipInfoByType(i)
                equip_info.dragon_data = self.info.dragon
            else
                equip_info = self:GetEquipInfoByType(i)
            end

            if equip_info and equip_info.id ~= 0 then
                if i == 9 then
                    game.BagCtrl.instance:OpenWearGodweaponInfoView(equip_info, false)
                elseif i == 10 then
                    game.BagCtrl.instance:OpenWearHideweaponInfoView(equip_info, false)
                elseif i == 11 then
                    game.BagCtrl.instance:OpenWearWeaponSoulInfoView(equip_info, false)
                elseif i == 12 then
                    game.BagCtrl.instance:OpenWearDragonDesignInfoView(equip_info, false)
                else
                    game.BagCtrl.instance:OpenWearEquipInfoView(equip_info, true)
                end
            end
        end)

        local info = {}
        info.name = self._layout_objs["equip_lv" .. i]
        info.name:SetVisible(false)
        info.item = equip_item
        table.insert(self.equip_list, info)
    end
end

function RoleBaseTemplate:ClearEquipList()
    for _, v in ipairs(self.equip_list) do
        v.item:DeleteMe()
    end
    self.equip_list = nil
end

function RoleBaseTemplate:GetEquipInfoByType(type)
    for _, v in pairs(self.info.equips) do
        if v.equip.pos == type then
            if type == 7 then
                v.equip.mate_name = self.info.marriage.mate_name
                v.equip.marry_bless = self.info.marriage.bless
            end
            return v.equip
        end
    end
end

function RoleBaseTemplate:RefreshEquipList()
    for i = 1, 8 do
        local equip_info = self:GetEquipInfoByType(i)
        if equip_info and equip_info.id ~= 0 then
            self.equip_list[i].item:SetItemInfo({ id = equip_info.id })
            if i == 7 and self.info.marriage.mate_id ~= 0 then
                local bless_cfg = config.marry_bless[self.info.marriage.bless]
                self.equip_list[i].item:SetRingImage(bless_cfg.frame)
            end
        else
            self.equip_list[i].item:ResetItem()
            self.equip_list[i].item:SetItemImage(tostring(i))
        end
    end

    self._layout_objs["btn_bs"]:SetText(tostring(self:GetStoneSuitNum()))
    self._layout_objs["btn_zb"]:SetText(tostring(self:GetStrenSuitLv()))
end

function RoleBaseTemplate:RefreshGodweapon()
    local equip_info = self.info.artifact
    if equip_info and equip_info.id > 0 then
        self.equip_list[9].item:SetVisible(true)

        local gw_id = equip_info.id
        local career = math.floor(gw_id / 100)
        local gw_cfg = config.artifact_base[career][gw_id]
        local item_id = gw_cfg.item_id
        self.equip_list[9].item:SetItemInfo({ id = item_id })
    else
        self.equip_list[9].item:SetVisible(false)
    end
end

function RoleBaseTemplate:InitRoleModel()
    local Weapon2_model, is_two = config_help.ConfigHelpModel.GetWeaponID(self.info.career, self.info.artifact.id)
    if not is_two then
        Weapon2_model = 0
    end
    local model_list = {
        [game.ModelType.Body] = config_help.ConfigHelpModel.GetBodyID(self.info.career, self.info.fashion),
        [game.ModelType.Hair] = config_help.ConfigHelpModel.GetHairID(self.info.career, self.info.hair),
        [game.ModelType.Weapon] = config_help.ConfigHelpModel.GetWeaponID(self.info.career, self.info.artifact.id),
        [game.ModelType.Weapon2] = Weapon2_model,
    }
    self.role_model = require("game/character/model_template").New()
    self.role_model:CreateModel(self._layout_objs["wrapper"], game.BodyType.Role, model_list)
    self.role_model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.Body + game.ModelType.Hair)
    self.role_model:SetCameraRotation(9.5, 0, 0)
    self.role_model:SetPosition(0, -1.25, 3)
    self.role_model:SetRotation(0, 180, 0)
end

function RoleBaseTemplate:ClearRoleModel()
    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end
end

function RoleBaseTemplate:SetHonor()
    local honor = self.info.title_honor
    self._layout_objs["title_txt"]:SetVisible(honor == 0)
    self._layout_objs["honor"]:SetVisible(honor > 0)
    if honor > 0 then
        self._layout_objs["honor"]:SetSprite("ui_title", config.title_honor[honor].icon, true)
    end
end


--宝石套装数量
function RoleBaseTemplate:GetStoneSuitNum()

    local career = self.info.career
    local suit_cfg = config.equip_stone_suit[career]
    local stone_min_lv_list = self:GetAllEquipStoneMinLv()

    local max_lv = 0
    for i = 1, 7 do
        local cfg = suit_cfg[i]
        local count = 0
        for _, stone_min_lv in pairs(stone_min_lv_list) do
            if stone_min_lv >= cfg.lv then
                count = count + 1
            end
        end

        if count >= cfg.num then
            max_lv = i
        end
    end

    return max_lv
end

function RoleBaseTemplate:GetAllEquipStoneMinLv()

    local list = {}

    for i = 1, 8 do
        local lv = self:GetStoneMinLvByPos(i)
        table.insert(list, lv)
    end

    local godweapon_stone_min_lv = self:GetGodweaponStoneMinLv()
    table.insert(list, godweapon_stone_min_lv)

    local hideweapon_stone_min_lv = self:GetHideweaponStoneMinLv()
    table.insert(list, hideweapon_stone_min_lv)

    return list
end

function RoleBaseTemplate:GetStoneMinLvByPos(equip_pos)

    local min_lv = 9999

    for _, var in pairs(self.info.equips) do

        if var.equip.pos == equip_pos then

            local count = 0
            for _, v in pairs(var.equip.stones) do
                local stone_item_id = v.id
                local cfg = self:GetStoneCfg(stone_item_id)
                local lv = cfg.level

                if lv <= min_lv then
                    min_lv = lv
                end
                count = count + 1
            end

            if min_lv == 9999 or count < 4 then
                min_lv = 0
            end

            break
        end
    end

    return min_lv
end

function RoleBaseTemplate:GetGodweaponStoneMinLv()

    local min_lv = 9999

    if self.godweapon_data then

        local count = 0
        for _, v in pairs(self.info.artifact.stones) do
            local stone_item_id = v.id
            local cfg = self:GetStoneCfg(stone_item_id)
            local lv = cfg.level

            if lv <= min_lv then
                min_lv = lv
            end
            count = count + 1
        end

        if min_lv == 9999 or count < 4 then
            min_lv = 0
        end
    end

    return min_lv
end

function RoleBaseTemplate:GetHideweaponStoneMinLv()

    local min_lv = 9999

    if self.hideweapon_data then

        local count = 0
        for _, v in pairs(self.info.anqi.stones) do
            local stone_item_id = v.id
            local cfg = self:GetStoneCfg(stone_item_id)
            local lv = cfg.level

            if lv <= min_lv then
                min_lv = lv
            end
            count = count + 1
        end

        if min_lv == 9999 or count < 4 then
            min_lv = 0
        end
    end

    return min_lv
end

function RoleBaseTemplate:GetStoneCfg(stone_item_id)

    local cfg

    for _, v in pairs(config.equip_stone) do

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

function RoleBaseTemplate:GetStrenSuitLv()

    local career = self.info.career
    local suit_cfg = config.equip_stren_suit[career]
    local stren_lv_list = {}
    for pos = 1, 8 do

        local equip_info = self:GetEquipInfoByType(pos)
        if equip_info then
            table.insert(stren_lv_list, equip_info.stren)
        else
            table.insert(stren_lv_list, 0)
        end
    end

    local godweapon_data = self.info.artifact
    if godweapon_data and godweapon_data.id > 0 then
        table.insert(stren_lv_list, godweapon_data.stren)
    end

    local hideweapon_data = self.info.anqi
    if hideweapon_data and hideweapon_data.id > 0 then
        table.insert(stren_lv_list, hideweapon_data.stren)
    end

    local stren_suit_lv = 0

    for _, v in pairs(suit_cfg) do

        local need_lv = v.lv
        local need_num = v.num

        local count = 0
        for _, stren_lv in pairs(stren_lv_list) do

            if stren_lv >= need_lv then
                count = count + 1
            end
        end

        if count >= need_num then
            stren_suit_lv = stren_suit_lv + 1
        end
    end

    return stren_suit_lv, stren_lv_list
end

function RoleBaseTemplate:RefreshHideweapon()
    local equip_info = self.info.anqi
    if equip_info and equip_info.id > 0 then
        self.equip_list[10].item:SetVisible(true)

        local cur_cfg = config.anqi_model[equip_info.id]
        local item_id = cur_cfg.icon
        self.equip_list[10].item:SetItemInfo({ id = item_id})
    else
        self.equip_list[10].item:SetVisible(false)
    end
end

function RoleBaseTemplate:RefreshWeaponSoul()
    local equip_info = self.info.warrior_soul
    if equip_info and equip_info.lv > 0 then
        self.equip_list[11].item:SetVisible(true)

        local star_lv = equip_info.star_lv
        local item_id = config.weapon_soul_star_up[star_lv].icon
        self.equip_list[11].item:SetItemInfo({ id = item_id})
    else
        self.equip_list[11].item:SetVisible(false)
    end
end

function RoleBaseTemplate:RefreshDragonDesign()
    local equip_info = self:GetEquipInfoByType(12)
    if equip_info and equip_info.id > 0 then
        self.equip_list[12].item:SetVisible(true)

        local item_id = equip_info.id
        self.equip_list[12].item:SetItemInfo({ id = item_id})
    else
        self.equip_list[12].item:SetVisible(false)
    end
end

return RoleBaseTemplate
