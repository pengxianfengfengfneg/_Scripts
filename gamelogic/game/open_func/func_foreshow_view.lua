local FuncForeshowView = Class(game.BaseView)

function FuncForeshowView:_init(ctrl)
    self._package_name = "ui_open_func"
    self._com_name = "func_foreshow_view"
    self.ctrl = ctrl
    self._mask_type = game.UIMaskType.Full
end

function FuncForeshowView:OpenViewCallBack()

	local cfg_index = self.ctrl:GetCurForeshowIndex()
	if cfg_index == 9999 then
		cfg_index = #config.func_foreshow
	end

	local cfg = config.func_foreshow[cfg_index]

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(cfg.name)

	self._layout_objs["n4"]:SetText(cfg.desc)

	local career = game.RoleCtrl.instance:GetCareer()
	if cfg.icon[career] then
		self._layout_objs["func_img"]:SetSprite("ui_main", cfg.icon[career], true)
	else
		self._layout_objs["func_img"]:SetSprite("ui_main", cfg.icon[1], true)
	end

	if cfg.inner_icon[1] ~= 0 then
		if cfg.inner_icon[career] then
			self._layout_objs["func_img2"]:SetSprite("ui_main", cfg.inner_icon[career], true)
		else
			self._layout_objs["func_img2"]:SetSprite("ui_main", cfg.inner_icon[1], true)
		end
		self._layout_objs["func_img2"]:SetVisible(true)
	else
		self._layout_objs["func_img2"]:SetVisible(false)
	end

	local role_lv = game.Scene.instance:GetMainRoleLevel()

	self._layout_objs["n5"]:SetText(string.format(config.words[2417], role_lv, cfg.level))
end

function FuncForeshowView:OnEmptyClick()
    self:Close()
end

function FuncForeshowView:CloseViewCallBack()

end

return FuncForeshowView
