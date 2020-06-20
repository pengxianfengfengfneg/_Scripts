local SkillSuperView = Class(game.BaseView)

function SkillSuperView:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "skill_super_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function SkillSuperView:OnEmptyClick()
    self:Close()
end

function SkillSuperView:OpenViewCallBack(pet, skill)
    self.pet_grid = pet
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1533])

    self._layout_objs.btn_forget:AddClickCallBack(function()
        local tips_view = game.GameMsgCtrl.instance:CreateMsgTips(config.words[1472])
        tips_view:SetBtn1(nil, function()
            self.ctrl:SendForgetSkill(pet, skill.grid)
            self:Close()
        end)
        tips_view:SetBtn2(config.words[101])
        tips_view:Open()
    end)

    self.skill_item = self:GetTemplate("game/skill/item/skill_item_rect", "skill_item")
    self.skill_item:SetItemInfo(skill)

    local skill_cfg = config.pet_skill[skill.id]
    if skill_cfg.type == 1 then
        self._layout_objs.type:SetText(config.words[1535])
    else
        self._layout_objs.type:SetText(config.words[1536])
    end
    local pet_info = game.PetCtrl.instance:GetPetInfoById(self.pet_grid)
    local skill_desc = config.pet_skill_desc[skill.id][skill.lv]
    local skill_lv_cfg = config.skill[skill.id][skill.lv]
    self._layout_objs.name:SetText(skill_lv_cfg.name)
    local param = {}
    for _, v in ipairs(skill_desc.param) do
        table.insert(param, math.floor(v * (1 + skill_lv_cfg.pet_assist_fact * (pet_info.level - 1))))
    end
    self._layout_objs.desc:SetText(string.format(skill_desc.desc, table.unpack(param)))
    self._layout_objs.pet_type:SetText(config.words[1510 + skill_cfg.fit_type])

    if skill.lv == 5 then
        self._layout_objs.text:SetText(config.words[1480])
    elseif skill.lv == 6 then
        self._layout_objs.text:SetText(config.words[1481])
    elseif skill.lv == 7 then
        self._layout_objs.text:SetText(config.words[1482])
    end
end

return SkillSuperView