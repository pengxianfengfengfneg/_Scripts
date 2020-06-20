local FoundryGodweaponForgeTemplate = Class(game.UITemplate)

function FoundryGodweaponForgeTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "godweapon_forge_template"
    self.parent = parent
end

function FoundryGodweaponForgeTemplate:OpenViewCallBack()

	self.is_auto = false
	self._layout_objs["auto_sz_btn"]:SetText(config.words[1275])
	self.foundry_data = game.FoundryCtrl.instance:GetData()

	self.cost_item = require("game/bag/item/goods_item").New()
	self.cost_item:SetVirtual(self._layout_objs["need_item"])
    self.cost_item:Open()
    self.cost_item:ResetItem()
    self.cost_item:SetShowTipsEnable(true)

    for i = 1, 5 do

    	self._layout_objs["img"..i]:SetTouchDisabled(false)
		self._layout_objs["img"..i]:AddClickCallBack(function()
			self:DoSelectPos(i)
		end)
    end

	self:BindEvent(game.FoundryEvent.UpdateGodweaponInfoPos, function(data)
        self:InitView(data)
        if self.parent.forge_index then
        	self:DoSelectPos(self.parent.forge_index)
        else
        	self:DoSelectPos(1)
        end
        self:DoAutoForge()
    end)

    self:BindEvent(game.FoundryEvent.UpdateGodweaponInfo, function(data)
        self:InitView(data)
        if self.parent.forge_index then
        	self:DoSelectPos(self.parent.forge_index)
        else
        	self:DoSelectPos(1)
        end
    end)

    self:BindEvent(game.FoundryEvent.UpdateGodweaponTupo, function(data)
        self:InitView(data)
        self:DoSelectPos(1)
    end)

	--自动神铸
    self._layout_objs["auto_sz_btn"]:AddClickCallBack(function()
    	if self.is_auto then
    		self._layout_objs["auto_sz_btn"]:SetText(config.words[1275])
    		self.is_auto = false
    	else
	        self.is_auto = true
	        self._layout_objs["auto_sz_btn"]:SetText(config.words[1276])
	        self:DoAutoForge()
	    end
    end)

    --神铸
    self._layout_objs["sz_btn"]:AddClickCallBack(function()
    	if self.select_pos then
    		self.is_auto = false
        	game.FoundryCtrl.instance:CsArtifactAddExtraAttr(self.select_pos)
        else
        	game.GameMsgCtrl.instance:PushMsg(config.words[1254])
        end
    end)

    --突破
    self._layout_objs["tp_btn"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:CsArtifactLvUp()
    end)

    --图鉴
    self._layout_objs["btn_tj"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:OpenGodWeaponShowView()
    end)

end

