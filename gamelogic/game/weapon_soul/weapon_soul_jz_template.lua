local WeaponSoulJZTemplate = Class(game.UITemplate)

function WeaponSoulJZTemplate:_init(parent)
	self.parent = parent
	self.weapon_soul_data = game.WeaponSoulCtrl.instance:GetData()
end

function WeaponSoulJZTemplate:_delete()
end

function WeaponSoulJZTemplate:OpenViewCallBack()
	self.is_auto = false
	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs.cost_item)
    self.cost_item:Open()
    self.cost_item:ResetItem()

    self._layout_objs["jz_btn"]:AddClickCallBack(function()
        game.WeaponSoulCtrl.instance:CsWarriorSoulRefine()
    end)

    self._layout_objs["auto_jz_btn"]:AddClickCallBack(function()
    	if self.is_auto then
    		self._layout_objs["auto_jz_btn"]:SetText(config.words[6104])
    		self.is_auto = false
    	else
	        self.is_auto = true
	        self._layout_objs["auto_jz_btn"]:SetText(config.words[6105])
	        self:DoAutoJingZhu()
	    end
    end)

    --图鉴
    self._layout_objs["n2"]:SetTouchDisabled(false)
    self._layout_objs["n2"]:AddClickCallBack(function()
    	game.WeaponSoulCtrl.instance:OpenWeaponSoulShowView()
    end)

    for i = 1, 4 do
    	self._layout_objs["skill_item"..i.."/image"]:SetTouchDisabled(false)
    	self._layout_objs["skill_item"..i.."/image"]:AddClickCallBack(function ()
    		local all_data = self.weapon_soul_data:GetAllData()
			local star_lv = all_data.star_lv
			local skill_list = self.weapon_soul_data:GetJZSkillList()
			local skill_id = skill_list[i].id
			local skill_lv = 1+star_lv

			local params = {}
			params.skill_id = skill_id
			params.skill_lv = skill_lv
			game.WeaponSoulCtrl.instance:OpenSkillPreView(params)
    	end)
    end

    self:InitView()

    self:SetModel()

    self:BindEvent(game.WeaponSoulEvent.JingZhu, function(data)

    	self:InitView()

    	self:DoAutoJingZhu()
    end)

    self:BindEvent(game.WeaponSoulEvent.RefreshCombat, function(data)
    	local all_data = self.weapon_soul_data:GetAllData()
    	self._layout_objs["combat_txt"]:SetText(all_data.combat_power)
    end)

    self:BindEvent(game.WeaponSoulEvent.ShengXing, function(data)
    	self:InitView()

    	self:SetModel()
    end)
end

