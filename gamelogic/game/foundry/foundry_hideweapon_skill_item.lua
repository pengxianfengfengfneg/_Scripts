local FoundryHideweaponSkillItem = Class(game.UITemplate)

function FoundryHideweaponSkillItem:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "skill_item"
    self.parent = parent
end

function FoundryHideweaponSkillItem:OpenViewCallBack()
end

function FoundryHideweaponSkillItem:CloseViewCallBack()
end

function FoundryHideweaponSkillItem:RefreshItem(idx)
	self.idx = idx

	local list_data = self.parent:GetListData()
	local skill_id = list_data[idx]
	
	local skill_icon = config.skill[skill_id][1].icon

	self._layout_objs["skill_icon"]:SetSprite("ui_skill_icon", skill_icon)
end

function FoundryHideweaponSkillItem:GetIdx()
	return self.idx
end

function FoundryHideweaponSkillItem:SetSelect(val)
	self._layout_objs["select_img"]:SetVisible(val)
end

return FoundryHideweaponSkillItem