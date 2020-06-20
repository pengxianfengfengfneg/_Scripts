local PetTrainSkillTemplate = Class(game.UITemplate)

function PetTrainSkillTemplate:OpenViewCallBack()
    self:InitBtn()
    self.skills = {}
    for i = 0, 8 do
        self.skills[i] = self:GetTemplate("game/skill/item/skill_item_rect", "skill" .. i)
        self.skills[i]:SetAddCallBack(function()
            game.PetCtrl.instance:OpenSkillLearnView(self.info.grid, i)
        end)
        self.skills[i]:AddClickEvent(function()
            if self.info then
                local skill_info
                for _, v in pairs(self.info.skills) do
                    if v.grid == i then
                        skill_info = v
                        break
                    end
                end
                if skill_info then
                    local pet_cfg = config.pet[self.info.cid]
                    local upgrade_cfg = config.pet_skill_upgrade[skill_info.lv]
                    if skill_info.lv >= #config.pet_skill_upgrade or (upgrade_cfg.carry_lv > pet_cfg.carry_lv and pet_cfg.quality ~= 2) then
                        game.PetCtrl.instance:OpenSkillSuperView(self.info.grid, skill_info)
                    else
                        if upgrade_cfg.carry_lv == 0 then
                            game.PetCtrl.instance:OpenSkillUpgradeView(self.info.grid, skill_info)
                        else
                            game.PetCtrl.instance:OpenSkillSeniorView(self.info.grid, skill_info)
                        end
                    end
                end
            end
        end)
    end
end

function PetTrainSkillTemplate:InitBtn()
    self._layout_objs.btn_commend:AddClickCallBack(function()
        game.PetCtrl.instance:OpenCommendView()
    end)

    self._layout_objs.btn_preview:AddClickCallBack(function()
        game.PetCtrl.instance:OpenSkillPreview()
    end)
end

function PetTrainSkillTemplate:SetSkill(info)
    self.info = info
    local savvy_cfg = config.pet_savvy[info.savvy_lv]
    for i = 0, 8 do
        self.skills[i]:ResetItem()
    end
    local active_add = true
    for _, v in ipairs(info.skills) do
        if v.grid == 0 then
            active_add = false
        end
        self.skills[v.grid]:SetItemInfo(v)
    end
    self.skills[0]:SetBtnAddVisible(active_add)
    local skill_num = #info.skills
    local max_skill_num = savvy_cfg.skill_grid
    if active_add == false then
        skill_num = skill_num - 1
        max_skill_num = max_skill_num + 1
    end
    if #info.skills < max_skill_num then
        self.skills[skill_num + 1]:SetBtnAddVisible(true)
    end
    local skill_grid_t = {}
    for i = 5, 8 do
        for j = 0, 15 do
            if config.pet_savvy[j].skill_grid == i then
                skill_grid_t[i] = j
                break
            end
        end
    end
    for i = savvy_cfg.skill_grid + 1, 8 do
        if skill_grid_t[i] then
            self.skills[i]:SetOpenText(string.format(config.words[1483], skill_grid_t[i]))
        end
    end
end

return PetTrainSkillTemplate