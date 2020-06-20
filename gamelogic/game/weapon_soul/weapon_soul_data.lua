local WeaponSoulData = Class(game.BaseData)

function WeaponSoulData:_init()
end

function WeaponSoulData:_delete()

end

function WeaponSoulData:SetAllData(data)
    self.all_data = data
end

function WeaponSoulData:GetAllData()
    return self.all_data
end

function WeaponSoulData:UpdateJzData(data)
    if self.all_data then
        self.all_data.id = data.lv
        self.all_data.combat_power = data.combat_power
        self.all_data.add_succ_rate = data.add_succ_rate

        if data.skill > 0 then
            local t = {}
            t.id = data.skill
            table.insert(self.all_data.skills, t)
        end
    end
end

function WeaponSoulData:GetSoulPartInfoByType(type_index)

    if self.all_data then

        for k, v in pairs(self.all_data.soul_parts) do
            if v.part.type == type_index then
                return v.part
            end
        end
    end
end

function WeaponSoulData:UpdateSxData(data)
    if self.all_data then
        self.all_data.star_lv = data.star_lv
        self.all_data.combat_power = data.combat_power
    end
end

function WeaponSoulData:UpdateNhData(data)

    if self.all_data then

        self.all_data.conden_num = data.conden_num

        local part_info = self:GetSoulPartInfoByType(data.type)
        part_info.conden_ret = data.single_ret
    end
end

--更新凝魂部位
function WeaponSoulData:UpdateSoulData(data)

    if self.all_data then

        self.all_data.combat_power = data.combat_power

        local target_type = data.new_part.type

        for k, v in pairs(self.all_data.soul_parts) do
            if v.part.type == target_type then
                v.part = data.new_part
                break
            end
        end
    end
end

