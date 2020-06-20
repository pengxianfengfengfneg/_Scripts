local WeaponSoulSXTemplate = Class(game.UITemplate)

function WeaponSoulSXTemplate:_init(parent)
	self.parent = parent
	self.weapon_soul_data = game.WeaponSoulCtrl.instance:GetData()
end

function WeaponSoulSXTemplate:_delete()
end

function WeaponSoulSXTemplate:OpenViewCallBack()
	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs.cost_item)
    self.cost_item:Open()
    self.cost_item:ResetItem()

    self.skill_item1 = require("game/bag/item/goods_item").New()
    self.skill_item1:SetVirtual(self._layout_objs["skill_item1"])
    self.skill_item1:Open()
    self.skill_item1:ResetItem()

    self.skill_item2 = require("game/bag/item/goods_item").New()
    self.skill_item2:SetVirtual(self._layout_objs["skill_item2"])
    self.skill_item2:Open()
    self.skill_item2:ResetItem()

    self._layout_objs["sx_btn"]:AddClickCallBack(function()
    	game.WeaponSoulCtrl.instance:CsWarriorSoulStarUp()
    end)

    --图鉴
    self._layout_objs["tujian"]:SetTouchDisabled(false)
    self._layout_objs["tujian"]:AddClickCallBack(function()
    	game.WeaponSoulCtrl.instance:OpenWeaponSoulShowView()
    end)

    self:InitView()

    self:SetModel()

    self:BindEvent(game.WeaponSoulEvent.ShengXing, function(data)
    	self:InitView()

    	self:SetModel()
    end)

    self:BindEvent(game.WeaponSoulEvent.RefreshCombat, function(data)
    	local all_data = self.weapon_soul_data:GetAllData()
    	self._layout_objs["combat_txt"]:SetText(all_data.combat_power)
    end)
end

function WeaponSoulSXTemplate:CloseViewCallBack()
	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	if self.skill_item2 then
		self.skill_item2:DeleteMe()
		self.skill_item2 = nil
	end

	if self.skill_item1 then
		self.skill_item1:DeleteMe()
		self.skill_item1 = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function WeaponSoulSXTemplate:InitView()
	local all_data = self.weapon_soul_data:GetAllData()
	local star_lv = all_data.star_lv
	local lv = all_data.id
	local star_up_cfg = config.weapon_soul_star_up[star_lv]

	self._layout_objs["name"]:SetText(star_up_cfg.name)

	-- self._layout_objs["skill_item1/image"]:SetSprite("ui_item", star_up_cfg.icon)
	self.skill_item1:SetItemInfo({id = tonumber(star_up_cfg.icon)})

	for i = 1, 9 do
		if i <= star_lv then
			self._layout_objs["cur_star"..i]:SetVisible(true)
		else
			self._layout_objs["cur_star"..i]:SetVisible(false)
		end
	end

	self._layout_objs["cur_desc"]:SetText(string.format(config.words[6102], (star_lv+1)))

	local next_star_up_cfg = config.weapon_soul_star_up[star_lv+1]
	if next_star_up_cfg then

		self._layout_objs["next_desc"]:SetText(string.format(config.words[6102], (star_lv+2)))
		-- self._layout_objs["skill_item2/image"]:SetSprite("ui_item", star_up_cfg.icon)
		self.skill_item2:SetItemInfo({id = tonumber(next_star_up_cfg.icon)})

		for i = 1, 9 do
			if i <= star_lv+1 then
				self._layout_objs["next_star"..i]:SetVisible(true)
			else
				self._layout_objs["next_star"..i]:SetVisible(false)
			end
		end

		local cost_item_id = next_star_up_cfg.upgrade_cost[1]
		local cost_item_num = next_star_up_cfg.upgrade_cost[2]
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

		self._layout_objs["n42"]:SetText(string.format(config.words[6103], next_star_up_cfg.refine_lv))
	
		if (cur_num >= cost_item_num) and (lv>=next_star_up_cfg.refine_lv) then
			self._layout_objs["sx_btn/hd"]:SetVisible(true)
			self.parent:SetTabRedPoint("hd2", true)
		else
			self._layout_objs["sx_btn/hd"]:SetVisible(false)
			self.parent:SetTabRedPoint("hd2", false)
		end
	else
		self._layout_objs["n7"]:SetVisible(false)

		self._layout_objs["n42"]:SetText("")

		self._layout_objs["cost_item"]:SetVisible(false)

		self._layout_objs["sx_btn/hd"]:SetVisible(false)
		self.parent:SetTabRedPoint("hd2", false)
	end

	self._layout_objs["combat_txt"]:SetText(all_data.combat_power)
end

function WeaponSoulSXTemplate:SetModel()

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

return WeaponSoulSXTemplate