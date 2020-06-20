local FoundryData = Class(game.BaseData)

local GetShopItemCfg = function (stone_item_id)
	local cfg = {}

	for k, v in pairs(config.shop_item) do
		for k1, v1 in pairs(v) do
			if k1 == stone_item_id then
				cfg = v1
				break
			end
		end
	end

	return cfg
end

function FoundryData:_init()
end

function FoundryData:_delete()
end

function FoundryData:SetEquipInfo(info)
    self.equip_info = info
end

function FoundryData:GetEquipInfo()
    return self.equip_info
end

function FoundryData:GetEquipInfoByType(equip_type)
    if self.equip_info then
        for i, v in pairs(self.equip_info.equips) do
            if v.equip.pos == equip_type then
				if equip_type == 7 then
					v.equip.mate_name = game.MarryCtrl.instance:GetMateName()
					v.equip.marry_bless = game.MarryCtrl.instance:GetBless()
				end
                return v.equip
            end
        end
    end
end

function FoundryData:UpdateEquipInfo(data)

	if self.equip_info then

		local exist = false
		for i, v in pairs(self.equip_info.equips) do
			if v.equip.pos == data.equip.pos then
				v.equip = data.equip
				exist = true
				break
			end
		end

		if not exist then
			table.insert(self.equip_info.equips, data)
		end
	end
end

function FoundryData:TakeOffEquip(data)
	if self.equip_info then

		for i, v in pairs(self.equip_info.equips) do
			if v.equip.pos == data.equip.pos then
				v.equip.id = 0
			end
		end
	end
end

function FoundryData:ChangeStrenLv(data)

	local pos = data.pos
	local new_level = data.lv

	--1-8常规 12为龙纹
	if pos < 9 or pos == 12 then
		local exist = false
		for k, v in pairs(self.equip_info.equips) do

			if v.equip.pos == pos then
				v.equip.stren = new_level
				exist = true
				break
			end
		end

		if not exist then
			local t = {}
			t.equip = {}
			t.equip.pos = pos
			t.equip.stren = new_level

			table.insert(self.equip_info.equips, t)
		end
	--神器
	elseif pos == 9 then
		if self.godweapon_data then
			self.godweapon_data.stren = new_level
		end
	elseif pos == 10 then
		if self.hideweapon_data then
			self.hideweapon_data.stren = new_level
		end
	elseif pos == 11 then
		local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
		if weaponsoul_data then
			weaponsoul_data.stren = new_level
		end
	end
end

