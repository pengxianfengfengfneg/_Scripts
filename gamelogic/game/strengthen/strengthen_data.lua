local StrengthenData = Class(game.BaseData)

function StrengthenData:_init(ctrl)
    self.ctrl = ctrl

    self.grade_config = {}
    for k, v in pairs(config.strengthen_grade) do
        self.grade_config[v.type] = self.grade_config[v.type] or {}
        table.insert(self.grade_config[v.type], v)
    end
    for k, v in pairs(self.grade_config) do
        table.sort(self.grade_config[k], function(m, n)
            return m.id < n.id
        end)
    end

    for k, v in pairs(config.strengthen_cate_func) do
        for _, cv in pairs(v) do
            local func_list = config.strengthen_func[cv.func_id]
            for _, func in pairs(func_list or game.EmptyTable) do
                func.cate_id = cv.id
            end
        end
    end
end

function StrengthenData:GetTitleList(type)
    local title_list = {}
    for k, v in pairs(config.strengthen_title) do
        if v.type == type then
            table.insert(title_list, v)
        end
    end
    table.sort(title_list, function(m, n)
        return m.id < n.id
    end)
    return title_list
end

function StrengthenData:GetTagList(type)
    local tag_list = {}
    for k, v in pairs(config.strengthen_tag) do
        if v.type == type and self:IsMeetCond(v.cond) then
            table.insert(tag_list, v)
        end
    end
    table.sort(tag_list, function(m, n)
        return m.id < n.id
    end)
    return tag_list
end

function StrengthenData:GetFuncList(cate_id)
    local func_list = {}
    for k, v in pairs(config.strengthen_cate_func[cate_id] or game.EmptyTable) do
        if config.strengthen_func[v.func_id] and self:IsMeetCond(v.cond) and self:CanShowFunc(v.func_id) then
            table.insert(func_list, v)
        end
    end
    table.sort(func_list, function(m, n)
        return m.sort < n.sort
    end)
    return func_list
end

function StrengthenData:GetFuncChildList(func_id)
    local func_child_list = {}
    for k, v in pairs(config.strengthen_func[func_id] or game.EmptyTable) do
        if self:CanShowFunc(v.func_id, v.id) then
            table.insert(func_child_list, v)
        end
    end
    table.sort(func_child_list, function(m, n)
        return m.id < n.id
    end)
    return func_child_list
end

function StrengthenData:GetCateList(tag_id)
    local cate_list = {}
    for k, v in pairs(config.strengthen_cate[tag_id] or game.EmptyTable) do
		table.insert(cate_list, v)
	end
	table.sort(cate_list, function(m, n)
		return m.cate_id < n.cate_id
    end)
    return cate_list
end

function StrengthenData:IsMeetCond(cond)
    if not cond or not cond[1] then
        return true
    else
        local type = cond[1]
        if type == 1 then
            local role_lv = game.RoleCtrl.instance:GetRoleLevel()
            return role_lv >= cond[2]
        end
    end
end

function StrengthenData:GetCateInfo(func_id)
    for k, v in pairs(config.strengthen_func[func_id] or game.EmptyTable) do
        return v
    end
end

function StrengthenData:GetGrade(type, idx)
    local grade_cfg = self.grade_config[type][idx]
    return string.format("[color=%s]%s[/color]", grade_cfg.color, grade_cfg.name)
end

function StrengthenData:GetTotalFight(type)
    local fight = 0
    local tag_list = self:GetTagList(type)

    for _, v in pairs(tag_list) do
        local func_list = self:GetFuncList(v.id)
        for _, cv in pairs(func_list) do
            fight = fight + self:GetFightByFuncId(cv.func_id)
        end
    end

    return fight
end

function StrengthenData:GetFightByFuncId(func_id)
    local func_list = config.strengthen_func[func_id]
    local fight = 0
    for k, v in pairs(func_list or game.EmptyTable) do
        fight = fight + self:GetFuncFight(v.func_type)
    end
    return fight
end

