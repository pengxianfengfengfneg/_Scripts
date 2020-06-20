local HeroData = Class(game.BaseData)

local _config_hero_effect = config.hero_effect
local _cfg_potential = config.pulse_potential
local _cfg_equip = config.pulse_equip
local _cfg_hero = config.hero
local _cfg_hero_item = config.hero_item
local _cfg_hero_level = config.hero_level

function HeroData:_init()
end

function HeroData:_delete()
end

function HeroData:SetHeroesInfo(info)
    self.hero_info = info
end

function HeroData:GetHeroesInfo()
    return self.hero_info
end

function HeroData:GetHeroInfo(id)
    if self.hero_info then
        for i, v in pairs(self.hero_info.heroes) do
            if v.hero.id == id then
                return v.hero
            end
        end
    end
end

function HeroData:GetHeroGuideInfo(guide_id)
    if self.hero_info then
        for k, v in pairs(self.hero_info.guides) do
            if v.guide.id == guide_id then
                return v.guide
            end
        end
    end
end

function HeroData:SetHeroUpgrade(data)
    for i, v in pairs(self.hero_info.heroes) do
        if v.hero.id == data.id then
            v.hero.level = data.level
            v.hero.exp = data.exp
            break
        end
    end
end

function HeroData:SetHeroOneKeyUpgrade(data)
    for i, v in pairs(self.hero_info.heroes) do
        for k, val in pairs(data.heroes) do
            if v.hero.id == val.hero.id then
                v.hero = val.hero
            end
        end
    end
end

function HeroData:AddHeroActive(hero)
    if self.hero_info then
        table.insert(self.hero_info.heroes, { hero = hero })
    end
end

function HeroData:SetHeroActiveSenior(id)
    if self.hero_info then
        for i, v in pairs(self.hero_info.heroes) do
            if v.hero.id == id then
                v.hero.legend = 1
                break
            end
        end
    end
end

function HeroData:IsHeroActived(hero_id)
    if self.hero_info then
        for _, v in pairs(self.hero_info.heroes) do
            if v.hero.id == hero_id then
                return true,v.hero
            end
        end
    end
    return false,nil
end

function HeroData:OnHeroModifyGuide(data)
    if self.hero_info then
        local is_update = false
        for _, v in ipairs(self.hero_info.guides) do
            if v.guide.id == data.guide.id then
                v.guide.name = data.guide.name
                v.guide.desc = data.guide.desc
                v.guide.plan = data.guide.plan

                is_update = true
                break
            end
        end

        if not is_update then
            table.insert(self.hero_info.guides, data)
        end
    end
end

function HeroData:OnHeroUseGuide(data)

end

function HeroData:GetHeroLengend(hero_id)
    if self.hero_info then
        for _, v in ipairs(self.hero_info.heroes) do
            if v.hero.id == hero_id then
                return v.hero.legend
            end
        end
    end
    return 0
end

local guide_limit = config.sys_config.hero_active_lv.value
function HeroData:IsSkillHasHero(skill_id)
    for k, v in pairs(_config_hero_effect or {}) do
        if v[skill_id] then
            local is_actived,hero_info = self:IsHeroActived(k)
            if is_actived and hero_info.level>guide_limit[2] then
                return true
            end
        end
    end
    return false
end

function HeroData:SetPulseInfo(info)
    self.pulse_info = info
    self:CalcPulseAttr()
end

function HeroData:GetPulseInfo()
    return self.pulse_info
end

function HeroData:GetPulseInfoByID(id)
    for i, v in pairs(self.pulse_info or {}) do
        if v.channel.id == id then
            return v.channel
        end
    end
end

function HeroData:SetActivePulse(data)
    if self.pulse_info == nil then
        return
    end
    local flag = true
    for i, v in pairs(self.pulse_info) do
        if v.channel.id == data.id then
            v.channel = data
            flag = false
            break
        end
    end
    if flag then
        table.insert(self.pulse_info, { channel = data })
    end
end

function HeroData:SetTrainPulse(data)
    for i, v in pairs(self.pulse_info or {}) do
        if v.channel.id == data.id then
            for j, val in pairs(v.channel.potentials) do
                if val.type == data.type then
                    val.val = data.val
                    break
                end
            end
            break
        end
    end
    self:CalcPulseAttr()
end

function HeroData:SetChangePotential(data)
    for i, v in pairs(self.pulse_info or {}) do
        if v.channel.id == data.id then
            for j, val in pairs(v.channel.potentials) do
                if val.type == data.type then
                    val.id = data.attr
                    val.val = data.val
                    break
                end
            end
            break
        end
    end
    self:CalcPulseAttr()
end

function HeroData:SetWearEquip(data)
    for i, v in pairs(self.pulse_info or {}) do
        if v.channel.id == data.id then
            v.channel.equips = data.equips
            break
        end
    end
    self:CalcPulseAttr()
