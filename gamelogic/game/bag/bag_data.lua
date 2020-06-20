local BagData = Class(game.BaseData)

function BagData:_init()
    self.bag_info = {}
    self.money_info = {}
end

function BagData:_delete()

end

function BagData:SetMoney(type, value)
    self.money_info[type] = value
end

local ClientMoneyTypeConfig = {
    --绑元优先
    [game.MoneyType.BindGoldFirst] = {
        value = function()
            local bag_ctrl = game.BagCtrl.instance
            return bag_ctrl:GetMoneyByType(game.MoneyType.BackupGoldFirst) + bag_ctrl:GetMoneyByType(game.MoneyType.BindGold)
        end,
    },
    --储备元宝优先
    [game.MoneyType.BackupGoldFirst] = {
        value = function()
            local bag_ctrl = game.BagCtrl.instance
            return bag_ctrl:GetMoneyByType(game.MoneyType.Gold) + bag_ctrl:GetMoneyByType(game.MoneyType.BackupGold)
        end,
    },
}
function BagData:GetMoneyByType(type)
    local client_cfg = ClientMoneyTypeConfig[type]
    if client_cfg then
        return client_cfg.value()
    else
        return self.money_info[type] or 0
    end
end

function BagData:GetHistoryMoneyByType(type)
    return self.money_info[255 - type] or 0
end

function BagData:SetBagInfo(info)
    self.bag_info = info
end

function BagData:GetBagInfo()
    return self.bag_info
end

function BagData:BagChange(changes)
    for _, v in pairs(self.bag_info) do
        for _, value in pairs(changes) do
            if value.change.bag_id == v.bag.bag_id then
                -- 删除物品
                for _, del in pairs(value.change.delete) do
                    for i, goods in ipairs(v.bag.goods) do
                        if goods.goods.pos == del.pos then
                            table.remove(v.bag.goods, i)
                        end
                    end
                end

                -- 改变物品/增加物品
                local add_flag
                for _, change_goods in pairs(value.change.change) do
                    add_flag = true
                    for i, goods in pairs(v.bag.goods) do
                        if goods.goods.pos == change_goods.goods.pos then
                            goods.goods = change_goods.goods
                            add_flag = false
                            break
                        end
                    end

                    if add_flag then
                        table.insert(v.bag.goods, change_goods)
                    end
                end
            end
        end
    end
end

function BagData:GetGoodsBagByBagId(bag_id)
    for i, v in pairs(self.bag_info) do
        if v.bag.bag_id == bag_id then
            return v.bag
        end
    end
end

function BagData:BagExtendCell(data)
    for i, v in pairs(self.bag_info) do
        if v.bag.bag_id == data.bag_id then
            v.bag.cell_num = data.cell_num
            break
        end
    end
end

function BagData:GetNumById(id)
    local own_num = 0
    local server_time = global.Time:GetServerTime()
    local bag_info = self:GetGoodsBagByBagId(1)
    if bag_info then
        for _, value in pairs(bag_info.goods) do
            if value.goods.id == id then
                if value.goods.expire == 0 or value.goods.expire > server_time then
                    own_num = own_num + value.goods.num
                end
            end
        end
    end
    return own_num
end

--获取 绑定或非绑定 物品数量
function BagData:GetBindNumById(id, bind_type)

    local own_num = 0
    local server_time = global.Time:GetServerTime()
    local bag_info = self:GetGoodsBagByBagId(1)
    if bag_info then
        for _, value in pairs(bag_info.goods) do
            if value.goods.id == id and value.goods.bind == bind_type then
                if value.goods.expire == 0 or value.goods.expire > server_time then
                    own_num = own_num + value.goods.num
                end
            end
        end
    end

    return own_num
end

function BagData:GetNumByPos(pos)
    local bag_info = self:GetGoodsBagByBagId(1)
    if bag_info then
        for _, value in pairs(bag_info.goods) do
            if value.goods.pos == pos then
                return value.goods.num
            end
        end
    end
    return 0
end

function BagData:GetIDByPos(pos)
    local bag_info = self:GetGoodsBagByBagId(1)
    if bag_info then
        for _, value in pairs(bag_info.goods) do
            if value.goods.pos == pos then
                return value.goods.id
            end
        end
    end
end

