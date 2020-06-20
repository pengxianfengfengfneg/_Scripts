local DragonDesignAttrTemplate = Class(game.UITemplate)

function DragonDesignAttrTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.DragonDesignCtrl.instance
	self.dragon_design_data = self.ctrl:GetData()
end

function DragonDesignAttrTemplate:_delete()
end

function DragonDesignAttrTemplate:OpenViewCallBack()

	self.goods_item_list = {}
    for i = 1, 4 do
        local item = self:GetTemplate("game/bag/item/goods_item", "inlay_item"..i)
        item:SetShowTipsEnable(true)
        item:ResetItem()
        self.goods_item_list[i] = item
    end

	self:InitView()

	self:ShowModel()

	self:BindEvent(game.DragonDesignEvent.UpdateReplace, function(data)
    	self:InitView()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateGrowth, function(data)
    	self:InitView()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateEquip, function(data)
    	self:InitView()
    end)

    self:BindEvent(game.DragonDesignEvent.UpdateEat, function(data)
    	self:InitView()
    end)
end

function DragonDesignAttrTemplate:CloseViewCallBack()
	for k, v in pairs(self.goods_item_list) do
        v:DeleteMe()
    end

    self.goods_item_list = nil

    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function DragonDesignAttrTemplate:InitView()

	local all_data = self.dragon_design_data:GetAllData()
	local growth_lv = all_data.growth_lv			--等级
	local growth_hole = all_data.growth_hole		--属性孔
	local growth_cfg = config.dragon_growth[growth_lv][growth_hole]
	local refine_star = all_data.refine_star	--星级
	local refine_lv = all_data.refine_lv		--品阶
	local refine_quality = all_data.refine_quality		--当前资质
	local refine_cfg = config.dragon_refine[refine_star][refine_lv]
	local quality_range = refine_cfg.quality_range

	local show_lv = (growth_lv == #config.dragon_growth) and (growth_lv - 1) or growth_lv
	self._layout_objs["lv_txt"]:SetText(string.format(config.words[1006], show_lv))

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

	--资质
	self._layout_objs["qua_txt"]:SetText(string.format(config.words[6123], refine_star, refine_lv))

	for i = 1, 5 do
		local qua_data
		for k, v in pairs(refine_quality) do
			if v.id == i then
				qua_data = v
				break
			end
		end

		if qua_data then

			local quality_max = quality_range[i][3]

			self._layout_objs["qua_txt"..i]:SetText(config.dragon_map[i].desc..":  "..qua_data.val.."("..quality_max..")")
		end
	end

	--镶嵌主龙元
	for i = 1, 4 do
		local main_pos = (i-1)*4 + 1
		local main_inlay_info = self.dragon_design_data:GetInlayInfoByPos(main_pos)
		self._layout_objs["unlock_lv"..i]:SetText("")
		if main_inlay_info and main_inlay_info.id > 0 then
			self.goods_item_list[i]:SetItemInfo({id=main_inlay_info.id})
			self.goods_item_list[i]:SetItemLevel(string.format(config.words[6266], main_inlay_info.level))
			self.goods_item_list[i]:AddClickEvent(function()
				self.ctrl:OpenDragonOperView(main_inlay_info, true)
			end)
		else

			--是否解锁
			local unlock_lv = config.dragon_pos[main_pos].unlock
			if growth_lv >= unlock_lv then
				self.goods_item_list[i]:ResetItem()
			else
				self._layout_objs["unlock_lv"..i]:SetText(string.format(config.words[6126], unlock_lv))
			end
			self.goods_item_list[i]:AddClickEvent(function()
			end)
		end
	end
end

function DragonDesignAttrTemplate:ShowModel()

	local model_obj = self._layout_objs["model"]

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self._layout_objs["model"]:SetVisible(true)

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(model_obj, game.BodyType.Weapon)
    self.model:SetPosition(-0.04, -0.26, 1)
    self.model:SetRotation(0.57, 191, -2.76)
    self.model:SetModel(game.ModelType.DragonDesign, 1, true)
    self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.DragonDesign)
end

return DragonDesignAttrTemplate