function FoundryData:ChangeStoneInlay(data)

	local equip_pos = math.floor(data.pos/10)

	if equip_pos < 9 or equip_pos == 12 then

		for k, v in pairs(self.equip_info.equips) do

			if v.equip.pos == equip_pos then

				--替换宝石 或增加宝石
				if data.id > 0 then
					local exist = false
					for _, v2 in pairs(v.equip.stones) do

						if v2.pos == data.pos then
							v2.id = data.id
							exist = true
							break
						end
					end

					if not exist then
						local t = {}
						t.pos = data.pos
						t.id = data.id
						table.insert(v.equip.stones, t)
					end
				--data.id == 0 则删除该宝石
				else

					local index
					for k, v  in pairs(v.equip.stones) do

						if v.pos == data.pos then
							index = k
							break
						end
					end

					if index then
						table.remove(v.equip.stones, index)
					end
				end

				break
			else

				if data.id > 0 then
					local t = {}
					t.equip = {}
					t.equip.id = 0
					t.equip.pos = equip_pos
					t.equip.attr = {}
					t.equip.stones = {}
					t.equip.pairs = 0
					t.equip.stren = 0

					local stone_t = {}
					stone_t.pos = data.pos
					stone_t.id = data.id

					table.insert(t.equip.stones, stone_t)

					table.insert(self.equip_info.equips, t)
				end
			end
		end
	elseif equip_pos == 9 then

		if self.godweapon_data then
			--替换宝石 或增加宝石
			if data.id > 0 then
				local exist = false
				for _, v2 in pairs(self.godweapon_data.stones) do

					if v2.pos == data.pos then
						v2.id = data.id
						exist = true
						break
					end
				end

				if not exist then
					local t = {}
					t.pos = data.pos
					t.id = data.id
					table.insert(self.godweapon_data.stones, t)
				end
			--data.id == 0 则删除该宝石
			else

				local index
				for k, v  in pairs(self.godweapon_data.stones) do

					if v.pos == data.pos then
						index = k
						break
					end
				end

				if index then
					table.remove(self.godweapon_data.stones, index)
				end
			end
		end
	elseif equip_pos == 10 then
		if self.hideweapon_data then
			--替换宝石 或增加宝石
			if data.id > 0 then
				local exist = false
				for _, v2 in pairs(self.hideweapon_data.stones) do

					if v2.pos == data.pos then
						v2.id = data.id
						exist = true
						break
					end
				end

				if not exist then
					local t = {}
					t.pos = data.pos
					t.id = data.id
					table.insert(self.hideweapon_data.stones, t)
				end
			--data.id == 0 则删除该宝石
			else

				local index
				for k, v  in pairs(self.hideweapon_data.stones) do

					if v.pos == data.pos then
						index = k
						break
					end
				end

				if index then
					table.remove(self.hideweapon_data.stones, index)
				end
			end
		end
	elseif equip_pos == 11 then
		local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
		if weaponsoul_data then
			--替换宝石 或增加宝石
			if data.id > 0 then
				local exist = false
				for _, v2 in pairs(weaponsoul_data.stones) do

					if v2.pos == data.pos then
						v2.id = data.id
						exist = true
						break
					end
				end

				if not exist then
					local t = {}
					t.pos = data.pos
					t.id = data.id
					table.insert(weaponsoul_data.stones, t)
				end
			--data.id == 0 则删除该宝石
			else

				local index
				for k, v  in pairs(weaponsoul_data.stones) do

					if v.pos == data.pos then
						index = k
						break
					end
				end

				if index then
					table.remove(weaponsoul_data.stones, index)
				end
			end
		end
	end
end

function FoundryData:GetAllEquipStoneMinLv()

	local list = {}

	for i = 1, 8 do
		local lv = self:GetStoneMinLvByPos(i)
		table.insert(list, lv)
	end

	local godweapon_stone_min_lv = self:GetGodweaponStoneMinLv()
	table.insert(list, godweapon_stone_min_lv)

	local hideweapon_stone_min_lv = self:GetHideweaponStoneMinLv()
	table.insert(list, hideweapon_stone_min_lv)

	local weaponsoul_stone_min_lv = self:GetWeaponSoulStoneMinLv()
	table.insert(list, weaponsoul_stone_min_lv)

	local dragon_design_min_lv = self:GetStoneMinLvByPos(12)
	table.insert(list, dragon_design_min_lv)	

	return list
end

function FoundryData:GetStoneMinLvByPos(equip_pos)

	local min_lv = 9999
	local count = 0

	if self.equip_info then
		for key, var in pairs(self.equip_info.equips) do

			if var.equip.pos == equip_pos then

				for k, v in pairs(var.equip.stones) do
					local stone_item_id = v.id
					local cfg = self:GetStoneCfg(stone_item_id)
					local lv = cfg.level

					if lv <= min_lv then
						min_lv = lv
					end
					count = count + 1
				end

				break
			end
		end
	end

	if min_lv == 9999 or count < 4 then
		min_lv = 0
	end

	return min_lv
end

function FoundryData:GetGodweaponStoneMinLv()

	local min_lv = 9999
	local count = 0

	if self.godweapon_data then

		for k, v in pairs(self.godweapon_data.stones) do
			local stone_item_id = v.id
			local cfg = self:GetStoneCfg(stone_item_id)
			local lv = cfg.level

			if lv <= min_lv then
				min_lv = lv
			end
			count = count + 1
		end
	end

	if min_lv == 9999 or count < 4 then
		min_lv = 0
	end

	return min_lv
end

