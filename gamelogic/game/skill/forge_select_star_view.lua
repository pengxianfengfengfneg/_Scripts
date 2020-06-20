local ForgeSelectStarView = Class(game.BaseView)

function ForgeSelectStarView:_init(ctrl)
    self._package_name = "ui_skill"
    self._com_name = "forge_select_star_view"

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None

    self.ctrl = ctrl
end

function ForgeSelectStarView:OpenViewCallBack(cur_index)

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1271])

	for i = 2, 3 do
		self._layout_objs["btn_checkbox"..i]:SetSelected(false)
	    self._layout_objs["btn_checkbox"..i]:AddChangeCallback(
	    	function(event_type)
		        local is_selected = (event_type == game.ButtonChangeType.Selected)
		        self:OnSelectCheckBox(i, is_selected)
	    	end)
	end

	self.select_index = cur_index
	self._layout_objs["btn_checkbox"..cur_index]:SetSelected(true)
end

function ForgeSelectStarView:OnSelectCheckBox(index, is_selected)
	for i = 2, 3 do
		self._layout_objs["btn_checkbox"..i]:SetSelected(false)
	end

	self._layout_objs["btn_checkbox"..index]:SetSelected(true)
	self.select_index = index
end

function ForgeSelectStarView:CloseViewCallBack()
	self:FireEvent(game.SkillEvent.ChangeForgeStar, self.select_index)
end

return ForgeSelectStarView