function WeaponSoulData:CanJingZhu()
    if not self.all_data or self.all_data.id == 0 then
        return false
    end

    local all_data = self:GetAllData()
    local lv = all_data.id

    local refine_cfg = config.weapon_soul_refine[lv]
    local cost_item_id = refine_cfg.item_cost[1]
    local cost_item_num = refine_cfg.item_cost[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
    local all_coin = game.BagCtrl.instance:GetCopper()

    if cur_num >= cost_item_num and all_coin >= refine_cfg.coin_cost then
        return true
    else
        return false
    end
end


function WeaponSoulData:CanShengXing()

    if not self.all_data or self.all_data.id == 0 then
        return false
    end
    
    local all_data = self:GetAllData()
    local lv = all_data.id
    local star_lv = all_data.star_lv
    local next_star_up_cfg = config.weapon_soul_star_up[star_lv+1]

    if next_star_up_cfg then

        local need_jz_lv = next_star_up_cfg.refine_lv
        local cost_item_id = next_star_up_cfg.upgrade_cost[1]
        local cost_item_num = next_star_up_cfg.upgrade_cost[2]
        local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

        if (cur_num >= cost_item_num) and (lv>=need_jz_lv) then
            return true
        else
            return false
        end
    else
        return false
    end
end

function WeaponSoulData:GetJPStateStr(jp_id)

    local state = config.words[1255]         --0未拥有  1已拥有  2已穿戴

    if self.all_data then

        for k, v in pairs(self.all_data.avatars) do

            if v.id == jp_id then

                if v.expire_time == 0 then
                    state = config.words[1256]
                else
                    state = game.Utils.SecToTimeCn(v.expire_time - global.Time:GetServerTime(), game.TimeFormatCn.DayHour)
                end

                break
            end
        end
    end

    return state
end

function WeaponSoulData:GetJPState(jp_id)

    local state = 0         --0未拥有  1已拥有  2已穿戴

    if self.all_data then

        for k, v in pairs(self.all_data.avatars) do

            if v.id == jp_id then
               state = 1
                break
            end
        end

        if self.all_data.cur_avatar == jp_id then
            state = 2
        end
    end

    return state
end

function WeaponSoulData:CheckJPWear(jp_id)
    if self.all_data then
        return self.all_data.cur_avatar == jp_id
    else
        return false
    end
end

function WeaponSoulData:UpdateChangeAvatar(data)
    if self.all_data then
        self.all_data.cur_avatar = data.avatar_id
    end
end

function WeaponSoulData:UpdateAvatar(data)
    if self.all_data then
        self.all_data.cur_avatar = data.cur_avatar
        self.all_data.avatars = data.avatars
        self.all_data.combat_power = data.combat_power
        self.all_data.a_combat_power = data.a_combat_power
    end
end

function WeaponSoulData:GetJZSkillList()
    local skill_list = {}

    for k, v in ipairs(config.weapon_soul_refine) do
        if v.skill > 0 then
            local t = {}
            t.id = v.skill
            t.limit_lv = v.lv
            table.insert(skill_list, t)
        end
    end

    return skill_list
end

function WeaponSoulData:CheckGetSkill(skill_id)

    local get_flag = false

    if self.all_data then
        for k,v in pairs(self.all_data.skills) do
            if v.id == skill_id then
                get_flag = true
                break
            end 
        end
    end

    return get_flag
end

function WeaponSoulData:CheckCanNingHun(multiple)
    multiple = multiple or 1
    local cost_item_id = config.weapon_soul_base[1].conden_soul_items[1]
    local cost_item_num = config.weapon_soul_base[1].conden_soul_items[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
    local cur_copper = game.BagCtrl.instance:GetCopper()

    if (cur_copper >= config.weapon_soul_base[1].conden_soul_coin * multiple) and (cur_num >= cost_item_num * multiple) then
        return true
    else
        return false
    end
end

function WeaponSoulData:CheckCanSaveNingHun(type_index)

    local soul_part_info = self:GetSoulPartInfoByType(type_index)
    local un_save_attr = soul_part_info.conden_ret.alters
    local un_save_attr_combat = game.Utils.CalculateCombatPower3(un_save_attr)

    return un_save_attr_combat > 0
end

function WeaponSoulData:CheckAllNingHunRedPoint()

    if not self.all_data or self.all_data.id == 0 then
        return false
    end

    local flag = false

    if self:CheckCanNingHun(1) then
        flag = true
    end

    for i = 1, 4 do
        if self:CheckCanSaveNingHun(i) then
            flag = true
            break
        end
    end

    return flag
end

--激活精魄属性综合
function WeaponSoulData:GetActivedJPAttr()

    local attr_list = {}

    if self.all_data then

        for k, v in pairs(self.all_data.avatars) do
            
            local jp_id = v.id
            local jp_cfg = config.weapon_soul_avatar[jp_id]

            for i, j in pairs(jp_cfg.attr) do

                if not attr_list[j[1]] then
                    attr_list[j[1]] = j[2]
                else
                    attr_list[j[1]] = attr_list[j[1]] + j[2]
                end
            end
        end
    end

    local new_attr_list = {}
    for k, v in pairs(attr_list) do
        local t = {}
        t.attr_type = k
        t.attr_value = v
        table.insert(new_attr_list, t)
    end

    return new_attr_list
end

function WeaponSoulData:GetGpIdList(type)

    local id_list = {}

    if type == 1 then
        for k, v in pairs(config.weapon_soul_avatar) do
            if v.type == 1 then
                table.insert(id_list, v.id)
            end
        end
    elseif type == 2 then
        for k, v in pairs(config.weapon_soul_avatar) do
            if v.type >= 2 then
                table.insert(id_list, v.id)
            end
        end
    end

    --已穿戴 已拥有 未拥有
    local wear_id
    for k, avatar_id in pairs(id_list) do
        if self.all_data.cur_avatar == avatar_id then
            wear_id = avatar_id
            break
        end
    end

    local get_id_list = {}
    local not_get_id_list = {}

    for k, avatar_id in pairs(id_list) do

        if self.all_data.cur_avatar ~= avatar_id then

            local get_flag = false
            for i, j in pairs(self.all_data.avatars) do

                if j.id == avatar_id then
                    get_flag = true
                    break
                end
            end

            if get_flag then
                table.insert(get_id_list, avatar_id)
            else
                table.insert(not_get_id_list, avatar_id)
            end
        end
    end

    local sort_id_list = {}
    if wear_id then
        table.insert(sort_id_list, wear_id)
    end

    for k,v in pairs(get_id_list) do
        table.insert(sort_id_list, v)
    end

    for k,v in pairs(not_get_id_list) do
        table.insert(sort_id_list, v)
    end

    return sort_id_list
end

return WeaponSoulData