function FoundryData:GetHideweaponStoneMinLv()

	local min_lv = 9999
	local count = 0

	if self.hideweapon_data then

		for k, v in pairs(self.hideweapon_data.stones) do
			local stone_item_id = v.id
			local cfg = self:GetStoneCfg(stone_item_id)
			local lv = cfg.level

			if lv <= min_lv then
				min_lv = lv
			end
			count = count + 1
		end
	end

	if min_lv == 9999 or count < 4 then
		min_lv = 0
	end

	return min_lv
end

function FoundryData:GetWeaponSoulStoneMinLv()

	local min_lv = 9999
	local count = 0

	local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
	if weaponsoul_data then

		for k, v in pairs(weaponsoul_data.stones) do
			local stone_item_id = v.id
			local cfg = self:GetStoneCfg(stone_item_id)
			local lv = cfg.level

			if lv <= min_lv then
				min_lv = lv
			end
			count = count + 1
		end
	end

	if min_lv == 9999 or count < 4 then
		min_lv = 0
	end
	
	return min_lv
end

function FoundryData:GetStoneCfg(stone_item_id)
	
	local cfg

    for k, v in pairs(config.equip_stone) do

        for item_id, v2 in pairs(v) do

            if item_id == stone_item_id then
                cfg = v2
                break
            end
        end

        if cfg then
            break
        end
    end

    return cfg
end


--要合成的物品id
function FoundryData:GetStoneAdvanceCost(stone_item_id)
	local index = stone_item_id % 10 - 1
	local item_id = stone_item_id
	local off_num = 1	--需要合成的数量

	local result = {}
	local last_index
	local cost_bgold = 0
	local cost_gold = 0

	for i = 1, index do

		local cur_low_num = game.BagCtrl.instance:GetNumById(item_id - i)

		--包含镶嵌的那个 所以+1
		if i == 1 then
			cur_low_num = cur_low_num + 1
		end

		local need_low_num = config.equip_stone2[item_id - i].cost_num

		if cur_low_num >= need_low_num * off_num then

			local t = {}
			t.item_id = item_id - i
			t.item_num = need_low_num * off_num

			if i == 1 then
				t.item_num = t.item_num - 1
			end

			if t.item_num > 0 then
				table.insert(result, t)
			end

			last_index = i
			break
		else
			off_num = need_low_num * off_num - cur_low_num

			if cur_low_num > 0 then

				local t = {}
				t.item_id = item_id - i
				t.item_num = cur_low_num
				if i == 1 then
					t.item_num = t.item_num - 1
				end

				if t.item_num > 0 then
					table.insert(result, t)
				end
			end
		end
	end

	--宝石足够
	if last_index and last_index <= index then
		cost_bgold = 0
		cost_gold = 0
	else
	--宝石不够, 计算需要绑元
		
		local total_bgold = GetShopItemCfg(stone_item_id).price

		local inlay_stone_price = GetShopItemCfg(stone_item_id-1).price --已经镶嵌的宝石也要算

		local stone_equal_bgold = 0

		for t, var in pairs(result) do

			local s_item_pirce = GetShopItemCfg(var.item_id).price
			stone_equal_bgold = stone_equal_bgold + s_item_pirce*var.item_num
		end

		local off_bgold = total_bgold - stone_equal_bgold - inlay_stone_price
		local bag_bgold = game.BagCtrl.instance:GetBindGold()

		if bag_bgold >= off_bgold then
			cost_bgold = off_bgold
			cost_gold = 0
		else
			cost_bgold = bag_bgold
			cost_gold = off_bgold - bag_bgold
		end
	end

	return result, cost_bgold, cost_gold
end

--打造物品列表
function FoundryData:GetForgeItems(tag, lv)

	local result = {}

	for k, v in ipairs(config.equip_forge) do
		if v.tag == tag and v.level == lv then
			table.insert(result, v.id)
		end
	end

	return result
end

function FoundryData:SetGatherData(data)
	self.gather_data = data
end

function FoundryData:GetGatherData()
	return self.gather_data
end

function FoundryData:UpdateGatherLevel(data)
	if self.gather_data then
		self.gather_data.level = data.level
	end
end

