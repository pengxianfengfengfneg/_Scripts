local FoundryHideweaponPracticeTemplate = Class(game.UITemplate)

function FoundryHideweaponPracticeTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "foundry_hideweapon_practice_template"
    self.parent = parent
    self.foundry_data = game.FoundryCtrl.instance:GetData()
end

function FoundryHideweaponPracticeTemplate:OpenViewCallBack()

	local hideweapon_data = self.foundry_data:GetHideWeaponData()
	local cur_practice_lv = hideweapon_data.practice_lv

	--修炼模块
	if cur_practice_lv < 100 then
		self.parent:SetBtnLabelName(1)
		self._layout_objs["practice_model"]:SetVisible(true)
		self._layout_objs["poison_plane"]:SetVisible(false)
		self.is_auto = false
		self.cost_item = require("game/bag/item/goods_item").New()
		self.cost_item:SetVirtual(self._layout_objs.cost_item)
		self.cost_item:Open()
		self.cost_item:SetItemInfo({ id = config.anqi_base[1].practice_cost[1], num = config.anqi_base[1].practice_cost[2] })

		self._layout_objs["auto_practice_btn"]:SetText(config.words[1283])
		self._layout_objs["auto_practice_btn"]:AddClickCallBack(function()
			if self.is_auto then
				self._layout_objs["auto_practice_btn"]:SetText(config.words[1283])
				self.is_auto = false
			else
				self._layout_objs["auto_practice_btn"]:SetText(config.words[1284])
				self.is_auto = true
				self:DoAutoPractice()
			end
		end)

		self._layout_objs["practice_btn"]:AddClickCallBack(function()
			self.is_auto = false
			game.FoundryCtrl.instance:CsAnqiPractice()
		end)

		self._layout_objs["n4"]:SetTouchDisabled(false)
		self._layout_objs["n4"]:AddClickCallBack(function()
			game.FoundryCtrl.instance:OpenHideWeaponShowView()
		end)

		self:BindEvent(game.FoundryEvent.UpdateHWPractice, function()
			self:InitView()
			self:DoAutoPractice()
		end)

		self:BindEvent(game.FoundryEvent.UpdateHWForge, function()
			self:InitView()
		end)

		self:InitView()
	--淬毒模块
	else
		self.parent:SetBtnLabelName(2)
		self._layout_objs["practice_model"]:SetVisible(false)
		self._layout_objs["poison_plane"]:SetVisible(true)

		self.cost_item2 = require("game/bag/item/goods_item").New()
		self.cost_item2:SetVirtual(self._layout_objs["poison_plane/n36"])
		self.cost_item2:Open()
		self.cost_item2:ResetItem()
		self.cost_item2:SetShowTipsEnable(true)

		self:InitPoison()
		self:UpdatePoison()
	end
end

function FoundryHideweaponPracticeTemplate:CloseViewCallBack()

	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	if self.cost_item2 then
		self.cost_item2:DeleteMe()
		self.cost_item2 = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

local GetAttrOffsetValue = function(cur_practice_lv, attr_type)

	local cur_attr_value = 0
	for k, v in pairs(config.anqi_practice[cur_practice_lv].attr) do

		if v[1] == attr_type then
			cur_attr_value = v[2]
			break
		end
	end

	local next_attr_value = 0
	for k, v in pairs(config.anqi_practice[cur_practice_lv+1].attr) do

		if v[1] == attr_type then
			next_attr_value = v[2]
			break
		end
	end

	return next_attr_value - cur_attr_value
end

local sort_attr = function(a, b)
	return a.id < b.id
end

