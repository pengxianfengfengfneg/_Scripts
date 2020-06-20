local ForgeItemTemplate = Class(game.UITemplate)

function ForgeItemTemplate:_init(parent)
	self._package_name = "ui_skill"
    self._com_name = "forge_item_template"
    self.parent = parent
end

function ForgeItemTemplate:OpenViewCallBack()
    self._layout_objs["btn"]:AddClickCallBack(function()
        game.SkillCtrl.instance:OpenForgeView(self.item_forge_id)
    end)
end

function ForgeItemTemplate:RefreshItem(idx)

	self.idx = idx

	local top_item_list = self.parent:GetTopItemList()
	local item_forge_id = top_item_list[idx]
	local item_forge_cfg =  config.equip_forge[item_forge_id]
    self.item_forge_id = item_forge_id

	if not self.goods_item then
		self.goods_item = require("game/bag/item/goods_item").New()
		self.goods_item:SetVirtual(self._layout_objs["item"])
        self.goods_item:Open()
    end

    local item_id = item_forge_cfg.items[1][2]
    self.goods_item:SetItemInfo({ id = item_id})

    self._layout_objs["item_lv"]:SetText(tostring(item_forge_cfg.level)..config.words[1217])

    self._layout_objs["item_name"]:SetText(config.goods[item_id].name)

    if item_forge_cfg.type == 0 then
    	self._layout_objs["item_desc"]:SetText(config.words[1227])
    else
    	self._layout_objs["item_desc"]:SetText(config.words[1228])
    end
end

function ForgeItemTemplate:SetSelect(var)
	self._layout_objs["n5"]:SetVisible(var)
end

function ForgeItemTemplate:GetIdx()
	return self.idx
end

return ForgeItemTemplate