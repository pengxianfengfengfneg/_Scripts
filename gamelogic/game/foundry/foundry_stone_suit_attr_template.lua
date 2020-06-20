local FoundryStoneSuitAttrTemplate = Class(game.UITemplate)

function FoundryStoneSuitAttrTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "stren_suit_attr_template"
    self.parent = parent
end

function FoundryStoneSuitAttrTemplate:OpenViewCallBack(stone_min_lv_list)
	self.stone_min_lv_list = stone_min_lv_list
end

function FoundryStoneSuitAttrTemplate:RefreshItem(idx)

	local suit_cfg = self.parent:GetCfg()
	local cfg = suit_cfg[idx]

	self._layout_objs["txt1"]:SetText(cfg.desc)

	local attr_name = config_help.ConfigHelpAttr.GetAttrName(cfg.attr[1])
	self._layout_objs["txt2"]:SetText(string.format(config.words[1226], attr_name, cfg.attr[2]))

	local count = 0
	for key, stone_min_lv in pairs(self.stone_min_lv_list) do
		if stone_min_lv >= cfg.lv then
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

return FoundryStoneSuitAttrTemplate