function BagData:GetSmeltEquip()
    local equip_list = {}
    local wear_equip = {}
    local attr = {}
    local cur_power = 0
    local goods_power = 0
    for i = 1, 10 do
        local equip_info = game.FoundryCtrl.instance:GetEquipInfoByType(i)
        if equip_info and equip_info.id ~= 0 then
            wear_equip[i] = equip_info.id
        end
    end
    for _, v in pairs(self.bag_info or {}) do
        if v.bag.bag_id == 1 then
            local career = game.RoleCtrl.instance:GetCareer()
            for _, goods in pairs(v.bag.goods) do
                local cfg = config.goods[goods.goods.id]
                if cfg.career ~= 0 and cfg.career ~= career then
                    table.insert(equip_list, goods)
                else
                    if wear_equip[cfg.pos] then
                        attr = config.goods[wear_equip[cfg.pos]].attr
                        cur_power = game.Utils.CalculateCombatPower(attr)
                        goods_power = game.Utils.CalculateCombatPower(cfg.attr)
                        if goods_power <= cur_power then
                            table.insert(equip_list, goods)
                        end
                    else
                        wear_equip[cfg.pos] = cfg.id
                    end
                end
            end
        end
    end
    return equip_list
end

function BagData:GetAdvanceEquipById(id)
    local equip_list = {}
    local equip_type = config.growup[id].equip_type
    for _, v in pairs(self.bag_info or {}) do
        if v.bag.bag_id == 1 then
            for _, goods in pairs(v.bag.goods) do
                local cfg = config.goods[goods.goods.id]
                if cfg.type == equip_type then
                    table.insert(equip_list, goods)
                end
            end
        end
    end
    return equip_list
end

function BagData:CheckExpire()
    local server_time = global.Time:GetServerTime()
    if self.bag_info then
        for _, v in pairs(self.bag_info) do
            for _, value in pairs(v.bag.goods) do
                if value.goods.expire ~= 0 and value.goods.expire <= server_time then
                    return true
                end
            end
        end
    end
    return false
end

function BagData:GetComposeBagItemList()

    local result_table = {}
    local compose_cfg = config.compose

    for _, v in pairs(self.bag_info or {}) do

        if v.bag.bag_id == 1 then

            for _, goods in pairs(v.bag.goods) do

                if compose_cfg[goods.goods.id] then
                    table.insert(result_table, goods)
                end
            end
        end
    end

    return result_table
end

function BagData:GetStonesByTypes(stone_types)

    local stone_id_list = {}
    for k, stone_type in pairs(stone_types) do

        for stone_item_id, v in pairs(config.equip_stone[stone_type]) do

            stone_id_list[stone_item_id] = true
        end
    end

    local result = {}
    for _, v in pairs(self.bag_info or {}) do

        if v.bag.bag_id == 1 then

            for _, goods in pairs(v.bag.goods) do
                if stone_id_list[goods.goods.id] then

                    local item_info = table.clone(goods)
                    if not result[goods.goods.id] then
                        result[goods.goods.id] = item_info
                    else
                        result[goods.goods.id].goods.num = result[goods.goods.id].goods.num + goods.goods.num
                    end
                end
            end
        end
    end

    local new_list = {}
    for k,v in pairs(result) do
        table.insert(new_list, v)
    end

    local sort = function(a, b)
        return a.goods.id < b.goods.id
    end
    table.sort( new_list, sort)

    return new_list
end

function BagData:StorageExtend(data)
    table.insert(self.bag_info, data)
end

function BagData:StorageRename(data)
    for _, v in pairs(self.bag_info) do
        if v.bag.bag_id == data.bag_id then
            v.bag.name = data.name
        end
    end
end

function BagData:GetPosById(id)
    if self.bag_info then
        for _, v in pairs(self.bag_info) do
            for _, value in pairs(v.bag.goods) do
                if value.goods.id == id then
                    return value.goods.pos
                end
            end
        end
    end
end

function BagData:OnBagGetBag(bag)
    if self.bag_info then
        for _, v in pairs(self.bag_info) do
            if v.bag.bag_id == bag.bag_id then
                v.bag = bag
                break
            end
        end
    end
end

function BagData:GetBagItemsByMainType(main_type)

    local result_table = {}
    local goods_cfg = config.goods

    for _, v in pairs(self.bag_info or {}) do

        if v.bag.bag_id == 1 then

            for _, goods in pairs(v.bag.goods) do
                if goods_cfg[goods.goods.id] and goods_cfg[goods.goods.id].type == main_type then
                    table.insert(result_table, goods)
                end
            end
        end
    end

    return result_table
end

function BagData:GetInfoListById(id)
    local info_list = {}
    for _, v in pairs(self.bag_info or {}) do
        for _, value in pairs(v.bag.goods) do
            if value.goods.id == id then
                table.insert(info_list, value.goods)
            end
        end
    end
    return info_list
end

return BagData