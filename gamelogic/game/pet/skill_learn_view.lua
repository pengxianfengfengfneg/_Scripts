local LearnSkillView = Class(game.BaseView)

function LearnSkillView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "skill_learn_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function LearnSkillView:OnEmptyClick()
    self:Close()
end

function LearnSkillView:OpenViewCallBack(pet, grid)
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1533])

    self._layout_objs.btn_learn:SetGray(true)
    self._layout_objs.btn_learn:AddClickCallBack(function()
        if self.cur_skill then
            self.ctrl:SendLearnSkill(pet, grid, self.cur_skill.id)
            self:Close()
        end
    end)

    self.goods_item = self:GetTemplate("game/skill/item/skill_item_rect", "skill_item")
    self.goods_item:ResetItem()
    self.goods_item:SetShowInfo()

    local skill_type = 1
    if grid == 0 then
        self._layout_objs.btn_label1:SetText(config.words[1535])
    else
        self._layout_objs.btn_label1:SetText(config.words[1536])
        skill_type = 2
    end

    local skill_list = {}
    for i, v in pairs(config.pet_skill) do
        if v.type == skill_type then
            table.insert(skill_list, v)
        end
    end
    table.sort(skill_list, function(a, b)
        local a_own = game.BagCtrl.instance:GetNumById(a.cost_id)
        local b_own = game.BagCtrl.instance:GetNumById(b.cost_id)
        return a_own > b_own
    end)

    self.list = self:CreateList("list", "game/skill/item/skill_item_rect")
    self.list:AddClickItemCallback(function(obj)
        self:SetSelectSkill(obj:GetItemInfo())
    end)
    self.list:SetRefreshItemFunc(function(item, index)
        local skill = skill_list[index]
        item:SetItemInfo(skill)
        local own = game.BagCtrl.instance:GetNumById(skill.cost_id)
        item:SetGray(own == 0)
        item:SetSelect(false)
        item:SetLevelText(own)
    end)
    self.list:SetItemNum(#skill_list)

    self:SetSelectSkill(skill_list[1])
end

function LearnSkillView:SetSelectSkill(skill)
    self.cur_skill = skill
    if skill then
        local skill_lv_cfg = config.skill[skill.id][1]
        self._layout_objs.name:SetText(skill_lv_cfg.name)
        self._layout_objs.type:SetText(config.words[1510 + skill.fit_type])
        self._layout_objs.normal_desc:SetText(skill.normal)
        self.list:Foreach(function(obj)
            local info = obj:GetItemInfo()
            obj:SetSelect(skill.id == info.id)
        end)
        self.goods_item:SetItemInfo({id = skill.id})

        local own = game.BagCtrl.instance:GetNumById(skill.cost_id)
        local upgrade_cfg = config.pet_skill_upgrade[1]
        local skill_cfg = config.pet_skill[skill.id]
        local num = skill_cfg.cost_num
        self.goods_item:SetLevelText(own .. "/" .. num)
        self._layout_objs.btn_learn:SetTouchEnable(own >= num)
        self._layout_objs.btn_learn:SetGray(own < num)

        self._layout_objs.ratio:SetText(string.format(config.words[1510], math.floor(upgrade_cfg.upgrade_rate / 100 )))
    end
end

return LearnSkillView