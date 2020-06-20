local PetInheritPreview = Class(game.BaseView)

function PetInheritPreview:_init(ctrl)
    self._package_name = "ui_pet"
    self._com_name = "inherit_preview"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full

    self.ctrl = ctrl
end

function PetInheritPreview:OnEmptyClick()
    self:Close()
end

function PetInheritPreview:OpenViewCallBack(original, target, savvy_stat, skill_stat)
    local inherit_type = 1
    local cost = 0

    self:BindEvent(game.PetEvent.PetChange, function()
        self:Close()
    end)

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1548])

    self._layout_objs.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    if savvy_stat and skill_stat then
        inherit_type = 3
    elseif savvy_stat then
        inherit_type = 1
    else
        inherit_type = 2
    end
    self._layout_objs.btn_ok:AddClickCallBack(function()
        self.ctrl:SendInherit(original.grid, target.grid, inherit_type)
    end)

    self.pet_icon = self:GetTemplate("game/pet/item/pet_icon_item", "pet_item")
    self.pet_icon:SetItemInfo(target)
    self._layout_objs.name:SetText(target.name)
    local savvy_lv = target.savvy_lv
    if savvy_stat then
        savvy_lv = original.savvy_lv
        cost = cost + (config.pet_inherit_savvy[savvy_lv] or 0)
    end
    self._layout_objs.level:SetText(savvy_lv)
    self._layout_objs.star:SetText(target.star)

    local skills = target.skills
    if skill_stat then
        skills = original.skills
    end

    local skill_items = {}
    for i = 0, 8 do
        skill_items[i] = self:GetTemplate("game/skill/item/skill_item_rect", "skill" .. i)
        skill_items[i]:ResetItem()
    end

    for _, v in pairs(skills) do
        skill_items[v.grid]:SetItemInfo(v)
        cost = cost + config.pet_inherit_skill[v.lv]
    end
    cost = math.ceil(cost)

    local savvy_cfg = config.pet_savvy[savvy_lv]
    for i = savvy_cfg.skill_grid + 1, 8 do
        skill_items[i]:ResetItem()
        skill_items[i]:SetLockVisible(true)
    end

    local cost_id = config.pet_common.inherit_item
    local own = game.BagCtrl.instance:GetNumById(cost_id)
    local goods_item = self:GetTemplate("game/bag/item/goods_item", "goods_item")
    goods_item:SetItemInfo({id = cost_id})
    goods_item:SetShowTipsEnable(true)
    goods_item:SetNumText(own .. "/" .. cost)
end

return PetInheritPreview