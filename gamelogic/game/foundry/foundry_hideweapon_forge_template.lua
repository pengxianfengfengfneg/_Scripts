local FoundryHideweaponForgeTemplate = Class(game.UITemplate)

function FoundryHideweaponForgeTemplate:_init(parent)
	self._package_name = "ui_foundry"
    self._com_name = "foundry_hideweapon_forge_template"
    self.parent = parent
    self.foundry_data = game.FoundryCtrl.instance:GetData()
end

function FoundryHideweaponForgeTemplate:OpenViewCallBack()

	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs.cost_item)
    self.cost_item:Open()
    self.cost_item:ResetItem()

    self._layout_objs["n59"]:AddClickCallBack(function()
        game.FoundryCtrl.instance:CsAnqiForge()
    end)

    self:BindEvent(game.FoundryEvent.UpdateHWForge, function()
        self:InitView()
    end)

	self:InitView()
end

function FoundryHideweaponForgeTemplate:CloseViewCallBack()
	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end

    if self.model2 then
        self.model2:DeleteMe()
        self.model2 = nil
    end
end

function FoundryHideweaponForgeTemplate:InitView()

	local hideweapon_data = self.foundry_data:GetHideWeaponData()
	local cur_model_id = hideweapon_data.id
	local max_model_id = #config.anqi_model
	local cur_cfg = config.anqi_model[cur_model_id]

	self._layout_objs["name1"]:SetText(cur_cfg.name)

	self:ShowModel(cur_model_id, self._layout_objs["model"])
	self._layout_objs["model"]:SetVisible(true)

	local star = cur_cfg.star
	for i = 1, 9 do
		if i <= star then
			self._layout_objs["left_xing"..i]:SetVisible(true)
		else
			self._layout_objs["left_xing"..i]:SetVisible(false)
		end
	end

	self._layout_objs["left_max_txt"]:SetText(cur_cfg.level_max)

	if cur_model_id < max_model_id then

		local next_cfg = config.anqi_model[cur_model_id+1]
		self._layout_objs["name2"]:SetText(next_cfg.name)

		self:ShowModel2(next_cfg.model, self._layout_objs["model2"])
		self._layout_objs["model2"]:SetVisible(true)

		local star = next_cfg.star
		for i = 1, 9 do
			if i <= star then
				self._layout_objs["right_xing"..i]:SetVisible(true)
			else
				self._layout_objs["right_xing"..i]:SetVisible(false)
			end
		end

		self._layout_objs["right_max_txt"]:SetText(next_cfg.level_max)


		--打造所需
		local cost_item_id = next_cfg.forge_source[1]
		local cost_item_num = next_cfg.forge_source[2]
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

		local main_role_lv = game.Scene.instance:GetMainRoleLevel()
		self._layout_objs["level_limit"]:SetText(string.format(config.words[1274], next_cfg.lv, main_role_lv))
	else
		self._layout_objs["name2"]:SetText("")
		self._layout_objs["model2"]:SetVisible(false)
	end
end

function FoundryHideweaponForgeTemplate:ShowModel(weapon_id, model_obj)

	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
    self._layout_objs["model"]:SetVisible(true)

    self.model = require("game/character/model_template").New()
    self.model:CreateDrawObj(model_obj, game.BodyType.Weapon)
    self.model:SetPosition(-0.04, -0.26, 1)
    self.model:SetRotation(0.57, 191, -2.76)
    self.model:SetModel(game.ModelType.AnQi, weapon_id, true)
    self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.AnQi)
end

function FoundryHideweaponForgeTemplate:ShowModel2(weapon_id, model_obj)

	if self.model2 then
        self.model2:DeleteMe()
        self.model2 = nil
    end
    self._layout_objs["model2"]:SetVisible(true)

    self.model2 = require("game/character/model_template").New()
    self.model2:CreateDrawObj(model_obj, game.BodyType.Weapon)
    self.model2:SetPosition(-0.04, -0.26, 1)
    self.model2:SetRotation(0.57, 191, -2.76)
    self.model2:SetModel(game.ModelType.AnQi, weapon_id, true)
    self.model2:PlayAnim(game.ObjAnimName.Idle, game.ModelType.AnQi)
end

return FoundryHideweaponForgeTemplate