--更新初始化暗器修炼/淬毒
function FoundryHideweaponPracticeTemplate:InitView()

	local hideweapon_data = self.foundry_data:GetHideWeaponData()
	local cur_practice_lv = hideweapon_data.practice_lv
	local max_practice_lv = #config.anqi_practice
	local origin_attr = hideweapon_data.origin_attr
	local cur_model_id = hideweapon_data.id
	local cur_cfg = config.anqi_model[cur_model_id]

	self._layout_objs["name"]:SetText(cur_cfg.name)
	self._layout_objs["n54"]:SetText(tostring(cur_practice_lv)..config.words[1217])

	--原始属性
	local count = 1
	table.sort(origin_attr, sort_attr)
	for k, v in ipairs(origin_attr) do

		local attr_type = v.id
		local attr_value = v.value

		if attr_type ~= 5 and attr_type ~= 6 then

			local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
			self._layout_objs["attr"..count]:SetText(string.format(config.words[1258], attr_name, attr_value))

			if cur_practice_lv < max_practice_lv then

				local offset_value = GetAttrOffsetValue(cur_practice_lv, attr_type)
				local next_attr_value = offset_value + attr_value

				self._layout_objs["next_attr"..count]:SetText(tostring(next_attr_value))
			else
				self._layout_objs["next_attr"..count]:SetText("")
			end

			count = count + 1
		end
	end

	--修炼所需
	local cur_num = game.BagCtrl.instance:GetNumById(config.anqi_base[1].practice_cost[1])

	self.cost_item:SetNumText(cur_num.."/"..config.anqi_base[1].practice_cost[2])

	if cur_num >= config.anqi_base[1].practice_cost[2] then
		self.cost_item:SetColor(224, 214, 189)
		self.cost_item:SetShowTipsEnable(true)
		self._layout_objs["auto_practice_btn/hd"]:SetVisible(true)
	else
		self.cost_item:SetColor(255, 0, 0)
		self.cost_item:SetShowTipsEnable(true)
		self._layout_objs["auto_practice_btn/hd"]:SetVisible(false)
	end

	--修炼进度
	if cur_practice_lv < max_practice_lv then

		self._layout_objs["n55"]:SetVisible(true)
		self._layout_objs["n56"]:SetText(tostring(cur_practice_lv+1)..config.words[1217])

		local need_exp = config.anqi_practice[cur_practice_lv+1].progress
		local cur_exp = hideweapon_data.practice_exp

		self._layout_objs["n11"]:SetProgressValue(cur_exp/need_exp*100)
		self._layout_objs["n11"]:GetChild("title"):SetText(cur_exp.."/"..need_exp)
	else
		self._layout_objs["n55"]:SetVisible(false)
		self._layout_objs["n56"]:SetText("")

		self._layout_objs["n11"]:SetProgressValue(100)
		self._layout_objs["n11"]:GetChild("title"):SetText(config.words[2201])
		self._layout_objs["auto_practice_btn/hd"]:SetVisible(false)
	end

	self._layout_objs["combat_txt"]:SetText(hideweapon_data.combat_power)

	--武器模型
	if hideweapon_data.id ~= self.hideweapon_id then
		self:ShowWeapon(hideweapon_data.id)
		self.hideweapon_id = hideweapon_data.id
	end

	if cur_practice_lv == 100 then
		self.parent:SetBtnLabelName(2)
		self._layout_objs["practice_model"]:SetVisible(false)
		self._layout_objs["poison_plane"]:SetVisible(true)

		self.cost_item2 = require("game/bag/item/goods_item").New()
		self.cost_item2:SetVirtual(self._layout_objs["poison_plane/n36"])
		self.cost_item2:Open()
		self.cost_item2:ResetItem()
		self.cost_item2:SetShowTipsEnable(true)

		self:InitPoison()
		self:UpdatePoison()
	end
end

function FoundryHideweaponPracticeTemplate:DoAutoPractice()

	if not self.is_auto then
		return
	end

	local item_id = config.anqi_base[1].practice_cost[1]
	local num = config.anqi_base[1].practice_cost[2]

	local cur_num = game.BagCtrl.instance:GetNumById(item_id)

	if cur_num >= num then
		game.FoundryCtrl.instance:CsAnqiPractice()
	else
		self.is_auto = false
		self._layout_objs["auto_practice_btn"]:SetText(config.words[1283])
	end
end

function FoundryHideweaponPracticeTemplate:ShowWeapon(weapon_id)

    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self._layout_objs["model"]:SetVisible(true)

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs["model"], game.BodyType.Weapon)
    self.model:SetPosition(-0.04, -0.26, 1)
    self.model:SetRotation(0.57, 191, -2.76)
    self.model:SetModel(game.ModelType.AnQi, weapon_id, true)
    self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.AnQi)
end

----------------------------淬毒模块---------------------------------