--宝石套装数量
function FoundryData:GetStoneSuitNum()

	local career = game.RoleCtrl.instance:GetCareer()
	local suit_cfg = config.equip_stone_suit[career]
	local stone_min_lv_list = self:GetAllEquipStoneMinLv()

	local max_lv = 0
	for i = 1, 7 do
		local cfg = suit_cfg[i]
		local count = 0
		for key, stone_min_lv in pairs(stone_min_lv_list) do
			if stone_min_lv >= cfg.lv then
				count = count + 1
			end
		end

		if count >= cfg.num then
			max_lv = i
		end
	end

	return max_lv
end

function FoundryData:UpdateGatherVitality(data)

	if self.gather_data then
		self.gather_data.vitality = data.vitality
	end
end

function FoundryData:SetSmetlData(data)
	self.smelt_data = data
end

function FoundryData:GetSmeltData()
	return self.smelt_data
end

function FoundryData:GetBagEquipList()

end

--镶嵌 强化更改Paris
function FoundryData:UpdateEquipParis(equip_info)

	local pos = equip_info.equip.pos

	for k, v in pairs(self.equip_info.equips) do

		if v.equip.pos == pos then
			v.equip = equip_info.equip
			break
		end
	end
end

--拆卸更改装备信息
function FoundryData:UpdateEquipStrip(data)

	if self.equip_info then

		for i, v in pairs(self.equip_info.equips) do
			if v.equip.pos == data.equip.pos then
				v.equip.id = 0
				v.equip.paris = 0
			end
		end
	end
end

--神器综述
function FoundryData:SetGodweaponData(data)
	self.godweapon_data = data
end

function FoundryData:GetGodweaponData()
	return self.godweapon_data
end

--神器铸造
function FoundryData:UpdateGodweaponData(data)

	if self.godweapon_data then

		local exist = false
		for k, v in pairs(self.godweapon_data.pos_attr) do

			if v.pos == data.pos then
				exist = true
				v.value = data.value
				break
			end
		end

		if not exist then
			local t = {}
			t.pos = data.pos
			t.value = data.value
			table.insert(self.godweapon_data.pos_attr, t)
		end

		self.godweapon_data.extra_attr = data.extra_attr
		self.godweapon_data.combat_power = data.combat_power
	end
end

--神器升级
function FoundryData:UpdateUpgradeData(data)

	if self.godweapon_data then

		self.godweapon_data.id = data.id
		self.godweapon_data.pos_attr = {}
	end
end

function FoundryData:UpdateHuanhua(data)
	if self.godweapon_data then
		self.godweapon_data.cur_avatar = data.avatar_id
	end
end

function FoundryData:RefreshHuanhua(data)

	if self.godweapon_data then
		self.godweapon_data.cur_avatar = data.cur_avatar
		self.godweapon_data.avatars = data.avatars
		self.godweapon_data.a_combat_power = data.a_combat_power
	end
end

function FoundryData:GetGodweaponPosAttr(pos)

	if self.godweapon_data then
		for k, v in pairs(self.godweapon_data.pos_attr) do

			if v.pos == pos then
				return v
			end
		end
	end
end

function FoundryData:CheckHaveAvatar(avatar_id)

	if self.godweapon_data then

		for k, v in pairs(self.godweapon_data.avatars) do
			if v.id == avatar_id then
				return true
			end
		end
	end

	return false
end

function FoundryData:GetAvatarId()
	if self.godweapon_data then
		return self.godweapon_data.cur_avatar
	else
		return 0
	end
end

function FoundryData:SetHideWeaponData(data)
	self.hideweapon_data = data
end

function FoundryData:GetHideWeaponData()
	return self.hideweapon_data
end

function FoundryData:UpdateHideweaponPractice(data)

	if self.hideweapon_data then
		self.hideweapon_data.combat_power = data.combat_power
		self.hideweapon_data.practice_lv = data.practice_lv
		self.hideweapon_data.practice_exp = data.practice_exp
		self.hideweapon_data.add_attr = data.add_attr
		self.hideweapon_data.origin_attr = data.origin_attr
	end
end

