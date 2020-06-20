local DragonDesignUpgradeTemplate = Class(game.UITemplate)

function DragonDesignUpgradeTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.DragonDesignCtrl.instance
	self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignUpgradeTemplate:_delete()
end

function DragonDesignUpgradeTemplate:OpenViewCallBack()

	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs["cost_item"])
    self.cost_item:Open()

    self:InitView()

    self._layout_objs["py_btn"]:AddClickCallBack(function()

    	if self.dragon_design_data:CanUpgrade() then
			self.ctrl:CsDragonLevelUp()
		else
			self:DoMoneyExchange()
		end
    end)

    self.is_auto = false
    self._layout_objs["auto_py_btn"]:AddClickCallBack(function()
		if self.is_auto then
    		self._layout_objs["auto_py_btn"]:SetText(config.words[6154])
    		self.is_auto = false
    	else
	        self.is_auto = true
	        self._layout_objs["auto_py_btn"]:SetText(config.words[6155])
	        self:DoAutoUpgrade()
	    end
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateGrowth, function(data)
    	self:InitView()

    	self:DoAutoUpgrade()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateReplace, function(data)
    	self:InitView()
    end)
end

function DragonDesignUpgradeTemplate:CloseViewCallBack()
	if self.cost_item then
        self.cost_item:DeleteMe()
        self.cost_item = nil
    end
end

function DragonDesignUpgradeTemplate:InitView()
	
	local all_data = self.dragon_design_data:GetAllData()
	local growth_lv = all_data.growth_lv			--等级
	local growth_hole = all_data.growth_hole		--属性孔
	local growth_cfg = config.dragon_growth[growth_lv][growth_hole]

	local show_lv = (growth_lv == #config.dragon_growth) and (growth_lv - 1) or growth_lv
	self._layout_objs["lv_txt"]:SetText(string.format(config.words[1006], show_lv))

	if growth_lv == #config.dragon_growth then
		self._layout_objs["tips"]:SetVisible(true)
		self._layout_objs["auto_py_btn"]:SetVisible(false)
		self._layout_objs["py_btn"]:SetVisible(false)
	else
		self._layout_objs["tips"]:SetVisible(false)
		self._layout_objs["auto_py_btn"]:SetVisible(true)
		self._layout_objs["py_btn"]:SetVisible(true)
	end

	for i = 1, 7 do
		if i ~= (growth_hole+1) then
			self._layout_objs["bg"..i]:SetVisible(false)
			self._layout_objs["hole_attr"..i]:SetText("")
		else
			self._layout_objs["bg"..i]:SetVisible(true)
			self._layout_objs["hole_attr"..i]:SetText(growth_cfg.desc)
		end
	end

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
			local percent = self.dragon_design_data:GetQualityPercent(i-3)
			local add_val = math.floor(attr_val*percent)
			local str1 = attr_name..":  "..(attr_val + add_val)
			self._layout_objs["attr"..i]:SetText(string.format(config.words[6125], str1, add_val))
			t.value = attr_val + add_val
		else
			self._layout_objs["attr"..i]:SetText(attr_name..":  "..attr_val)
		end

		table.insert(attr_list, t)
	end

	--战力
	local combat_power = game.Utils.CalculateCombatPower3(attr_list)
	self._layout_objs["combat_txt"]:SetText(combat_power)

	local cost_item_id = growth_cfg.material[1]
    local cost_item_num = growth_cfg.material[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

    self.cost_item:SetItemInfo({ id = cost_item_id, num = cost_item_num})
    self.cost_item:SetNumText(cur_num.."/"..cost_item_num)
    self.cost_item:SetShowTipsEnable(true)

    if cur_num >= cost_item_num then
        self.cost_item:SetColor(224, 214, 189)
    else
        self.cost_item:SetColor(255, 0, 0)
    end

    self._layout_objs["cost"]:SetText(growth_cfg.coin)

    if self.dragon_design_data:CanUpgrade() then
    	self._layout_objs["auto_py_btn/hd"]:SetVisible(true)
    	self._layout_objs["py_btn/hd"]:SetVisible(true)
	else
		self._layout_objs["auto_py_btn/hd"]:SetVisible(false)
    	self._layout_objs["py_btn/hd"]:SetVisible(false)
	end

	self:PlayEffect(growth_hole+1)
end

function DragonDesignUpgradeTemplate:DoAutoUpgrade()

	if not self.is_auto then
		return
	end

	if self.dragon_design_data:CanUpgrade() then
		self.ctrl:CsDragonLevelUp()
	else
		self:DoAutoMoneyExchange()
	end
end

function DragonDesignUpgradeTemplate:DoMoneyExchange()

	local all_data = self.dragon_design_data:GetAllData()
	local growth_lv = all_data.growth_lv			--等级
	local growth_hole = all_data.growth_hole		--属性孔
	local growth_cfg = config.dragon_growth[growth_lv][growth_hole]

	local cost_item_id = growth_cfg.material[1]
    local cost_item_num = growth_cfg.material[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
    local cur_copper = game.BagCtrl.instance:GetCopper()

    if cur_num >= cost_item_num and  cur_copper < growth_cfg.coin then
		game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, growth_cfg.coin - cur_copper, function()
	        self.ctrl:CsDragonLevelUp()
	    end)
	else
		game.GameMsgCtrl.instance:PushMsg(config.words[6158])
	end
end

function DragonDesignUpgradeTemplate:DoAutoMoneyExchange()

	local all_data = self.dragon_design_data:GetAllData()
	local growth_lv = all_data.growth_lv			--等级
	local growth_hole = all_data.growth_hole		--属性孔
	local growth_cfg = config.dragon_growth[growth_lv][growth_hole]

	local cost_item_id = growth_cfg.material[1]
    local cost_item_num = growth_cfg.material[2]
    local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)
    local cur_copper = game.BagCtrl.instance:GetCopper()


    if cur_num >= cost_item_num and  cur_copper < growth_cfg.coin then
		game.MainUICtrl.instance:OpenAutoMoneyExchangeView(game.MoneyType.Copper, growth_cfg.coin - cur_copper, function()
	        self.ctrl:CsDragonLevelUp()
	    end)
	else
		game.GameMsgCtrl.instance:PushMsg(config.words[6158])
		self._layout_objs["auto_py_btn"]:SetText(config.words[6154])
    	self.is_auto = false
	end
end

function DragonDesignUpgradeTemplate:PlayEffect(index)
	for i = 1, 7 do
		if i <= index then
			self._layout_objs["effect"..tostring(i)]:SetVisible(true)
			local ui_effect = self:CreateUIEffect(self._layout_objs["effect"..i], "effect/ui/dragon_fire.ab", 10)
		    ui_effect:SetLoop(true)
		else
			self._layout_objs["effect"..tostring(i)]:SetVisible(false)
		end
	end
end

return DragonDesignUpgradeTemplate