function FoundryGodweaponForgeTemplate:CloseViewCallBack()
	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function FoundryGodweaponForgeTemplate:InitView()

	local data = self.foundry_data:GetGodweaponData()
	local id = data.id
	local career = game.RoleCtrl.instance:GetCareer()
	local cfg = config.artifact_base[career][id]
	local next_cfg = config.artifact_base[career][id+1]
	if not next_cfg then
		next_cfg = cfg
	end

	local finish_count = 0
	for pos = 1, 5 do

		local attr_type = cfg["part_upper"..pos][1]
		local cur_attr_value = 0
		local part_attr = self.foundry_data:GetGodweaponPosAttr(pos)
		if part_attr then
			cur_attr_value = part_attr.value
		end

		local max_value = cfg["part_upper"..pos][2]
		local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)

		self._layout_objs["top_attr"..pos]:SetText(attr_name)
		self._layout_objs["top_attrt"..pos]:SetText(tostring(cur_attr_value).."/"..tostring(max_value))

		self._layout_objs["img"..pos]:SetFillAmount(cur_attr_value/max_value)

		if cur_attr_value >= max_value then
			finish_count = finish_count + 1
		end
	end

	--突破
	if finish_count >= 5 then
		self._layout_objs["auto_sz_btn"]:SetVisible(false)
		self._layout_objs["sz_btn"]:SetVisible(false)
		self._layout_objs["tp_btn"]:SetVisible(true)
	else
		self._layout_objs["auto_sz_btn"]:SetVisible(true)
		self._layout_objs["sz_btn"]:SetVisible(true)
		self._layout_objs["tp_btn"]:SetVisible(false)
	end

	--总属性
	local all_attr_list = {}

	for k, v in pairs(cfg.attr) do
		all_attr_list[v[1]] = v[2]
	end

	for k, v in pairs(data.extra_attr) do
		if not all_attr_list[v.id] then
			all_attr_list[v.id] = v.value
		else
			all_attr_list[v.id] = all_attr_list[v.id] + v.value
		end
	end

	local sort_attr_list = {}
	for attr_type, attr_value in pairs(all_attr_list) do

		if attr_type ~= 5 and attr_type ~= 6 then
			local t = {}
			t.id = attr_type
			t.value = attr_value
			table.insert(sort_attr_list, t)
		end
	end

	for attr_type, attr_value in pairs(all_attr_list) do
		if attr_type == 5 or attr_type == 6 then
			local t = {}
			t.id = attr_type
			t.value = attr_value
			table.insert(sort_attr_list, 1, t)
		end
	end

	local count = 1
	for k, attr_info in pairs(sort_attr_list) do

		if count < 13 then
			local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_info.id)
			self._layout_objs["attr"..count]:SetText(attr_name..": "..tostring(attr_info.value))
			count = count + 1
		end
	end

	--技能
	local skill_id = cfg.skill
	local skill_desc = config.skill[skill_id][1].desc
	local skill_name = config.skill[skill_id][1].name
	local skill_icon = config.skill[skill_id][1].icon
	self._layout_objs["skill_name"]:SetText(skill_name)
	self._layout_objs["skill_desc"]:SetText(skill_desc)
	self._layout_objs["skill_icon"]:SetSprite("ui_main", skill_icon)

	--消耗
	local part_source = cfg.part_source
	if finish_count >= 5 then
		part_source = next_cfg.upgrade_source
	end
	self.cost_item:SetItemInfo({ id = part_source[1], num = part_source[2]})

	local cur_num = game.BagCtrl.instance:GetNumById(part_source[1])

	self.cost_item:SetNumText(cur_num.."/"..part_source[2])

	if cur_num >= part_source[2] then
		self.cost_item:SetColor(224, 214, 189)
		self.cost_item:SetShowTipsEnable(true)
	else
		self.cost_item:SetColor(255, 0, 0)
		self.cost_item:SetShowTipsEnable(true)
	end

	self._layout_objs["combat_txt"]:SetText(data.combat_power)

	self._layout_objs["equip_name"]:SetText(cfg.name)

	self:ShowModel(cfg.model)
end

function FoundryGodweaponForgeTemplate:DoSelectPos(index)

	for i = 1, 5 do
		self._layout_objs["select_img"..i]:SetVisible(i==index)
	end

	self.select_pos = index
	self.parent.forge_index = index

	--当前部位是否可以再铸造
	local data = self.foundry_data:GetGodweaponData()
	local id = data.id
	local career = game.RoleCtrl.instance:GetCareer()
	local cfg = config.artifact_base[career][id]
	local next_cfg = config.artifact_base[career][id+1]
	if not next_cfg then
		next_cfg = cfg
	end

	local cur_attr_value = 0
	local part_attr = self.foundry_data:GetGodweaponPosAttr(index)
	if part_attr then
		cur_attr_value = part_attr.value
	end

	local max_value = cfg["part_upper"..index][2]

	if cur_attr_value >= max_value then
		self._layout_objs["n78"]:SetVisible(false)
		self._layout_objs["max_tips"]:SetVisible(true)
		self._layout_objs["max_btn"]:SetVisible(true)
		self._layout_objs["auto_sz_btn"]:SetVisible(false)
		self._layout_objs["sz_btn"]:SetVisible(false)
	else
		self._layout_objs["n78"]:SetVisible(true)
		self._layout_objs["max_tips"]:SetVisible(false)
		self._layout_objs["max_btn"]:SetVisible(false)
		self._layout_objs["auto_sz_btn"]:SetVisible(true)
		self._layout_objs["sz_btn"]:SetVisible(true)
	end

	local finish_count = 0
	for pos = 1, 5 do
		local cur_attr_value = 0
		local part_attr = self.foundry_data:GetGodweaponPosAttr(pos)
		if part_attr then
			cur_attr_value = part_attr.value
		end

		local max_value = cfg["part_upper"..pos][2]
		if cur_attr_value >= max_value then
			finish_count = finish_count + 1
		end
	end

	--突破
	if finish_count >= 5 then
		self._layout_objs["n78"]:SetVisible(true)
		self._layout_objs["auto_sz_btn"]:SetVisible(false)
		self._layout_objs["sz_btn"]:SetVisible(false)
		self._layout_objs["tp_btn"]:SetVisible(true)
		self._layout_objs["max_tips"]:SetVisible(false)
		self._layout_objs["max_btn"]:SetVisible(false)

		local mainrole_lv = game.Scene.instance:GetMainRoleLevel()
		self._layout_objs["n88"]:SetText(string.format(config.words[5222], next_cfg.lv))
		self._layout_objs["n89"]:SetText(string.format(config.words[5223], mainrole_lv))
		self._layout_objs["lv_limit_txt"]:SetVisible(true)
	else
		self._layout_objs["lv_limit_txt"]:SetVisible(false)
	end

	--满级
	if (id%100) == 7 and finish_count >= 5 then
		self._layout_objs["n78"]:SetVisible(false)
		self._layout_objs["tp_btn"]:SetVisible(false)
		self._layout_objs["lv_limit_txt"]:SetVisible(false)
	end
