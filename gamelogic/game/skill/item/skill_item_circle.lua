local SkillItemCircle = Class(game.UITemplate)

local config_skill = config.skill

function SkillItemCircle:_init()

end

function SkillItemCircle:OpenViewCallBack()
    self:GetRoot():AddClickCallBack(function()
        if self.click_func then
            self.click_func(self)
        end
    end)
end

function SkillItemCircle:SetItemInfo(info)
    self.item_info = info
    self:ResetItem()

    local skill_config = config_skill[info.id][1]
    self:SetSkillIcon(skill_config.icon)
    if info.lock then
        self:SetBtnLockState(info.lock)
    end

    self._layout_objs["btn_lock"]:AddClickCallBack(function()
        if self.lock_func then
            self.lock_func(self._layout_objs["btn_lock"]:GetSelected())
        end
    end)

    self.is_lock_mask = false
    if info.open_lv then
        self.is_lock_mask = info.lv<=0
        self:SetShowLockMask(self.is_lock_mask, info.open_lv)
    end

    if info.show_lv then
        self:SetShowLv(true, info.lv)
    end
end

function SkillItemCircle:ResetItem()
    self.is_lock_mask = false

    self._layout_objs["icon"]:SetVisible(false)
    self._layout_objs["btn_lock"]:SetVisible(false)
    self:SetShowLockMask(false)
    self:SetShowLv(false)
    self:SetShowLvUp(false)
end

function SkillItemCircle:AddClickEvent(func)
    self.click_func = func
end

function SkillItemCircle:SetSkillIcon(name)
    self._layout_objs["icon"]:SetVisible(true)
    self._layout_objs["icon"]:SetSprite("ui_skill_icon", name)
end

function SkillItemCircle:SetGray(val)
    self._layout_objs["icon"]:SetGray(val)
end

function SkillItemCircle:GetItemInfo()
    return self.item_info
end

function SkillItemCircle:SetBtnLockState(val)
    self._layout_objs["btn_lock"]:SetVisible(true)
    self._layout_objs["btn_lock"]:SetSelected(val == 1)
end

function SkillItemCircle:SetLockState(val)
    self._layout_objs["lock"]:SetVisible(val)
end

function SkillItemCircle:SetBtnLockEvent(func)
    self.lock_func = func
end

function SkillItemCircle:SetLockBtnTouchEnable(val)
    self._layout_objs["btn_lock"]:SetTouchEnable(val)
end

function SkillItemCircle:GetSkillId()
    return self.item_info.id
end

function SkillItemCircle:GetSkillLv()
    return self.item_info.lv
end

function SkillItemCircle:GetSkillHeroId()
    return self.item_info.hero or 0
end

function SkillItemCircle:GetSkillLegend()
    return self.item_info.legend
end

function SkillItemCircle:DoSelected(val)
    self._layout_objs["img_selected"]:SetVisible(val)
end

function SkillItemCircle:SetShowLvUp(val)
    if self.is_lock_mask then
        return
    end

    self._layout_objs["img_up"]:SetVisible(val)
end

function SkillItemCircle:SetShowLockMask(val, lv)
    self.is_lock_mask = val

    if val then
        local desc = string.format(config.words[2200], lv)
        self._layout_objs["txt_lock_desc"]:SetText(desc)
    end
    self._layout_objs["group_mask"]:SetVisible(val)
end

function SkillItemCircle:SetShowLv(val, lv)
    if self.is_lock_mask then
        return
    end

    if val then
        self._layout_objs["txt_lv"]:SetText(lv)
    end
    self._layout_objs["group_lv"]:SetVisible(val)
end

function SkillItemCircle:GetOpenLv()
    return self.item_info.open_lv or 0
end

function SkillItemCircle:GetCost()
    local skill_cfg = config_skill[self:GetSkillId()] or {}
    local lv_cfg = skill_cfg[self:GetSkillLv()] or {}
    return lv_cfg.cost or 0
end

function SkillItemCircle:GetName()
    local skill_cfg = config_skill[self:GetSkillId()] or {}
    local lv_cfg = skill_cfg[1] or {}
    return lv_cfg.name or ""
end

function SkillItemCircle:PlayEffect(eff_name, scale)
    local effect = self:CreateUIEffect(self._layout_objs.effect, string.format("effect/ui/%s.ab", eff_name))
    if scale then
        effect:SetScale(scale, scale, scale)
    end
end

return SkillItemCircle