function FoundryHideweaponPracticeTemplate:InitPoison()

	for i = 1, 5 do
		local cfg = config.anqi_poison[i]
		self._layout_objs["poison_plane/item_name"..i]:SetText(cfg.name)
		self._layout_objs["poison_plane/item_img"..i]:SetTouchDisabled(false)
		self._layout_objs["poison_plane/item_img"..i]:AddClickCallBack(function()
			self:DoSelectPoisonPos(i)
		end)
	end

	self:BindEvent(game.FoundryEvent.UpdateHWPoison, function(data)
		self:UpdatePoison()
		if self.select_pos then
			self:DoSelectPoisonPos(self.select_pos)
		end
    end)

	--淬毒
	self._layout_objs["poison_plane/use_btn"]:AddClickCallBack(function()
		game.FoundryCtrl.instance:CsAnqiOpenPoisonSlot(self.select_pos)
	end)

	--替换
	self._layout_objs["poison_plane/replace_btn"]:AddClickCallBack(function()
		if self.poison_slot then
			local cur_attr = self.poison_slot.attr
			local create_attr = self.poison_slot.sub_attr

			if next(create_attr) then
				local cur_combat = config_help.ConfigHelpAttr.CalcCombatPower2(cur_attr)
				local create_combat = config_help.ConfigHelpAttr.CalcCombatPower2(create_attr)

				if create_combat < cur_combat then
					local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[1277])
			        msg_box:SetOkBtn(function()
			            game.FoundryCtrl.instance:CsAnqiReplacePoisonAttr(self.select_pos)
			            msg_box:Close()
			            msg_box:DeleteMe()
			        end)
			        msg_box:SetCancelBtn(function()
			            end)
			        msg_box:Open()
				else 
					game.FoundryCtrl.instance:CsAnqiReplacePoisonAttr(self.select_pos)
				end
			else
				game.GameMsgCtrl.instance:PushMsg(config.words[1278])
			end
		end
	end)

	--炼毒
	self._layout_objs["poison_plane/create_btn"]:AddClickCallBack(function()
		game.FoundryCtrl.instance:CsAnqiCreatePoison(self.select_pos)
	end)

	self:DoSelectPoisonPos(1)
end

function FoundryHideweaponPracticeTemplate:UpdatePoison()

	local hideweapon_data = self.foundry_data:GetHideWeaponData()
	local poison_slots = hideweapon_data.poison_slots

	for i = 1, 5 do

		local poison_slot
		for k, v in pairs(poison_slots) do

			if v.slot.index == i then
				poison_slot = v.slot
				break
			end
		end

		if poison_slot then
			self._layout_objs["poison_plane/select_lock"..i]:SetVisible(false)
		else
			self._layout_objs["poison_plane/select_lock"..i]:SetVisible(true)
		end
	end
end

function FoundryHideweaponPracticeTemplate:DoSelectPoisonPos(index)

	self.select_pos = index

	for i = 1, 5 do
		self._layout_objs["poison_plane/select_p"..i]:SetVisible(i==index)
	end

	local hideweapon_data = self.foundry_data:GetHideWeaponData()
	local poison_slots = hideweapon_data.poison_slots
	local poison_slot
	for k, v in pairs(poison_slots) do

		if v.slot.index == index then
			poison_slot = v.slot
			break
		end
	end
	self.poison_slot = poison_slot

	local cfg = config.anqi_poison[index]

	self._layout_objs["poison_plane/target_img"]:SetSprite("ui_foundry", "p"..index)

	self._layout_objs["poison_plane/n3"]:SetText(cfg.name)
	self._layout_objs["poison_plane/n5"]:SetText(cfg.desc)

	if poison_slot then
		self._layout_objs["poison_plane/n4"]:SetText(poison_slot.lv..config.words[1217])
		self._layout_objs["poison_plane/use_btn"]:SetVisible(false)
		self._layout_objs["poison_plane/replace_btn"]:SetVisible(true)
		self._layout_objs["poison_plane/create_btn"]:SetVisible(true)
		self._layout_objs["poison_plane/before_plane"]:SetVisible(false)
		self._layout_objs["poison_plane/after_plane"]:SetVisible(true)
		self:SetPoison(poison_slot)
	else
		self._layout_objs["poison_plane/n4"]:SetText(config.words[1266])
		self._layout_objs["poison_plane/use_btn"]:SetVisible(true)
		self._layout_objs["poison_plane/replace_btn"]:SetVisible(false)
		self._layout_objs["poison_plane/create_btn"]:SetVisible(false)
		self._layout_objs["poison_plane/before_plane"]:SetVisible(true)
		self._layout_objs["poison_plane/after_plane"]:SetVisible(false)

		self:SetUnPoison()
	end