end

function FoundryGodweaponForgeTemplate:DoAutoForge()

	if not self.is_auto then
		return
	end

	local select_pos = 1

	if self.select_pos then
		select_pos = self.select_pos
	end

	local data = self.foundry_data:GetGodweaponData()
	local id = data.id
	local career = game.RoleCtrl.instance:GetCareer()
	local cfg = config.artifact_base[career][id]

	local can_forge = false
	for i = 0, 4 do

		local target_pos = select_pos + i
		if target_pos > 5 then
			target_pos = target_pos - 5
		end

		local cur_attr_value = 0
		local part_attr = self.foundry_data:GetGodweaponPosAttr(target_pos)
		if part_attr then
			cur_attr_value = part_attr.value
		end

		local max_value = cfg["part_upper"..target_pos][2]

		if cur_attr_value < max_value then
			self:DoSelectPos(target_pos)
			game.FoundryCtrl.instance:CsArtifactAddExtraAttr(target_pos)
			can_forge = true
			break
		end
	end

	if not can_forge then
		self.is_auto = false
		self._layout_objs["auto_sz_btn"]:SetText(config.words[1275])
	end
end

function FoundryGodweaponForgeTemplate:ShowModel(weapon_id)

	if self.tween then
        self.tween:Kill(false)
        self.tween = nil
    end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self._layout_objs["model"]:SetVisible(true)

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(self._layout_objs["model"], game.BodyType.Weapon)
    self.model:SetPosition(-0.04, -0.87, 2.7)
    self.model:SetRotation(0.57, 191, -2.76)
    self.model:SetModel(game.ModelType.WeaponUI, weapon_id, true)
    self.model:SetAlwaysAnim(true)
    self.model:PlayAnim(game.ObjAnimName.Show1, game.ModelType.WeaponUI)
    self.model:SetModelChangeCallBack(function()
    	local cfg = config.artifact_show[weapon_id]
    	local pos = cfg.ui_pos
    	self.model:SetPosition(pos[1], pos[2], pos[3])
    	self.model:SetScale(cfg.ui_show_ratio)

    	local show_effct = cfg.show_effect
	    for k, v in pairs(show_effct) do
	    	self.model:SetEffect(v[1], v[2], game.ModelType.WeaponUI, true)
	    end

	    self.tween = DOTween.Sequence()
	    self.tween:AppendInterval(5)
	    self.tween:AppendCallback(function()
	        self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.WeaponUI)
	        local idle_effect = cfg.idle_effect
		    for k, v in pairs(idle_effect) do
		    	self.model:SetEffect(v[1], v[2], game.ModelType.WeaponUI, true)
		    end
	    end)
    end)    
end

return FoundryGodweaponForgeTemplate