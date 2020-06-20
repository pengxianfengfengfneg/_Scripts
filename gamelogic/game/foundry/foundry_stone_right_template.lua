local FoundryStoneRightTemplate = Class(game.UITemplate)

function FoundryStoneRightTemplate:_init(parent)
	self.parent = parent
end

function FoundryStoneRightTemplate:OpenViewCallBack()

	if self._layout_objs["bg"] then
		self._layout_objs["bg"]:SetTouchDisabled(false)
		self._layout_objs["bg"]:AddClickCallBack(function()
			self.parent:OnSelectTypeItem(self.idx, self)
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_stone_inlay_view/stone_right_template1"})
	    	game.ViewMgr:FireGuideEvent()
	    end)
	end

	if self._layout_objs["n3"] then
		self._layout_objs["n3"]:SetTouchDisabled(false)
		self._layout_objs["n3"]:AddClickCallBack(function()
			local stone_pos = self.parent.stone_pos
			game.FoundryCtrl.instance:CsEquipInlayStone(stone_pos, self.stone_item_id1)
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_stone_inlay_view/stone_right_template2"})
			game.ViewMgr:FireGuideEvent()
	    end)
	end

	if self._layout_objs["n9"] then
		self._layout_objs["n9"]:SetTouchDisabled(false)
		self._layout_objs["n9"]:AddClickCallBack(function()
			local stone_pos = self.parent.stone_pos
			game.FoundryCtrl.instance:CsEquipInlayStone(stone_pos, self.stone_item_id2)
			game.GuideCtrl.instance:FinishCurGuideInfo({click_btn_name = "ui_foundry/foundry_stone_inlay_view/stone_right_template2"})
			game.ViewMgr:FireGuideEvent()
	    end)
	end
end

function FoundryStoneRightTemplate:CloseViewCallBack()

	if self.goods_item1 then
		self.goods_item1:DeleteMe()
		self.goods_item1 = nil
	end

	if self.goods_item2 then
		self.goods_item2:DeleteMe()
		self.goods_item2 = nil
	end
end

function FoundryStoneRightTemplate:RefreshItem(idx)

	local list_data = self.parent:GetListData()
	self.item_data = list_data[idx]
	self.idx = idx

	--类型栏
	if self.item_data.type == 1 then

		local stone_type = self.item_data.stone_type
		local stone_name = config.equip_stone_type[stone_type].name
		local stone_nums = self:GetStoneNumInBag(stone_type)
		self._layout_objs["name"]:SetText(stone_name.."("..tostring(stone_nums)..")")

		local icon_str = self:GetStoneIconByStoneType(stone_type)
		self._layout_objs["stone_img"]:SetSprite("ui_item", icon_str)

	--宝石栏
	else

		if self.item_data.data1 then
			local item_id = self.item_data.data1.goods.id
			local item_num = self.item_data.data1.goods.num
			local is_bind = self.item_data.data1.goods.bind
			local item_cfg = config.goods[item_id]
			self.stone_item_id1 = item_id

			if not self.goods_item1 then
				self.goods_item1 = require("game/bag/item/goods_item").New()
				self.goods_item1:SetVirtual(self._layout_objs["item1"])
				self.goods_item1:Open()
			end
			self.goods_item1:SetItemInfo({id = item_id, num = item_num, bind = 0})

			self._layout_objs["name1"]:SetText(item_cfg.name)

			local attr = self:GetStoneAttr(item_id)
			local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[1])
			self._layout_objs["attr1"]:SetText(string.format(config.words[1226], attr_name, attr[2]))
		end

		if self.item_data.data2 then
			local item_id = self.item_data.data2.goods.id
			local item_num = self.item_data.data2.goods.num
			local is_bind = self.item_data.data2.goods.bind
			local item_cfg = config.goods[item_id]
			self.stone_item_id2 = item_id

			if not self.goods_item2 then
				self.goods_item2 = require("game/bag/item/goods_item").New()
				self.goods_item2:SetVirtual(self._layout_objs["item2"])
				self.goods_item2:Open()
			end
			self.goods_item2:SetItemInfo({id = item_id, num = item_num, bind = 0})

			self._layout_objs["name2"]:SetText(item_cfg.name)

			local attr = self:GetStoneAttr(item_id)
			local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr[1])
			self._layout_objs["attr2"]:SetText(string.format(config.words[1226], attr_name, attr[2]))

			self._layout_objs["temp2"]:SetVisible(true)
		else
			self._layout_objs["temp2"]:SetVisible(false)
		end
	end
end

--标题1 物品 2
function FoundryStoneRightTemplate:GetType()
	return self.item_data.type
end

function FoundryStoneRightTemplate:SetSelect(val)

	self.select_flag = val

	if self.item_data.type == 1 then
		if val then
			self._layout_objs["bg"]:SetSprite("ui_common", "xlan_02")
		else
			self._layout_objs["bg"]:SetSprite("ui_common", "xlan_01")
		end
	end
end

function FoundryStoneRightTemplate:GetSelectFlag()
	return self.select_flag
end

function FoundryStoneRightTemplate:GetIndex()
	return self.idx
end

function FoundryStoneRightTemplate:GetStoneAttr(stone_item_id)

	local attr

	for k, v in pairs(config.equip_stone) do

		for item_id, v2 in pairs(v) do

			if item_id == stone_item_id then
				attr = v2.attr
				break
			end
		end

		if attr then
			break
		end
	end

	return attr
end

function FoundryStoneRightTemplate:GetStoneNumInBag(stone_type)

	local total_num = 0
	for k, v in pairs(config.equip_stone2) do
		if v.type == stone_type then

			local item_id = v.id
			local item_num = game.BagCtrl.instance:GetNumById(item_id)
			total_num = item_num + total_num
		end
	end
	return total_num
end

function FoundryStoneRightTemplate:GetStoneIconByStoneType(stone_type)

	local icon_str = ""

	for k, v in pairs(config.equip_stone2) do
		if v.type == stone_type then

			local item_id = v.id
			icon_str = config.goods[item_id].icon
		end
	end

	return icon_str
end

return FoundryStoneRightTemplate