function FoundryData:UpdateHWForge(data)

	if self.hideweapon_data then

		self.hideweapon_data.id = data.id
		self.hideweapon_data.combat_power = data.combat_power
		self.hideweapon_data.origin_attr = data.origin_attr
		self.hideweapon_data.add_attr = data.add_attr
		self.hideweapon_data.origin_attr = data.origin_attr
	end
end

function FoundryData:UpdateHWLvUp(data)

	if self.hideweapon_data then
		self.hideweapon_data.q_level = data.q_level
		self.hideweapon_data.combat_power = data.combat_power
		self.hideweapon_data.add_attr = data.add_attr
	end
end

--更改使用方案
function FoundryData:ChangeHWPlan(data)

	if self.hideweapon_data then
		self.hideweapon_data.cur_plan = data.plan
		self.hideweapon_data.end_plan_cd_time = data.end_plan_cd_time
	end
end

--解锁方案
function FoundryData:UnlockHWPlan(data)

	if self.hideweapon_data then

		local t = {}
		t.plan = {}
		t.plan.index = data.plan
		t.plan.skill1 = 0
		t.plan.skill2 = 0
		t.plan.skill3 = 0

		table.insert(self.hideweapon_data.skill_plans, t)
	end
end

--更新重洗技能
function FoundryData:RefreshHWPlan(data)

	if self.hideweapon_data then

		for k, v in pairs(self.hideweapon_data.skill_plans) do
			if v.plan.index == 0 then
				self.hideweapon_data.skill_plans[k] = nil
				break
			end
		end

		local t = {}
		t.plan = data.skill_plan
		table.insert(self.hideweapon_data.skill_plans, t)
	end
end

--替换技能
function FoundryData:ReplaceHWPlan(data)

	if self.hideweapon_data then

		local target_index = data.skill_plan.index

		for k, v in pairs(self.hideweapon_data.skill_plans) do
			if v.plan.index == 0 then
				self.hideweapon_data.skill_plans[k] = nil
			end
		end

		for k, v in pairs(self.hideweapon_data.skill_plans) do
			if v.plan.index == target_index then
				self.hideweapon_data.skill_plans[k] = nil
			end
		end

		local t = {}
		t.plan = data.skill_plan
		table.insert(self.hideweapon_data.skill_plans, t)
	end
end

function FoundryData:UpdateNewSkillOpen(data)

	if self.hideweapon_data then

		self.hideweapon_data.cur_plan = data.cur_plan

		local target_index = data.skill_plan.index

		for k, v in pairs(self.hideweapon_data.skill_plans) do
			if v.plan.index == target_index then
				self.hideweapon_data.skill_plans[k] = nil
			end
		end

		local t = {}
		t.plan = data.skill_plan
		table.insert(self.hideweapon_data.skill_plans, t)
	end
end

--暗器当前技能
function FoundryData:GetHWCurSkill()

	local cur_skill_info = {}
	if self.hideweapon_data then

		local target_index = self.hideweapon_data.cur_plan

		for k, v in pairs(self.hideweapon_data.skill_plans) do
			if v.plan.index == target_index then
				cur_skill_info = v.plan
				break
			end
		end
	end

	return cur_skill_info
end

function FoundryData:GetHWPreviewSkillList()

	local list = {}

	for k, v in pairs(config.anqi_skill) do

		if v.quality == 1 then
			table.insert(list, v.id)
		end
	end

	table.sort(list, function(a, b)
		return a < b
	end)

	return list
end

--更新淬毒信息
function FoundryData:UpdateHWPoisonInfo(data)

	if self.hideweapon_data then

		local poison_slots = self.hideweapon_data.poison_slots

		for k, v in pairs(poison_slots) do

			if v.slot.index == data.poison_slot.index then
				poison_slots[k] = nil
				break
			end
		end

		local t = {}
		t.slot = data.poison_slot
		table.insert(poison_slots, t)
	end
end

