local DragonDesignData = Class(game.BaseData)
local _goods_cfg = config.goods
function DragonDesignData:_init()
end

function DragonDesignData:_delete()
end

function DragonDesignData:SetAllData(data)
	self.all_data = data
end

function DragonDesignData:GetAllData()
	return self.all_data
end

function DragonDesignData:UpdateRefine(data)
	if self.all_data then
		self.all_data.refine_exp = data.refine_exp
		self.all_data.refine_times = data.refine_times
		self.all_data.refine_lv_r = data.refine_lv_r
		self.all_data.refine_star_r = data.refine_star_r
		self.all_data.refine_quality_r = data.refine_quality_r
	end
end

function DragonDesignData:UpdateReplace(data)
	if self.all_data then
		self.all_data.refine_star = data.refine_star
		self.all_data.refine_lv = data.refine_lv
		self.all_data.refine_quality = data.refine_quality
		self.all_data.refine_quality_r = {}
	end
end

function DragonDesignData:UpdateGrowthData(data)
	if self.all_data then
		self.all_data.growth_lv = data.growth_lv
		self.all_data.growth_hole = data.growth_hole
	end
end

function DragonDesignData:GetQualityPercent(index)

	if self.all_data then

		local qua_info
		for k, v in pairs(self.all_data.refine_quality) do
			if v.id == index then
				qua_info = v
				break
			end
		end

		if qua_info then
			return (qua_info.val-1000)*0.001
		else
			return 0
		end
	end

	return 0
end

function DragonDesignData:GetNewQualityPercent(index)

	if self.all_data then

		local qua_info
		for k, v in pairs(self.all_data.refine_quality_r) do
			if v.id == index then
				qua_info = v
				break
			end
		end

		if qua_info then
			return (qua_info.val-1000)*0.001
		else
			return 0
		end
	end

	return 0
end

function DragonDesignData:GetInlayInfoByPos(pos)

	local info

	if self.all_data then

		for k, v in pairs(self.all_data.items) do
			if v.item.pos == pos then
				info = v.item
				break
			end
		end
	end

	return info
end

--所有辅龙元属性综合
function DragonDesignData:GetSubMetaAttr()

	local attr_list = {}

	if self.all_data then
		for k, v in pairs(self.all_data.items) do

			if (v.item.pos % 4) ~= 1 and v.item.id > 0 then

				local attr_info = config.dragon_attr[v.item.id][v.item.level]
				if attr_info then

					if not attr_list[attr_info.attr[1][1]] then
						attr_list[attr_info.attr[1][1]] = attr_info.attr[1][2]
					else
						attr_list[attr_info.attr[1][1]] = attr_list[attr_info.attr[1][1]] + attr_info.attr[1][2]
					end
				end
			end
		end
	end

	return attr_list
end

--获取背包龙元
function DragonDesignData:GetCanEquipList(color, filter_pos)

	local equip_bag = game.BagCtrl.instance:GetGoodsBagByBagId(2)
	local list = equip_bag.goods
	local resutl_list = {}

	if color > 0 then
		for k, v in pairs(list) do

			local item_id = v.goods.id
			local item_cfg = _goods_cfg[item_id]
			if item_cfg.color <= color and v.goods.pos ~= filter_pos then
				table.insert(resutl_list, v)
			end
		end

		return resutl_list
	else
		for k, v in pairs(list) do
			if v.goods.pos ~= filter_pos then
				table.insert(resutl_list, v)
			end
		end

		return resutl_list
	end
end

function DragonDesignData:GetCanEquipListByFixColor(fix_color)

	local equip_bag = game.BagCtrl.instance:GetGoodsBagByBagId(2)
	local list = equip_bag.goods
	local resutl_list = {}

	if fix_color > 0 then
		for k, v in pairs(list) do

			local item_id = v.goods.id
			local item_cfg = _goods_cfg[item_id]
			if item_cfg.color == fix_color then
				table.insert(resutl_list, v)
			end
		end

		return resutl_list
	else
		for k, v in pairs(list) do
			if v.goods.id ~= 39000101 then		--去除龙元尘
				table.insert(resutl_list, v)
			end
		end

		return resutl_list
	end
end

function DragonDesignData:UpdateEquipData(data)
	if self.all_data then

		local exist = false
		for k, v in pairs(self.all_data.items) do
			if v.item.pos == data.item.pos then
				exist = true
				v.item = data.item
				break
			end
		end

		if not exist then
			table.insert(self.all_data.items, data)
		end
	end
end

function DragonDesignData:UpdateEatData(data)
	if data.type == 1 then
		if self.all_data then
			for k, v in pairs(self.all_data.items) do
				if v.item.pos == data.pos then
					v.item.level = data.level
					v.item.exp = data.exp
					break
				end
			end
		end
	end
end

function DragonDesignData:UpdateCondenseData(data)
	if self.all_data then
		self.all_data.condense_state = data.condense_state
	end
end

function DragonDesignData:GetCondenseState()
	if self.all_data then
		return self.all_data.condense_state
	else
		return 1
	end
end

function DragonDesignData:CanUpgrade()

	if self.all_data then
	
		local growth_lv = self.all_data.growth_lv			--等级
		local growth_hole = self.all_data.growth_hole		--属性孔
		local growth_cfg = config.dragon_growth[growth_lv][growth_hole]

		local cost_item_id = growth_cfg.material[1]
	    local cost_item_num = growth_cfg.material[2]
	    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
	    if cur_num < cost_item_num then
	    	return false
	    end

	    local cur_copper = game.BagCtrl.instance:GetCopper()
	    if cur_copper < growth_cfg.coin then
	    	return false
	    end

	    return true
	else
		return false
	end
end

--新资质是否提高战力
function DragonDesignData:CanSaveRefine()
	if self.all_data then

		local growth_lv = self.all_data.growth_lv			--等级
		local growth_hole = self.all_data.growth_hole		--属性孔
		local growth_cfg = config.dragon_growth[growth_lv][growth_hole]
		local refine_quality = self.all_data.refine_quality
		local refine_quality_r = self.all_data.refine_quality_r


		local attr_list = {}

		for i = 1, 5 do
			local add_percent = self:GetQualityPercent(i)
			local add_percent_r = self:GetNewQualityPercent(i)
			local offset_percent = add_percent_r - add_percent

			local attr_info = growth_cfg.attr[i+3]
			local attr_type = attr_info[1]
			local attr_val = attr_info[2]
			local add_val = math.floor(attr_val*offset_percent)


			local t = {}
			t.id = attr_type
			t.value = add_val
			table.insert(attr_list, t)
		end

		local offset_combat_power = game.Utils.CalculateCombatPower3(attr_list)
		if offset_combat_power > 0 then
			return true
		else
			return false
		end
	else
		return false
	end
end

function DragonDesignData:GetAttrCombatPower()
	local all_data = self:GetAllData()
	if not all_data then
		return 0
	end
	local growth_lv = all_data.growth_lv			--等级
	local growth_hole = all_data.growth_hole		--属性孔
	local growth_cfg = config.dragon_growth[growth_lv][growth_hole]
	local attr_list = {}

	for i = 1, 7 do
		local attr_info = growth_cfg.attr[i]
		local attr_type = attr_info[1]
		local attr_val = attr_info[2]
		local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)

		local t = {}
		t.id = attr_type
		t.value = attr_val

		if i > 3 and i < 9 then
			local percent = self:GetQualityPercent(i-3)
			local add_val = math.floor(attr_val*percent)
			t.value = attr_val + add_val
		end

		table.insert(attr_list, t)
	end

	return game.Utils.CalculateCombatPower3(attr_list)
end

return DragonDesignData