function WeaponSoulJZTemplate:CloseViewCallBack()
	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function WeaponSoulJZTemplate:InitView()

	local all_data = self.weapon_soul_data:GetAllData()
	local lv = all_data.id
	local star_lv = all_data.star_lv
	local refine_cfg = config.weapon_soul_refine[lv]

	self._layout_objs["name"]:SetText(config.weapon_soul_star_up[star_lv].name)

	self._layout_objs["cur_lv"]:SetText(string.format(config.words[2314], lv))

	--属性
	local next_refine_cfg
	if config.weapon_soul_refine[lv+1] then
		next_refine_cfg = config.weapon_soul_refine[lv+1]
		self._layout_objs["next_lv"]:SetText(string.format(config.words[2314], lv+1))
		self._layout_objs["next_lv"]:SetVisible(true)
	else
		self._layout_objs["next_lv"]:SetVisible(false)
		self._layout_objs["n7"]:SetVisible(false)
	end

	for k, v in ipairs(refine_cfg.attr) do

		local attr_type = v[1]
		local attr_value = v[2]
		local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
		self._layout_objs["attr"..k]:SetText(string.format(config.words[6111], attr_name, attr_value))

		if next_refine_cfg then
			local attr_value2 = next_refine_cfg.attr[k][2]
			self._layout_objs["next_attr"..k]:SetText(tostring(attr_value2))
		else
			self._layout_objs["next_attr"..k]:SetText("")
		end
	end

	--技能
	local skill_list = self.weapon_soul_data:GetJZSkillList()
	for k, v in ipairs(skill_list) do
		local skill_cfg = config.skill[v.id][1+star_lv]
		self._layout_objs["skill_item"..k.."/image"]:SetSprite("ui_skill_icon", v.id)
		self._layout_objs["skill_item"..k.."/bg"]:SetSprite("ui_common", "item" .. skill_cfg.color)
		if self.weapon_soul_data:CheckGetSkill(v.id) then
			self._layout_objs["skill_item"..k.."/lock_txt"]:SetText("")
			self._layout_objs["skill_item"..k.."/gray_img"]:SetVisible(false)
		else
			self._layout_objs["skill_item"..k.."/lock_txt"]:SetText(tostring(v.limit_lv)..config.words[3108])
			self._layout_objs["skill_item"..k.."/gray_img"]:SetVisible(true)
		end
	end

	--精铸所需
	if next_refine_cfg then
		local cost_item_id = next_refine_cfg.item_cost[1]
		local cost_item_num = next_refine_cfg.item_cost[2]
		local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

		self.cost_item:SetItemInfo({ id =cost_item_id, num = cost_item_num})
		self.cost_item:SetNumText(cur_num.."/"..cost_item_num)

		if cur_num >= cost_item_num then
			self.cost_item:SetColor(224, 214, 189)
			self.cost_item:SetShowTipsEnable(true)
		else
			self.cost_item:SetColor(255, 0, 0)
			self.cost_item:SetShowTipsEnable(true)
		end

		self._layout_objs["cost_gold"]:SetText(next_refine_cfg.coin_cost)

		local all_coin = game.BagCtrl.instance:GetCopper()
		if cur_num >= cost_item_num and all_coin >= next_refine_cfg.coin_cost then
			self._layout_objs["jz_btn/hd"]:SetVisible(true)
			self._layout_objs["auto_jz_btn/hd"]:SetVisible(true)
			self.parent:SetTabRedPoint("hd1", true)
		else
			self._layout_objs["jz_btn/hd"]:SetVisible(false)
			self._layout_objs["auto_jz_btn/hd"]:SetVisible(false)
			self.parent:SetTabRedPoint("hd1", false)
		end
	end

	self._layout_objs["n41"]:SetText(math.floor((refine_cfg.succ_rate+all_data.add_succ_rate)/100).."%")
	self._layout_objs["n42"]:SetText(string.format(config.words[6101], math.floor(refine_cfg.fail_add/100)))

	
	self._layout_objs["combat_txt"]:SetText(all_data.combat_power)
end

function WeaponSoulJZTemplate:DoAutoJingZhu()

	if not self.is_auto then
		return
	end

	if self.weapon_soul_data:CanJingZhu() then
		game.WeaponSoulCtrl.instance:CsWarriorSoulRefine()
	else
		self._layout_objs["auto_jz_btn"]:SetText(config.words[6104])
    	self.is_auto = false
	end
end

function WeaponSoulJZTemplate:SetModel()

	local all_data = self.weapon_soul_data:GetAllData()
	local star_lv = all_data.star_lv
	local model_id = config.weapon_soul_star_up[star_lv].model

	if not self.model then
	    self.model = require("game/character/model_template").New()
	    self.model:CreateDrawObj(self._layout_objs["model"], game.ModelType.WuHunUI)
	    self.model:SetPosition(-0.01, -0.04, 0.77)
	    self.model:SetRotation(0.57, 191, -2.76)
	    self.model:SetAlwaysAnim(true)
	end

    self.model:SetModel(game.ModelType.WuHunUI, model_id, true)
    self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.WuHunUI)
end

return WeaponSoulJZTemplate