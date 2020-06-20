local PulseTemplate = Class(game.UITemplate)

local cfg_potential = config.pulse_potential
local cfg_equip = config.pulse_equip

function PulseTemplate:_init(parent, info)
    self.parent_view = parent
    self.pulse_info = info.channels
    self.info = info.info
end

function PulseTemplate:OpenViewCallBack()
    self.power = self._layout_objs["role_fight_com/txt_fight"]
    self._layout_objs["role_fight_com/btn_look"]:SetVisible(false)
    self:CalcPulseAttr()
    self:InitList()
    self:SetPulseItem()
    self:UpdateFight()
end

function PulseTemplate:InitList()
    self.list = self:CreateList("list", "game/hero/item/attr_list_item2")

    self.list:SetRefreshItemFunc(function(item, idx)
        item:SetItemInfo({ self.attr_list[idx * 2 - 1], self.attr_list[idx * 2] })
        item:SetBg(idx % 2 == 1)
    end)
end

function PulseTemplate:SetPulseItem()
    self.pulse_items = {}
    for _, v in pairs(config.pulse) do
        self.pulse_items[v.id] = self:GetTemplate("game/hero/item/pulse_item", "pulse_item" .. v.id)
        self.pulse_items[v.id]:SetOthersMode()
        self.pulse_items[v.id]:SetOthersInfo(self.info.level, self:GetPulseInfoByID(v.id))
        self.pulse_items[v.id]:SetPulseInfo(v)
    end
end

function PulseTemplate:UpdateFight()
    self.power:SetText(self.pulse_fight)

    self.attr_list = {}
    for k, v in pairs(self.pulse_attr) do
        table.insert(self.attr_list, { k, v })
    end
    self.list:SetItemNum(math.ceil(#self.attr_list / 2))
end

function PulseTemplate:CalcPulseAttr()
    -- 英雄属性、潜能属性、装备属性
    self.pulse_attr = {}
    local attrs = {}
    for _, v in pairs(self.pulse_info) do
        if v.channel.hero ~= 0 then
            local career = self.info.career
            local attr_pulse = config.hero_level[v.channel.hero][v.channel.level].attr_pulse[career]
            table.insert(attrs, attr_pulse)
        end

        local pulse_potential_info = {}
        for _, val in pairs(v.channel.potentials) do
            local cfg = cfg_potential[val.id]
            local value = math.floor(cfg.limit * val.val / 10000)
            if value > 0 then
                table.insert(attrs, { val.id, value })
            end
            pulse_potential_info[val.type] = val.id
        end

        for _, val in pairs(v.channel.equips) do
            local equip_cfg = cfg_equip[val.id]
            local add_attr = equip_cfg.base_attr
            for _, value in pairs(equip_cfg.heros) do
                if value == v.channel.hero then
                    add_attr = equip_cfg.pro_attr
                end
            end
            local pos_table = {}
            for k, value in pairs(config.pulse_potential_pos) do
                pos_table[value.pos] = k
            end
            for _, value in pairs(add_attr) do
                if value[1] == pulse_potential_info[pos_table[val.pos]] then
                    table.insert(attrs, value)
                    break
                end
            end
        end
    end

    for _, v in ipairs(attrs) do
        if self.pulse_attr[v[1]] then
            self.pulse_attr[v[1]] = self.pulse_attr[v[1]] + v[2]
        else
            self.pulse_attr[v[1]] = v[2]
        end
    end

    self.pulse_fight = 0
    for k, v in pairs(self.pulse_attr) do
        if k < 100 then
            self.pulse_fight = self.pulse_fight + config.combat_power_battle[k].value * v
        else
            self.pulse_fight = self.pulse_fight + config.combat_power_base[k - 100].value * v
        end
    end
end

function PulseTemplate:GetPulseInfoByID(id)
    for _, v in pairs(self.pulse_info or {}) do
        if v.channel.id == id then
            return v.channel
        end
    end
end

return PulseTemplate