function FoundryData:GetStrenSuitLv()

    local career = game.RoleCtrl.instance:GetCareer()
    local suit_cfg = config.equip_stren_suit[career]
    local stren_lv_list = {}
    for pos = 1, 8 do

        local equip_info = self:GetEquipInfoByType(pos)
        if equip_info then
            table.insert(stren_lv_list, equip_info.stren)
        else
            table.insert(stren_lv_list, 0)
        end
    end

    local godweapon_data = self:GetGodweaponData()
    if godweapon_data and godweapon_data.id > 0 then
        table.insert(stren_lv_list, godweapon_data.stren)
    end

    local hideweapon_data = self:GetHideWeaponData()
    if hideweapon_data and hideweapon_data.id > 0 then
        table.insert(stren_lv_list, hideweapon_data.stren)
    end

    local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    if weaponsoul_data and weaponsoul_data.id > 0 then
        table.insert(stren_lv_list, weaponsoul_data.stren)
    end

    local dragon_equip = self:GetEquipInfoByType(12)
    if dragon_equip then
        table.insert(stren_lv_list, dragon_equip.stren)
    end

    local stren_suit_lv = 0

    for k, v in pairs(suit_cfg) do

        local need_lv = v.lv
        local need_num = v.num

        local count = 0
        for _, stren_lv in pairs(stren_lv_list) do

            if stren_lv >= need_lv then
                count = count + 1
            end
        end

        if count >= need_num then
            stren_suit_lv = stren_suit_lv + 1
        end
    end

    return stren_suit_lv, stren_lv_list
end

function FoundryData:CheckCanInlay(stone_pos)

	local bag_data = game.BagCtrl.instance:GetData()
	local equip_pos = math.floor(stone_pos/10)

	local equip_info
	if equip_pos < 9 then
		equip_info = self:GetEquipInfoByType(equip_pos)
	elseif equip_pos == 9 then
		equip_info = self:GetGodweaponData()
	elseif equip_pos == 10 then
		equip_info = self:GetHideWeaponData()
	elseif equip_pos == 11 then
        equip_info = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    elseif equip_pos == 12 then
		equip_info = self:GetEquipInfoByType(12)
	end

	if not equip_info then
		return false
	end

	local stone_id
	for k,v in pairs(equip_info.stones) do
		if v.pos == stone_pos then
			stone_id = v.id
			break
		end
	end

	local inlay_stone_cfg = config.equip_stone_pos[equip_pos][stone_pos]
	local career = game.RoleCtrl.instance:GetCareer()
	local stone_type_list = inlay_stone_cfg["inlay_type_"..career]

	local list = bag_data:GetStonesByTypes(stone_type_list)

	if not stone_id then		
		if next(list) then
			return true
		else
			return false
		end
	else

		local stone_type = config.equip_stone2[stone_id].type
		local exist_better = false
		for stone_item_id, v in pairs(config.equip_stone[stone_type]) do

			if stone_item_id > stone_id then

				local num = game.BagCtrl.instance:GetNumById(stone_item_id)
				if num > 0 then
					exist_better = true
					break
				end
			end
		end

		return exist_better
	end
end

function FoundryData:CheckEquipCanStone(equip_pos)

	if equip_pos == 9 then
		if not (self.godweapon_data and self.godweapon_data.id > 0) then
			return false
		end
	end

	if equip_pos == 10 then
		if not (self.hideweapon_data and self.hideweapon_data.id > 0) then
			return false
		end
	end

	if equip_pos == 11 then
		local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()

		if not (weaponsoul_data and weaponsoul_data.id > 0) then
			return false
		end
	end

	if equip_pos == 12 then
		local dragon_equip = self:GetEquipInfoByType(12)

		if not (dragon_equip and dragon_equip.id > 0) then
			return false
		end
	end

	local can_inlay = false

	for stone_pos, v in pairs(config.equip_stone_pos[equip_pos]) do

		if self:CheckCanInlay(stone_pos) then
			can_inlay = true
			break
		end
	end

	return can_inlay
end

function FoundryData:GetAllPoisonAttrList()

	local poison_attr_list = {}

	if self.hideweapon_data then
		local poison_slots = self.hideweapon_data.poison_slots

		for k,v in pairs(poison_slots)  do

			for i, j in pairs(v.slot.attr) do

				if not poison_attr_list[j.id] then
					poison_attr_list[j.id] = j.value
				end

				poison_attr_list[j.id] = poison_attr_list[j.id] + j.value
			end
		end
	end

	return poison_attr_list