end

function FoundryHideweaponPracticeTemplate:SetUnPoison()

	local career = game.RoleCtrl.instance:GetCareer()
	local poison_cfg = config.anqi_poison[self.select_pos]

	local attr_cfg = poison_cfg["attr"..career]

	for k, attr_type in ipairs(attr_cfg) do

		local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
		self._layout_objs["poison_plane/attr"..k]:SetText(attr_name)
	end

	local cost_item_id = config.anqi_base[1].unlock_poison_cost[1]
	local cost_item_num = config.anqi_base[1].unlock_poison_cost[2]
	local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

	self.cost_item2:SetItemInfo({ id = cost_item_id, num = cost_item_num})
	self.cost_item2:SetNumText(cur_num.."/"..cost_item_num)

	if cur_num >= cost_item_num then
		self.cost_item2:SetColor(224, 214, 189)
	else
		self.cost_item2:SetColor(255, 0, 0)
	end
end

function FoundryHideweaponPracticeTemplate:SetPoison(poison_slot)

	self:ResetAttrText()

	local lv = poison_slot.lv
	local exp = poison_slot.exp
	local need_exp = config.anqi_poison_lv[lv+1] and config.anqi_poison_lv[lv+1].exp or config.anqi_poison_lv[lv].exp
	local cur_attr = poison_slot.attr
	local create_attr = poison_slot.sub_attr

	local cur_combat = config_help.ConfigHelpAttr.CalcCombatPower2(cur_attr)
	local create_combat = config_help.ConfigHelpAttr.CalcCombatPower2(create_attr)

	self._layout_objs["poison_plane/replace_btn/hd"]:SetVisible(create_combat > cur_combat)


	self._layout_objs["poison_plane/exp_bar"]:SetProgressValue(exp/need_exp*100)
	self._layout_objs["poison_plane/exp_bar"]:GetChild("title"):SetText(exp.."/"..need_exp)

	for k, v in ipairs(cur_attr) do

		local attr_name = config_help.ConfigHelpAttr.GetAttrName(v.id)

		self._layout_objs["poison_plane/cur_po_attr_name"..k]:SetText(attr_name)
		self._layout_objs["poison_plane/cur_po_attr_value"..k]:SetText(tostring(v.value))
	end

	for k, v in ipairs(create_attr) do

		local attr_name = config_help.ConfigHelpAttr.GetAttrName(v.id)

		self._layout_objs["poison_plane/next_po_attr_name"..k]:SetText(attr_name)


		if v.value > cur_attr[k].value then
			self._layout_objs["poison_plane/next_po_attr_value"..k]:SetColor(54, 122, 33, 255)
		elseif v.value < cur_attr[k].value then
			self._layout_objs["poison_plane/next_po_attr_value"..k]:SetColor(219, 71, 52, 255)
		else
			self._layout_objs["poison_plane/next_po_attr_value"..k]:SetColor(112, 83, 52, 255)
		end

		self._layout_objs["poison_plane/next_po_attr_value"..k]:SetText(tostring(v.value))
	end

	local cost_item_id = config.anqi_base[1].execute_poison_cost[1]
	local cost_item_num = config.anqi_base[1].execute_poison_cost[2]
	local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

	self.cost_item2:SetItemInfo({ id = cost_item_id, num = cost_item_num})
	self.cost_item2:SetNumText(cur_num.."/"..cost_item_num)

	if cur_num >= cost_item_num then
		self.cost_item2:SetColor(224, 214, 189)
	else
		self.cost_item2:SetColor(255, 0, 0)
	end
end

function FoundryHideweaponPracticeTemplate:ResetAttrText()

	for k = 1, 3 do

		self._layout_objs["poison_plane/cur_po_attr_name"..k]:SetText("")
		self._layout_objs["poison_plane/cur_po_attr_value"..k]:SetText("")

		self._layout_objs["poison_plane/next_po_attr_name"..k]:SetText("")
		self._layout_objs["poison_plane/next_po_attr_value"..k]:SetText("")
	end
end

return FoundryHideweaponPracticeTemplate