end

function HeroData:SetTreasureInfo(info)
    self.treasure_info = info
end

function HeroData:GetTreasureInfo()
    return self.treasure_info
end

function HeroData:SetDrawTimes(data)
    if self.treasure_info then
        self.treasure_info.times = data.times
        self.treasure_info.week_times = data.week_times
    end
end

function HeroData:SetTreasreReward(data)
    if self.treasure_info then
        table.insert(self.treasure_info.acc, data)
    end
end

function HeroData:CalcPulseAttr()
    -- 英雄属性、潜能属性、装备属性
    self.pulse_attr = {}
    self.pulse_fight_info = {}

    local attrs = {}
    for i, v in pairs(self.pulse_info) do
        local channel_id = v.channel.id
        local channel_attr = {}

        if v.channel.hero ~= 0 then
            local hero_info = game.HeroCtrl.instance:GetHeroInfo(v.channel.hero)
            local career = game.RoleCtrl.instance:GetCareer()
            local attr_pulse = config.hero_level[v.channel.hero][hero_info.level].attr_pulse[career]
            table.insert(channel_attr, attr_pulse)
            table.insert(attrs, attr_pulse)
        end

        local pulse_potential_info = {}
        for j, val in pairs(v.channel.potentials) do
            local cfg = _cfg_potential[val.id]
            local value = math.floor(cfg.limit * val.val / 10000)
            if value > 0 then
                local attr_potential = { val.id, value }
                table.insert(channel_attr, attr_potential)
                table.insert(attrs, attr_potential)
            end
            pulse_potential_info[val.type] = val.id
        end

        for j, val in pairs(v.channel.equips) do
            local equip_cfg = _cfg_equip[val.id]
            local add_attr = equip_cfg.base_attr
            for k, value in pairs(equip_cfg.heros) do
                if value == v.channel.hero then
                    add_attr = equip_cfg.pro_attr
                end
            end
            local pos_table = {}
            for k, value in pairs(config.pulse_potential_pos) do
                pos_table[value.pos] = k
            end
            for k, value in pairs(add_attr) do
                if value[1] == pulse_potential_info[pos_table[val.pos]] then
                    table.insert(channel_attr, value)
                    table.insert(attrs, value)
                    break
                end
            end
        end

        self.pulse_fight_info[channel_id] = game.Utils.CalculateCombatPower2(channel_attr)
    end

    for i, v in ipairs(attrs) do
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

function HeroData:GetPulseChannelFight(id)
    return self.pulse_fight_info[id] or 0
end

function HeroData:GetPulseAttr()
    return self.pulse_attr or {}
end

function HeroData:GetPulseFight()
    return self.pulse_fight or 0
end

function HeroData:CanUpgrade(hero_id)
    local hero_info = self:GetHeroInfo(hero_id)
    if hero_info and hero_info.level < #_cfg_hero_level[hero_id] then
        return true
    else
        return false
    end
end

function HeroData:GetHeroTipState(hero_id)
    if self:CanUpgrade(hero_id) == false then
        return false
    end
    local cfg = _cfg_hero[hero_id]
    local own = game.BagCtrl.instance:GetNumById(cfg.item_id)
    if own > 0 then
        return true
    end
    local upgrade_item_id = cfg.item_id
    for k, v in pairs(_cfg_hero_item) do
        if v.color == cfg.color then
            upgrade_item_id = k
        end
    end
    own = game.BagCtrl.instance:GetNumById(upgrade_item_id)
    return own > 0
end

function HeroData:GetHeroChipTipState(hero_id)
    if self:CanUpgrade(hero_id) == false then
        return false
    end
    local cfg = _cfg_hero[hero_id]
    local own = game.BagCtrl.instance:GetNumById(cfg.item_id)
    return own > 0
end

function HeroData:GetAllChipTipState()
    for _, v in pairs(_cfg_hero) do
        if self:GetHeroChipTipState(v.id) then
            return true
        end
    end
    return false
end

function HeroData:GetTipState()
    for _, v in pairs(_cfg_hero) do
        if self:GetHeroTipState(v.id) then
            return true
        end
    end
    return false
end

function HeroData:GetBookFight()
    local hero_info = self:GetHeroesInfo()
    local total_attr = {}
    for _, v in pairs(hero_info.heroes) do
        for _, val in ipairs(config.hero_level[v.hero.id][v.hero.level].attr) do
            table.insert(total_attr, val)
        end
    end
    local attr = {}
    for _, v in pairs(total_attr) do
        if attr[v[1]] then
            attr[v[1]] = attr[v[1]] + v[2]
        else
            attr[v[1]] = v[2]
        end
    end
    total_attr = {}
    for i, v in pairs(attr) do
        table.insert(total_attr, { i, v })
    end
    return game.Utils.CalculateCombatPower2(total_attr)
end

return HeroData