end

function FoundryData:SetGodweaponChip(data)
	if self.godweapon_data then

		local exist = false
		for k,v in pairs(self.godweapon_data.chips) do
			if v.lv == data.lv then
				v.take = data.take
				exist = true
				break
			end
		end

		if not exist then
			table.insert(self.godweapon_data.chips, data)
		end
	end
end

function FoundryData:GetGodweaponChipState(level)

	local state = 0

	if self.godweapon_data then

		for k,v in pairs(self.godweapon_data.chips) do
			if v.lv == level then
				state = v.take + 1
				break
			end
		end
	end

	return state
end

function FoundryData:CheckGetGodweapon()

	local is_open = false

	if self.godweapon_data then
		if self.godweapon_data.id > 0 then
			is_open = true
		end
	end

	return is_open
end

function FoundryData:GetGodweaponChipText()

	local str = ""

	if self.godweapon_data then
		local count = #self.godweapon_data.chips
		str = tostring(count).."/"..tostring(5)
	end

	return str
end

function FoundryData:CheckAllEquipCanStone()

	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	if main_role_lv < 17 then
		return false
	end

	local is_can_stone = false

	for i = 1, 10 do
		if self:CheckEquipCanStone(i) then
			is_can_stone = true
			break
		end
	end

	return is_can_stone
end

function FoundryData:CheckCanStren()

	local can_stren = false

	local main_role_lv = game.Scene.instance:GetMainRoleLevel()

	for i = 1, 8 do

		local equip_info = self:GetEquipInfoByType(i)
        if equip_info then

        	local equip_stren_cfg = config.equip_stren[equip_info.stren][i]
            local cost_item_id = equip_stren_cfg.cost[1]
            local cost_item_num = equip_stren_cfg.cost[2]
            local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

            if cur_num >= cost_item_num then
                if main_role_lv > equip_info.stren then
                	can_stren = true
                end
            end
        end
	end

	local godweapon_data = game.FoundryCtrl.instance:GetData():GetGodweaponData()
    if godweapon_data and godweapon_data.id > 0 then
    	local equip_stren_cfg = config.equip_stren[godweapon_data.stren][9]
        local cost_item_id = equip_stren_cfg.cost[1]
        local cost_item_num = equip_stren_cfg.cost[2]
        local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
        if cur_num >= cost_item_num then
            if main_role_lv > godweapon_data.stren then
                can_stren = true
            end
        end
    end

    local hideweapon_data = game.FoundryCtrl.instance:GetData():GetHideWeaponData()
    if hideweapon_data and hideweapon_data.id > 0 then

        local equip_stren_cfg = config.equip_stren[hideweapon_data.stren][10]
        local cost_item_id = equip_stren_cfg.cost[1]
        local cost_item_num = equip_stren_cfg.cost[2]
        local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

        if cur_num >= cost_item_num then
            if main_role_lv > hideweapon_data.stren then
            	can_stren = true
            end
        end
    end

    local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
    if weaponsoul_data and weaponsoul_data.id > 0 then

        local equip_stren_cfg = config.equip_stren[weaponsoul_data.stren][11]
        local cost_item_id = equip_stren_cfg.cost[1]
        local cost_item_num = equip_stren_cfg.cost[2]
        local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

        if cur_num >= cost_item_num then
            if main_role_lv > weaponsoul_data.stren then
            	can_stren = true
            end
        end
    end

    local dragon_equip = self:GetEquipInfoByType(12)
    if dragon_equip and dragon_equip.id > 0 then
    	 local equip_stren_cfg = config.equip_stren[dragon_equip.stren][12]
        local cost_item_id = equip_stren_cfg.cost[1]
        local cost_item_num = equip_stren_cfg.cost[2]
        local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

        if cur_num >= cost_item_num then
            if main_role_lv > dragon_equip.stren then
            	can_stren = true
            end
        end
    end

	return can_stren
end

