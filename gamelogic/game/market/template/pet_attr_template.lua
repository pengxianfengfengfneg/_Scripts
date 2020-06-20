local PetAttrTemplate = Class(game.UITemplate)

local function potential(init_val, star_add, savvy_add)
    return math.floor(init_val * (1 + star_add / 10000) * (1 + savvy_add / 10000))
end

function PetAttrTemplate:_init(view, info)
    self.info = info
    self.ctrl = game.MarketCtrl.instance
end

function PetAttrTemplate:OpenViewCallBack()
    self:Init(self.info)
end

function PetAttrTemplate:Init(info)
    local star_add = config.pet_star[info.star] or 0
    local savvy_cfg = config.pet_savvy[info.savvy_lv]
    local cur_potential = {}
    cur_potential[1] = potential(info.potential.power, star_add, savvy_cfg.potential_addon)
    cur_potential[2] = potential(info.potential.anima, star_add, savvy_cfg.potential_addon)
    cur_potential[3] = potential(info.potential.energy, star_add, savvy_cfg.potential_addon)
    cur_potential[4] = potential(info.potential.concent, star_add, savvy_cfg.potential_addon)
    cur_potential[5] = potential(info.potential.method, star_add, savvy_cfg.potential_addon)

    for i = 1, 5 do
        self._layout_objs["quality" .. i]:SetText(cur_potential[i])
    end

    table.sort(info.init_attr, function(a, b)
        return a.type < b.type
    end)
    for i, v in ipairs(info.init_attr) do
        self._layout_objs["base_text" .. i]:SetText(config.combat_power_base[v.type].name)
        self._layout_objs["base_attr" .. i]:SetText(v.value)
    end

    local max_hp = 0
    local bt_attr = {}
    for _, v in pairs(info.bt_attr) do
        if v.type == 1 then
            max_hp = v.value
        else
            table.insert(bt_attr, v)
        end
    end
    self._layout_objs.txt_hp:SetText(max_hp)

    table.sort(bt_attr, function(a, b)
        return a.type < b.type
    end)
    for i = 1, 8 do
        if bt_attr[i] then
            self._layout_objs["bt_text" .. i]:SetText(config.combat_power_battle[bt_attr[i].type].name)
            self._layout_objs["bt_attr" .. i]:SetText(bt_attr[i].value)
        end
    end
end

return PetAttrTemplate