local PetSkillTemplate = Class(game.UITemplate)

function PetSkillTemplate:OpenViewCallBack()
    self.skills = {}
    for i = 0, 8 do
        self.skills[i] = self:GetTemplate("game/skill/item/skill_item_rect", "skill" .. i)
    end
end

local function potential(init_val, star_add, savvy_add)
    return math.floor(init_val * (1 + star_add / 10000) * (1 + savvy_add / 10000))
end

function PetSkillTemplate:SetSkill(info)
    if info then
        self._layout_objs.lv:SetText(info.savvy_lv .. config.words[1217])

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
    else
        self:Reset()
    end
end

function PetSkillTemplate:Reset()
    self._layout_objs.lv:SetText("")
    for i = 0, 8 do
        self.skills[i]:ResetItem()
    end
    for i = 1, 5 do
        self._layout_objs["quality" .. i]:SetText("")
    end
end

return PetSkillTemplate