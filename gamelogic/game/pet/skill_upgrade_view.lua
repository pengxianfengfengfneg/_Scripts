local SkillUpgradeView = Class(game.BaseView)

function SkillUpgradeView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "skill_upgrade_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function SkillUpgradeView:OnEmptyClick()
    self:Close()
end

function SkillUpgradeView:OpenViewCallBack(pet, skill)
    self.pet_grid = pet
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1533])

    self:BindEvent(game.PetEvent.PetChange, function(data)
        if data.grid == pet then
            for _, v in pairs(data.skills) do
                if v.grid == skill.grid then
                    if config.pet_skill_upgrade[v.lv].carry_lv ~= 0 then
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
            self.ctrl:SendUpgradeSkill(pet, skill.grid, 0)
        end
    end)

    self.skill_item = self:GetTemplate("game/skill/item/skill_item_rect", "skill_item")
    self.goods_item = self:GetTemplate("game/skill/item/skill_item_rect", "goods_item")

    local skill_cfg = config.pet_skill[skill.id]
    local skill_lv_cfg = config.skill[skill.id][skill.lv]
    self._layout_objs.name:SetText(skill_lv_cfg.name)
    if skill_cfg.type == 1 then
        self._layout_objs.type:SetText(config.words[1535])
    else
        self._layout_objs.type:SetText(config.words[1536])
    end
    self._layout_objs.pet_type:SetText(config.words[1510 + skill_cfg.fit_type])

    self:SetSkillInfo(skill)
end

function SkillUpgradeView:SetSkillInfo(skill)
    self.skill_item:SetItemInfo(skill)
    local pet_info = game.PetCtrl.instance:GetPetInfoById(self.pet_grid)
    local skill_desc = config.pet_skill_desc[skill.id][skill.lv]
    local skill_fact = config.skill[skill.id][skill.lv].pet_assist_fact
    local param = {}
    for _, v in ipairs(skill_desc.param) do
        table.insert(param, math.floor(v * (1 + skill_fact * (pet_info.level - 1))))
    end
    self._layout_objs.desc:SetText(string.format(skill_desc.desc, table.unpack(param)))

    local skill_cfg = config.pet_skill[skill.id]
    self.goods_item:SetItemInfo(skill)
    self.goods_item:AddClickEvent(function()
        game.BagCtrl.instance:OpenGoodsInfoView({ id = skill_cfg.cost_id }, 0)
    end)
    local own = game.BagCtrl.instance:GetNumById(skill_cfg.cost_id)
    local upgrade_cfg = config.pet_skill_upgrade[skill.lv]
    local num = upgrade_cfg.cost_num
    self.goods_item:SetLevelText(own .. "/" .. num)
    self._layout_objs.ratio:SetText(string.format(config.words[1510], math.floor(upgrade_cfg.upgrade_rate / 100)))
    self._layout_objs.btn_upgrade:SetGray(own < num)
    self._layout_objs.btn_upgrade:SetTouchEnable(own >= num)
end

return SkillUpgradeView