local FoundryStrenSuitAttrTemplate = Class(game.UITemplate)

function FoundryStrenSuitAttrTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "stren_suit_attr_template"
    self.parent = parent
end

function FoundryStrenSuitAttrTemplate:OpenViewCallBack()

end

function FoundryStrenSuitAttrTemplate:RefreshItem(idx)
	local suit_cfg = self.parent:GetCfg()
	local stren_lv_list = self.parent:GetStrenLvList()

	local cfg = suit_cfg[idx]
	self._layout_objs["txt1"]:SetText(string.format(config.words[1225], cfg.num, cfg.lv))

	local attr_name = config_help.ConfigHelpAttr.GetAttrName(cfg.attr[1])
	self._layout_objs["txt2"]:SetText(string.format(config.words[1226], attr_name, cfg.attr[2]))

	local count = 0
	for key, stren_lv in pairs(stren_lv_list) do
		if stren_lv >= cfg.lv then
			count = count + 1
		end
	end

	if count >= cfg.num then
		self._layout_objs["txt1"]:SetColor(95,201,52,255)
		self._layout_objs["txt2"]:SetColor(95,201,52,255)
	else
		self._layout_objs["txt1"]:SetColor(149,141,126,255)
		self._layout_objs["txt2"]:SetColor(149,141,126,255)
	end
end

return FoundryStrenSuitAttrTemplate