function FoundryData:CheckEquipHd()

	if self:CheckCanStren() then
		return true
	end

	if self:CheckAllEquipCanStone() then
		return true
	end

	if self:CheckCanCompose() then
		return true
	end

	return false
end

function FoundryData:CheckGodweaponChipHd()

	local can_get = false

	if self.godweapon_data then

		local count = 0

		for k,v in pairs(self.godweapon_data.chips) do
			if v.take == 0 then
				can_get = true
			elseif v.take == 1 then
				count = count + 1
			end
		end

		--可以突破
		if count == 5 then
			can_get = true
		end
	end

	return can_get
end

function FoundryData:GetEquipCombat(equip_pos)

    local equip_info
	if equip_pos < 9 then
		equip_info = self:GetEquipInfoByType(equip_pos)
	elseif equip_pos == 9 then
		equip_info = self:GetGodweaponData()
	elseif equip_pos == 10 then
		equip_info = self:GetHideWeaponData()
	end

	if (not equip_info) or equip_info.id == 0 then
		return 0
	end

	if equip_pos < 9 then
		local goods_config = config.goods[equip_info.id]
		local base_score = game.Utils.CalculateCombatPower2(goods_config.attr)
	    local random_score = game.Utils.CalculateCombatPower2(equip_info.attr)
	    local total_score = base_score + random_score

	    return total_score
	elseif equip_pos == 9 then
		local gw_id = equip_info.id
	    local career = math.floor(gw_id/100)
		local gw_cfg = config.artifact_base[career][gw_id]
		local base_score = game.Utils.CalculateCombatPower2(gw_cfg.attr)

		return base_score
	elseif equip_pos == 10 then
		local cur_model_id = equip_info.id
    	local cur_cfg = config.anqi_model[cur_model_id]
    	local base_score = game.Utils.CalculateCombatPower2(cur_cfg.attr)
    	local add_score = game.Utils.CalculateCombatPower3(equip_info.add_attr)
    	local total_score = base_score + add_score
    	return total_score
	end
end

function FoundryData:GetSmeltLv()
	if self.smelt_data then
		return self.smelt_data.level
	else
		return 0
	end
end

function FoundryData:GetStrenLv(pos)

	local stren_lv = 0

	--1-8常规
	if pos < 9 or (pos == 12) then
		local exist = false
		for k, v in pairs(self.equip_info.equips) do

			if v.equip.pos == pos then
				stren_lv = v.equip.stren
				break
			end
		end
	--神器
	elseif pos == 9 then
		if self.godweapon_data then
			stren_lv = self.godweapon_data.stren
		end
	elseif pos == 10 then
		if self.hideweapon_data then
			stren_lv = self.hideweapon_data.stren
		end
	elseif pos == 11 then
		local weaponsoul_data = game.WeaponSoulCtrl.instance:GetData():GetAllData()
		if weaponsoul_data then
			stren_lv = weaponsoul_data.stren
		end
	end

	return stren_lv
end

function FoundryData:CheckCanCompose()

	local main_role_lv = game.Scene.instance:GetMainRoleLevel()
	if main_role_lv < 20 then
		return false
	end

	local item_list = game.FoundryCtrl.instance:GetComposeBagItemList()
	
	--单个选择
	local flag = false
	for k, item_info in pairs(item_list) do
		local sour_item_id = item_info.goods.id

		if config.compose[sour_item_id].red_point == 1 then
			local sour_item_num = item_info.goods.num
			local target_item_id = config.compose[sour_item_id].target
			local target_cost_num = config.compose[sour_item_id].cost_num

			if sour_item_num >= target_cost_num then
				flag = true
				break
			end
		end
	end

	--两个选择
	for k, item_info in pairs(item_list) do
		local sour_item_id = item_info.goods.id
		if config.compose[sour_item_id].red_point == 1 then
			local target_cost_num = config.compose[sour_item_id].cost_num
			local sour_num = 0	--包括绑定和非绑定

			for j, v in pairs(item_list) do

				if v.goods.id == sour_item_id then
					sour_num = sour_num + v.goods.num
				end
			end

			if sour_num >= target_cost_num then
				flag = true
				break
			end
		end
	end

	return flag
end

return FoundryData