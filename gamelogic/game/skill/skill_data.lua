local SkillData = Class(game.BaseData)

local config_skill = config.skill
local config_skill_career = config.skill_career
local config_hero_effect = config.hero_effect

local type = type
local table_nums = table.nums
local table_clone = table.clone

local _et = {}

function SkillData:_init()
    self.skill_list = {}

    self.skill_setting_value = 0

    self.backup_skill_config = table.clone(config_skill)
end

function SkillData:_delete()

end

function SkillData:InitSkillList(data_list)
    -- "skill_list__T__id@I##lv@H##hero@C##legend@C",
    self.skill_list = data_list.skill_list or {}
end

-- function SkillData:OnSkillGetInfo(data)
--     self.skill_list = data.skills
-- end

function SkillData:OnSkillActive(data)
    --table.insert(self.skill_list, data)
end

function SkillData:OnSkillUpgrade(data)
    for _,v in ipairs(self.skill_list or {}) do
        if v.id == data.id then
            v.lv = data.lv
            break
        end
    end
end

function SkillData:OnSkillOneKeyUp(data)
    for _,v in ipairs(data.skills or {}) do
        self:OnSkillUpgrade(v)
    end
end

function SkillData:OnSkillNew(data)
    for _,v in ipairs(data.skills or {}) do
        v.legend = 0
        v.hero = 0
        table.insert(self.skill_list, v)
    end
end

function SkillData:IsSkillActived(skill_id)
    for _,v in ipairs(self.skill_list) do
        if v.id == skill_id then
            return true
        end
    end
    return false
end

function SkillData:GetSkillLv(skill_id)
    for _,v in ipairs(self.skill_list) do
        if v.id == skill_id then
            return v.lv
        end
    end
    return 0
end

function SkillData:GetSkillLvUpCost(skill_id, skill_lv)
    local skill_cfg = config_skill[skill_id] or {}
    local lv_cfg = skill_cfg[skill_lv] or {}
    return lv_cfg.cost or 0
end

function SkillData:CanSkillUpgrade(skill_id, skill_lv)
    local cfg = config_skill[skill_id]
    if cfg[1].type ~= game.SkillType.Active then
        return false
    end

    if not self.skill_career_cfg then
        local career = game.Scene.instance:GetMainRoleCareer()
        self.skill_career_cfg = config_skill_career[career]
    end

    local is_check = false
    for _,v in pairs(self.skill_career_cfg or _et) do
        if skill_id == v.skill_id then
            is_check = true
            break
        end
    end

    if not is_check then
        return false
    end

    local lv_max = game.Scene.instance:GetMainRoleLevel()
    local cfg_max = #(cfg or {})

    local max_lv = math.min(lv_max, cfg_max)
    if skill_lv+1 > max_lv then
        return false,1
    end

    local cost = self:GetSkillLvUpCost(skill_id, skill_lv)
    local cur_copper = game.BagCtrl.instance:GetCopper()
    return cur_copper>=cost,2
end

function SkillData:CanSkillUpgradeAny()
    if not self.skill_career_cfg then
        local career = game.Scene.instance:GetMainRoleCareer()
        self.skill_career_cfg = config_skill_career[career]
    end

    local result = 1
    for _,v in pairs(self.skill_career_cfg or _et) do
        local skill_id = v.skill_id
        local skill_lv = self:GetSkillLv(skill_id)

        local is_can,res = self:CanSkillUpgrade(skill_id, skill_lv)
        result = res
        if is_can then
            return true
        end
    end
    return false,result
end

function SkillData:GetAllActiveSkillCost()
    local cost = 0
    local max_lv = game.RoleCtrl.instance:GetRoleLevel()
    for _,v in ipairs(self.skill_list) do
        local skill_cfg = (config_skill[v.id] or _et)[1] or {}
        if skill_cfg.type == game.SkillType.Active then
            for i=v.lv,max_lv-1 do
                cost = cost + self:GetSkillLvUpCost(v.id, i)
            end
        end
    end
    return cost
end

function SkillData:OnGetSettingInfo()
    self.skill_setting_value = game.SysSettingCtrl.instance:GetInt(game.CommonlyKey.SkillSetting)
end

function SkillData:SetSkillSettingValue(idx, is_selected)
    if self:IsSkillSettingActived(idx) == is_selected then
        return self.skill_setting_value
    end

    local val = (is_selected and 0 or 1)
    local set_val = (1<<idx)*(is_selected and -1 or 1)
    self.skill_setting_value = self.skill_setting_value + set_val

    return self.skill_setting_value
end

function SkillData:IsSkillSettingActived(idx)
    local target_val = (1<<idx)
    return not ((self.skill_setting_value&target_val)==target_val)
end

function SkillData:IsSkillSettingActivedForId(skill_id)
    if not self.skill_career_cfg then
        local career = game.RoleCtrl.instance:GetCareer()
        self.skill_career_cfg = config_skill_career[career]
    end

    local idx = nil
    for _,v in pairs(self.skill_career_cfg or _et) do
        if v.skill_id == skill_id then
            idx = v.index
            break
        end
    end

    if idx then
        return self:IsSkillSettingActived(idx)
    end
    return true
end

function SkillData:GetSkillHeroId(skill_id)
    for _,v in ipairs(self.skill_list) do
        if v.id == skill_id then
            return v.hero
        end
    end
    return 0
end

function SkillData:GetSkillLegend(skill_id)
    for _,v in ipairs(self.skill_list) do
        if v.id == skill_id then
            return v.legend
        end
    end
    return 0
end

function SkillData:GetSkillHeroLegend(skill_id)
    for _,v in ipairs(self.skill_list) do
        if v.id == skill_id then
            return v.hero,v.legend
        end
    end
    return 0,0
end

function SkillData:SetSkillGuide(skill_id, hero_id, legend)
    for _,v in ipairs(self.skill_list) do
        if v.id == skill_id then
            v.hero = hero_id
            v.legend = legend

            self:FireEvent(game.SkillEvent.UpdateSkillInfo,v)

            break
        end
    end
end

function SkillData:IsSkillUsedHero(skill_id)
    for _,v in ipairs(self.skill_list) do
        if v.id == skill_id then
            return v.hero>0
        end
    end
    return false
end

function SkillData:IsHeroUsed(hero_id)
    for _,v in ipairs(self.skill_list) do
        if v.hero == hero_id then
            return true
        end
    end
    return false
end

function SkillData:OnGuideChange(data)
    self:SetSkillGuide(data.skill, data.id, data.legend)
end

function SkillData:OnHeroUseGuide(data)
    for _,v in ipairs(data or {}) do
        self:SetSkillGuide(v.id, v.hero, v.legend)
    end
end

function SkillData:GetSkillList()
    return self.skill_list
end

return SkillData
