local SkillSeniorView = Class(game.BaseView)

function SkillSeniorView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "skill_senior_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function SkillSeniorView:OnEmptyClick()
    self:Close()
end

function SkillSeniorView:OpenViewCallBack(pet, skill)
    self.pet_grid = pet
    self.cur_skill = skill
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1533])

    self:BindEvent(game.PetEvent.PetChange, function(data)
        if data.grid == pet then
            local pet_cfg = config.pet[data.cid]
            for i, v in pairs(data.skills) do
                if v.grid == skill.grid then
                    local upgrade_cfg = config.pet_skill_upgrade[v.lv]
                    if (pet_cfg.carry_lv < upgrade_cfg.carry_lv and pet_cfg.quality ~= 2) or v.lv >= #config.pet_skill_upgrade then
                        self:Close()
                    else
                        self:SetSkillInfo(v)
                    end
                    break
                end
            end
        else
            self:Close()
        end
    end)

    self:BindEvent(game.BagEvent.BagItemChange, function()
        self:SetCostItem()
    end)

    self._layout_objs.btn_forget:AddClickCallBack(function()
        if skill then
            local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[1472])
            tips_view:SetBtn1(nil, function()
                self.ctrl:SendForgetSkill(pet, skill.grid)
                self:Close()
            end)
            tips_view:SetBtn2(config.words[101])
            tips_view:Open()
        end
    end)

    self._layout_objs.btn_upgrade:AddClickCallBack(function()
        if skill then
            local num = tonumber(self._layout_objs.num:GetText())
            self.ctrl:SendUpgradeSkill(pet, skill.grid, num)
        end
    end)

    self._layout_objs.btn_add:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.num:GetText())
        self:UpdateNum(num + 1)
    end)

    self._layout_objs.btn_reduce:AddClickCallBack(function()
        local num = tonumber(self._layout_objs.num:GetText())
        if num > 0 then
            self:UpdateNum(num - 1)
        end
    end)

    self._layout_objs.num:AddClickCallBack(function()
        game.MainUICtrl.instance:OpenNumberKeyboard()
    end)

    self:BindEvent(game.NumberKeyboardEvent.Number, function(key)
        local num = tonumber(self._layout_objs.num:GetText())
        if key >= 0 then
            self:UpdateNum(num * 10 + key)
        else
            self:UpdateNum(math.floor(num / 10))
        end
    end)

    self.skill_item = self:GetTemplate("game/skill/item/skill_item_rect", "skill_item")
    self.senior_skill_item = self:GetTemplate("game/skill/item/skill_item_rect", "senior_skill_item")
    self.goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    self.goods_item:SetShowTipsEnable(true)

    local skill_cfg = config.pet_skill[skill.id]
    if skill_cfg.type == 1 then
        self._layout_objs.type:SetText(config.words[1535])
        self._layout_objs.senior_type:SetText(config.words[1535])
    else
        self._layout_objs.type:SetText(config.words[1536])
        self._layout_objs.senior_type:SetText(config.words[1536])
    end
    self._layout_objs.pet_type:SetText(config.words[1510 + skill_cfg.fit_type])
    self._layout_objs.senior_pet_type:SetText(config.words[1510 + skill_cfg.fit_type])

    self:SetSkillInfo(skill)
end

function SkillSeniorView:SetSkillInfo(skill)
    self.skill_info = skill
    self.skill_item:SetItemInfo(skill)
    local pet_info = game.PetCtrl.instance:GetPetInfoById(self.pet_grid)
    local skill_desc = config.pet_skill_desc[skill.id][skill.lv]
    local skill_cfg = config.skill[skill.id][skill.lv]
    self._layout_objs.name:SetText(skill_cfg.name)
    local param = {}
    for _, v in ipairs(skill_desc.param) do
        table.insert(param, math.floor(v * (1 + skill_cfg.pet_assist_fact * (pet_info.level - 1))))
    end
    self._layout_objs.desc:SetText(string.format(skill_desc.desc, table.unpack(param)))
    self.senior_skill_item:SetItemInfo({ id = skill.id, lv = skill.lv + 1 })
    skill_desc = config.pet_skill_desc[skill.id][skill.lv + 1]
    skill_cfg = config.skill[skill.id][skill.lv + 1]
    self._layout_objs.senior_name:SetText(skill_cfg.name)
    param = {}
    for _, v in ipairs(skill_desc.param) do
        table.insert(param, math.floor(v * (1 + skill_cfg.pet_assist_fact * (pet_info.level - 1))))
    end
    self._layout_objs.senior_desc:SetText(string.format(skill_desc.desc, table.unpack(param)))

    self:SetCostItem()
    self:UpdateNum(0)
end

function SkillSeniorView:SetCostItem()
    local item_id = config.pet_common.skill_stone
    local own = game.BagCtrl.instance:GetNumById(item_id)
    self.goods_item:SetItemInfo({ id = item_id, num = own })
end

function SkillSeniorView:UpdateNum(num)
    local item_id = config.pet_common.skill_stone
    local own = game.BagCtrl.instance:GetNumById(item_id)
    local upgrade_cfg = config.pet_skill_upgrade[self.skill_info.lv]
    local upgrade_rate = upgrade_cfg.stone_rate
    local skill_cfg = config.pet_skill[self.cur_skill.id]
    if skill_cfg.type == 2 then
        upgrade_rate = upgrade_cfg.stone_rate_auto
    end
    local max_num = math.ceil(10000 / upgrade_rate)
    if num > max_num then
        num = max_num
    end
    if num > own then
        num = own
    end
    self._layout_objs.num:SetText(num)
    self._layout_objs.ratio:SetText(string.format(config.words[1510], math.floor(math.min(upgrade_rate * num / 100 , 100))))
    self._layout_objs.btn_upgrade:SetGray(own < num)
    self._layout_objs.btn_upgrade:SetTouchEnable(own >= num)
end

return SkillSeniorView