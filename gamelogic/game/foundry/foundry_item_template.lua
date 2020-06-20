local FoundryForgeTemplate = Class(game.UITemplate)

function FoundryForgeTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "forge_item_template"
    self.parent = parent
end

function FoundryForgeTemplate:OpenViewCallBack()

end

function FoundryForgeTemplate:RefreshItem(idx)

	self.idx = idx

	local top_item_list = self.parent:GetTopItemList()
	local item_forge_id = top_item_list[idx]
	local item_forge_cfg =  config.equip_forge[item_forge_id]

	if not self.goods_item then
		self.goods_item = require("game/bag/item/goods_item").New()
		self.goods_item:SetVirtual(self._layout_objs["n2"])
        self.goods_item:Open()
    end

    local item_id = item_forge_cfg.items[1][2]
    self.goods_item:SetItemInfo({ id = item_id})
    self._layout_objs["n2/name2"]:SetText("")

    self._layout_objs["n3"]:SetText(config.goods[item_id].name)

    if item_forge_cfg.type == 0 then
    	self._layout_objs["n4"]:SetText(config.words[1227])
    else
    	self._layout_objs["n4"]:SetText(config.words[1228])
    end
end

function FoundryForgeTemplate:SetSelect(var)
	self._layout_objs["n5"]:SetVisible(var)
end

function FoundryForgeTemplate:GetIdx()
	return self.idx
end

return FoundryForgeTemplate