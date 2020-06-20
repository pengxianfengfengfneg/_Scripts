local PetSkillTemplate = Class(game.UITemplate)

function PetSkillTemplate:OpenViewCallBack()
    self.skills = {}
    for i = 0, 8 do
        self.skills[i] = self:GetTemplate("game/skill/item/skill_item_rect", "skill" .. i)
    end
end

local function potential(init_val, star_add, savvy_add)
    return math.floor(init_val * (1 + star_add / 10000) * (1 + savvy_add / 10000)), math.floor(init_val * (1 + star_add / 10000) * savvy_add / 10000)
end

function PetSkillTemplate:SetSkill(info)
    self._layout_objs.lv:SetText(info.savvy_lv .. config.words[1217])

    local star_add = config.pet_star[info.star] or 0
    local savvy_cfg = config.pet_savvy[info.savvy_lv]
    local cur_potential = {}
    local savvy_add = {}
    cur_potential[1], savvy_add[1] = potential(info.potential.power, star_add, savvy_cfg.potential_addon)
    cur_potential[2], savvy_add[2] = potential(info.potential.anima, star_add, savvy_cfg.potential_addon)
    cur_potential[3], savvy_add[3] = potential(info.potential.energy, star_add, savvy_cfg.potential_addon)
    cur_potential[4], savvy_add[4] = potential(info.potential.concent, star_add, savvy_cfg.potential_addon)
    cur_potential[5], savvy_add[5] = potential(info.potential.method, star_add, savvy_cfg.potential_addon)

    for i = 1, 5 do
        if savvy_add[i] > 0 then
            self._layout_objs["quality" .. i]:SetText(string.format("%d[color=#367a21](+%d)[/color]", cur_potential[i], savvy_add[i]))
        else
            self._layout_objs["quality" .. i]:SetText(cur_potential[i])
        end
    end

    for i = 0, 8 do
        self.skills[i]:ResetItem()
    end
    for _, v in pairs(info.skills) do
        self.skills[v.grid]:SetItemInfo({ id = v.id, lv = v.lv })
        self.skills[v.grid]:SetShowInfo()
    end

    for i = savvy_cfg.skill_grid + 1, 8 do
        self.skills[i]:SetLockVisible(true)
    end
end

return PetSkillTemplate