local CombatConfig = {
    [1] = function(self)
        return self:GetTotalEquipCombat()
    end,
    [2] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(1)
    end,
    [3] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(2)
    end,    
    [4] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(3)
    end,
    [5] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(4)
    end,
    [6] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(5)
    end,
    [7] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(6)
    end,
    [8] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(7)
    end,
    [9] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(8)
    end,
    [10] = function(self)
        return self:GetTotalStoneLv()
    end,
    [11] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(1)
    end,
    [12] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(2)
    end,
    [13] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(3)
    end,
    [14] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(4)
    end,
    [15] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(5)
    end,
    [16] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(6)
    end,
    [17] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(7)
    end,
    [18] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(8)
    end,
    [19] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(9)
    end,
    [20] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(10)
    end,
    [21] = function(self)
        return self:GetBattlePetFight()
    end,
    [22] = function(self)
        return math.floor(self:GetTotalAttachFight())
    end,
    [23] = function()
        return math.floor(game.PetCtrl.instance:GetAttach(1))
    end,
    [24] = function()
        return math.floor(game.PetCtrl.instance:GetAttach(2))
    end,
    [25] = function()
        return math.floor(game.PetCtrl.instance:GetAttach(3))
    end,
    [26] = function()
        return math.floor(game.PetCtrl.instance:GetAttach(4))
    end,
    [27] = function()
        return game.HeroCtrl.instance:GetBookFight()
    end,
    [28] = function()
        return game.HeroCtrl.instance:GetPulseFight()
    end,
    [29] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(1)
    end,
    [30] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(2)
    end,
    [31] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(3)
    end,
    [32] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(4)
    end,
    [33] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(5)
    end,
    [34] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(6)
    end,
    [35] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(7)
    end,
    [36] = function()
        return game.HeroCtrl.instance:GetPulseChannelFight(8)
    end,
    [37] = function()
        local id = game.RoleCtrl.instance:GetRoleHonor()
        return config.title_honor[id].level
    end,
    [38] = function()
        return game.GuildCtrl.instance:GetPracticeTotalLv()
    end,
    [39] = function()
        return game.FoundryCtrl.instance:GetSmeltLv()
    end,
    [40] = function(self)
        return self:GetSKillTotalLv()
    end,
    [41] = function(self)
        self:GetSkillLv(1)
    end,
    [42] = function(self)
        self:GetSkillLv(2)
    end,
    [43] = function(self)
        self:GetSkillLv(3)
    end,
    [44] = function(self)
        self:GetSkillLv(4)
    end,
    [45] = function(self)
        self:GetSkillLv(5)
    end,
    [46] = function(self)
        self:GetSkillLv(6)
    end,
    [47] = function(self)
        self:GetSkillLv(7)
    end,
    [48] = function(self)
        self:GetSkillLv(8)
    end,
    [49] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(9)
    end,
    [50] = function()
        return game.FoundryCtrl.instance:GetEquipCombat(10)
    end,
    [51] = function()
        return math.floor(game.PetCtrl.instance:GetAttach(5))
    end,
    [52] = function(self)
        return self:GetTotalStrenLv()
    end,
    [53] = function()
        return game.WeaponSoulCtrl.instance:GetCombatPower()
    end,
    [54] = function()
        return game.DragonDesignCtrl.instance:GetAttrCombatPower()
    end,
    [55] = function()
        return game.FoundryCtrl.instance:GetStrenLv(1)
    end,
    [56] = function()
        return game.FoundryCtrl.instance:GetStrenLv(2)
    end,
    [57] = function()
        return game.FoundryCtrl.instance:GetStrenLv(3)
    end,
    [58] = function()
        return game.FoundryCtrl.instance:GetStrenLv(4)
    end,
    [59] = function()
        return game.FoundryCtrl.instance:GetStrenLv(5)
    end,
    [60] = function()
        return game.FoundryCtrl.instance:GetStrenLv(6)
    end,
    [61] = function()
        return game.FoundryCtrl.instance:GetStrenLv(7)
    end,
    [62] = function()
        return game.FoundryCtrl.instance:GetStrenLv(8)
    end,
    [63] = function()
        return game.FoundryCtrl.instance:GetStrenLv(9)
    end,
    [64] = function()
        return game.FoundryCtrl.instance:GetStrenLv(10)
    end,
    [65] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(11)
    end,
    [66] = function()
        return game.FoundryCtrl.instance:GetStoneMinLvByPos(12)
    end,
    [67] = function()
        return game.FoundryCtrl.instance:GetStrenLv(11)
    end,
    [68] = function()
        return game.FoundryCtrl.instance:GetStrenLv(12)
    end,
}

function StrengthenData:GetFuncFight(func_type)
    local fight = 0
    local cfg = CombatConfig[func_type]
    if cfg then
        fight = cfg(self) or 0
    end
    return fight
end

function StrengthenData:GetSKillTotalLv()
    local skill_list = game.SkillCtrl.instance:GetSkillList()
    local level = 0
    for k, v in pairs(skill_list or game.EmptyTable) do
        level = level + v.lv
    end
    return level
end

function StrengthenData:GetSkillLv(id)
    local skill_list = game.SkillCtrl.instance:GetSkillList()
    if skill_list[id] then
        return skill_list[id].lv
    else
        return 0
    end
end

function StrengthenData:GetTotalEquipCombat()
    local combat = 0
    for i=1, 8 do
        combat = combat + game.FoundryCtrl.instance:GetEquipCombat(i)
    end
    return combat
end

function StrengthenData:GetTotalStoneLv()
    local combat = 0
    for i=1, 10 do
        combat = combat + game.FoundryCtrl.instance:GetStoneMinLvByPos(i)
    end
    return combat
end

function StrengthenData:GetTotalAttachFight()
    local total_fight = 0
    for _, v in ipairs(config.pet_zhenfa) do
        local info = game.PetCtrl.instance:GetAttach(v.id)
        if info then
            total_fight = total_fight + info.fight
        end
    end
    return total_fight
end

function StrengthenData:GetBattlePetFight()
    local pet_info = game.PetCtrl.instance:GetFightingPet()
    if pet_info then
        return game.PetCtrl.instance:CalcFight(pet_info)
    else
        return 0
    end
end

function StrengthenData:IsFinishFunc(func_id, id)
    local info = config.strengthen_func[func_id][id]
    if info.func_type == 0 then
        return true
    else
        local fight = self:GetFuncFight(info.func_type)
        local max_val = info.params[#info.params]
        return fight >= max_val
    end
end

function StrengthenData:CanShowFunc(func_id, id)
    id = id or 0
    local info = config.strengthen_func[func_id][id]

    if not self:IsMeetCond(info.cond) then
        return false
    end

    if info.finish_hide == 1 then
        if id ~= 0 then
            if self:IsFinishFunc(func_id, id) then
                return false
            end
        else
            local func_list = config.strengthen_func[func_id]
            for k, v in pairs(func_list or game.EmptyTable) do
                if not self:IsFinishFunc(v.func_id, v.id) then
                    return true
                end
            end
            return false
        end
    end

    return true
end

function StrengthenData:GetTotalStrenLv()
    local stren_lv = 0
    for i=1, 10 do
        stren_lv = stren_lv + game.FoundryCtrl.instance:GetStrenLv(i)
    end
    return stren_lv
end

return StrengthenData