local FoundryHideweaponUpgradeTemplate = Class(game.UITemplate)

function FoundryHideweaponUpgradeTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "foundry_hideweapon_upgrade_template"
    self.parent = parent
end

function FoundryHideweaponUpgradeTemplate:OpenViewCallBack()

	self.is_auto = false
	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs.cost_item)
    self.cost_item:Open()
    self.cost_item:ResetItem()

    self._layout_objs["auto_upgrade_btn"]:SetText(config.words[1285])
    self._layout_objs["auto_upgrade_btn"]:AddClickCallBack(function()
    	if self.is_auto then
    		self._layout_objs["auto_upgrade_btn"]:SetText(config.words[1285])
    		self.is_auto = false
    	else
    		self._layout_objs["auto_upgrade_btn"]:SetText(config.words[1286])
	    	self.is_auto = true
	        self:DoAutoUpgrade()
	    end
    end)

    self._layout_objs["upgrade_btn"]:AddClickCallBack(function()
    	self.is_auto = false
        game.FoundryCtrl.instance:CsAnqiLvUp()
    end)

	self._layout_objs["n4"]:SetTouchDisabled(false)
	self._layout_objs["n4"]:AddClickCallBack(function()
		game.FoundryCtrl.instance:OpenHideWeaponShowView()
	end)

    self:BindEvent(game.FoundryEvent.UpdateHWUpgrade, function()
        self:InitView()
        self:DoAutoUpgrade()
    end)

    self:BindEvent(game.FoundryEvent.UpdateHWForge, function()
        self:InitView()
    end)

    self:InitView()
end

function FoundryHideweaponUpgradeTemplate:CloseViewCallBack()
	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

local sort_attr = function(a, b)
	return a.id < b.id
end

function FoundryHideweaponUpgradeTemplate:InitView()

	local hideweapon_data = game.FoundryCtrl.instance:GetData():GetHideWeaponData()

	self._layout_objs["combat_txt"]:SetText(hideweapon_data.combat_power)

	--暗器属性
	local add_attr = hideweapon_data.add_attr
	table.sort( add_attr, sort_attr)

	local count = 1
	for k, v in ipairs(add_attr) do

		if v.id ~= 5 and v.id ~= 6 then
			local attr_name = config_help.ConfigHelpAttr.GetAttrName(v.id)
			self._layout_objs["attr"..count]:SetText(attr_name..":  "..v.value)

			count = count + 1
		end
	end

	--品阶鉴定
	local cur_model_id = hideweapon_data.id
	local cur_cfg = config.anqi_model[cur_model_id]
	local max_lv = cur_cfg.level_max
	local cur_lv = hideweapon_data.q_level
	self._layout_objs["name"]:SetText(cur_cfg.name)
	self._layout_objs["n11"]:SetProgressValue(cur_lv/max_lv*100)
	self._layout_objs["n11"]:GetChild("title"):SetText(cur_lv.."/"..max_lv)

	--升阶所需
	local cost_item_id = config.anqi_base[1].up_level_cost[1]
	local cost_item_num = config.anqi_base[1].up_level_cost[2]
	local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
	self.cost_item:SetItemInfo({ id =cost_item_id, num = cost_item_num})
	self.cost_item:SetNumText(cur_num.."/"..cost_item_num)

	if cur_num >= cost_item_num then
		self.cost_item:SetColor(224, 214, 189)
		self.cost_item:SetShowTipsEnable(true)
		self._layout_objs["auto_upgrade_btn/hd"]:SetVisible(true)

	else
		self.cost_item:SetColor(255, 0, 0)
		self.cost_item:SetShowTipsEnable(true)
		self._layout_objs["auto_upgrade_btn/hd"]:SetVisible(false)
	end

	--武器模型
	self:ShowWeapon(cur_model_id)
end

function FoundryHideweaponUpgradeTemplate:DoAutoUpgrade()

	if not self.is_auto then
		return
	end

	local item_id = config.anqi_base[1].up_level_cost[1]
	local num = config.anqi_base[1].up_level_cost[2]

	local cur_num = game.BagCtrl.instance:GetNumById(item_id)

	if cur_num >= num then
		game.FoundryCtrl.instance:CsAnqiLvUp()
	else
		self.is_auto = false
		self._layout_objs["auto_upgrade_btn"]:SetText(config.words[1285])
	end
end

function FoundryHideweaponUpgradeTemplate:ShowWeapon(weapon_id)

	if weapon_id == self.cur_weapon_id then
		return
	end

	self.cur_weapon_id = weapon_id

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

return FoundryHideweaponUpgradeTemplate