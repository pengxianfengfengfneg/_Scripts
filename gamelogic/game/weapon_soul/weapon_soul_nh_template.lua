local WeaponSoulNHTemplate = Class(game.UITemplate)

function WeaponSoulNHTemplate:_init(parent)
	self.parent = parent
	self.weapon_soul_data = game.WeaponSoulCtrl.instance:GetData()
end

function WeaponSoulNHTemplate:_delete()
end

function WeaponSoulNHTemplate:OpenViewCallBack()

	self.cost_item = require("game/bag/item/goods_item").New()
    self.cost_item:SetVirtual(self._layout_objs.cost_item)
    self.cost_item:Open()
    self.cost_item:ResetItem()

    self._layout_objs["nh_btn"]:AddClickCallBack(function()

    	if self.select_type_index then

    		if self.weapon_soul_data:CheckCanSaveNingHun(self.select_type_index) then
	    		local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[102], config.words[6113])
		        msg_box:SetOkBtn(function()
		        	if self._layout_objs.btn_checkbox:GetSelected() then 
		    			game.WeaponSoulCtrl.instance:CsWarriorSoulConden(self.select_type_index, 1)
		    		else
		    			game.WeaponSoulCtrl.instance:CsWarriorSoulConden(self.select_type_index, 0)
		    		end
		            msg_box:DeleteMe()
		        end)
		        msg_box:SetCancelBtn(function()
		            msg_box:DeleteMe()
		            end)
		        msg_box:Open()
		    else
	    		if self._layout_objs.btn_checkbox:GetSelected() then 
	    			game.WeaponSoulCtrl.instance:CsWarriorSoulConden(self.select_type_index, 1)
	    		else
	    			game.WeaponSoulCtrl.instance:CsWarriorSoulConden(self.select_type_index, 0)
	    		end
	    	end
    	end
    end)

    self._layout_objs["save_btn"]:AddClickCallBack(function()
    	if self.select_type_index then
    		game.WeaponSoulCtrl.instance:CsWarriorSoulSaveConden(self.select_type_index, {{index = 0}})
    	end
    end)

    --图鉴
    self._layout_objs["tujian"]:SetTouchDisabled(false)
    self._layout_objs["tujian"]:AddClickCallBack(function()
    	game.WeaponSoulCtrl.instance:OpenWeaponSoulShowView()
    end)

    for i = 1, 4 do
    	self._layout_objs["img"..i]:SetTouchDisabled(false)
    	self._layout_objs["img"..i]:AddClickCallBack(function()
    		self:OnClickSelect(i)
    	end)

    	self._layout_objs["chang_btn"..i]:AddClickCallBack(function()
    		self:OnClickChangeAttr(i)
    	end)
    end

    self:SetCostItem(1)

    self._layout_objs.btn_checkbox:SetSelected(false)
    self._layout_objs.btn_checkbox:AddClickCallBack(function()
        if self._layout_objs.btn_checkbox:GetSelected() then
            self:SetCostItem(10)
        else
            self:SetCostItem(1)
        end
    end)

    self:InitView()

    self:SetModel()

    self:OnClickSelect(1)

    self:BindEvent(game.WeaponSoulEvent.NingHun, function(data)
    	if self.select_type_index == data.type then
    		self:SetAttr(data.type)
    	end

    	if self._layout_objs.btn_checkbox:GetSelected() then
            self:SetCostItem(10)
        else
            self:SetCostItem(1)
        end
    end)

    self:BindEvent(game.WeaponSoulEvent.RefreshNingHun, function(data)
    	if self.select_type_index == data.new_part.type then
    		self:SetAttr(data.new_part.type)
    	end

    	if self._layout_objs.btn_checkbox:GetSelected() then
            self:SetCostItem(10)
        else
            self:SetCostItem(1)
        end
    end)

    self:BindEvent(game.WeaponSoulEvent.RefreshCombat, function(data)
    	local all_data = self.weapon_soul_data:GetAllData()
    	self._layout_objs["combat_txt"]:SetText(all_data.combat_power)
    end)

    self:BindEvent(game.WeaponSoulEvent.ShengXing, function(data)
    	self:RefreshView()

    	self:InitView()

    	self:SetModel()
    end)
end

function WeaponSoulNHTemplate:CloseViewCallBack()
	if self.cost_item then
		self.cost_item:DeleteMe()
		self.cost_item = nil
	end
	if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function WeaponSoulNHTemplate:OnClickSelect(index)

	for i = 1, 4 do
		self._layout_objs["sel"..i]:SetVisible(i==index)
	end

	self.select_type_index = index

	self:SetAttr(index)
end

function WeaponSoulNHTemplate:InitView()

	local all_data = self.weapon_soul_data:GetAllData()
	local star_lv = all_data.star_lv

	self._layout_objs["combat_txt"]:SetText(all_data.combat_power)
	self._layout_objs["name"]:SetText(config.weapon_soul_star_up[star_lv].name)
end

local getAttrMaxValue = function(attr_limit, attr_type)

	local max_value = 100

	for k, v in pairs(attr_limit) do
		if v[1] == attr_type then
			max_value = v[2]
			break
		end
	end

	return max_value
end

function WeaponSoulNHTemplate:SetAttr(type_index)

	local all_data = self.weapon_soul_data:GetAllData()
	local star_lv = all_data.star_lv
	local attr_limit = config.weapon_soul_star_up[star_lv].attr_limit
	local soul_part_info = self.weapon_soul_data:GetSoulPartInfoByType(type_index)
	local un_save_attr = soul_part_info.conden_ret.alters

	for k, v in ipairs(soul_part_info.attr) do

		local attr_type = v.id
		local attr_value = v.value
		local attr_name = config_help.ConfigHelpAttr.GetAttrName(attr_type)
		self._layout_objs["attr"..k]:SetText(attr_name)

		local max_value = getAttrMaxValue(attr_limit, attr_type)

		local per = math.ceil(attr_value/max_value*100)
		self._layout_objs["bar"..k]:SetProgressValue(per)

		self._layout_objs["bar"..k]:GetChild("title"):SetText(attr_value.."/"..max_value)

		local alter_attr
		for i, j in pairs(un_save_attr) do
			if j.id == attr_type then
				alter_attr = j
				break
			end
		end

		if alter_attr then
			local off_value = alter_attr.value
			if off_value > 0 then
				self._layout_objs["arrow"..k]:SetSprite("ui_common", "jia")
				self._layout_objs["arrow"..k]:SetVisible(true)
				self._layout_objs["delta"..k]:SetText(off_value)
				self._layout_objs["delta"..k]:SetColor(54,122,33,255)
			elseif off_value < 0 then
				self._layout_objs["arrow"..k]:SetSprite("ui_common", "zb_04")
				self._layout_objs["arrow"..k]:SetVisible(true)
				self._layout_objs["delta"..k]:SetText(off_value)
				self._layout_objs["delta"..k]:SetColor(255,0,0,255)
			else
				self._layout_objs["arrow"..k]:SetVisible(false)
				self._layout_objs["delta"..k]:SetText("+0")
				self._layout_objs["delta"..k]:SetColor(112,83,52,255)
			end
		else
			self._layout_objs["arrow"..k]:SetVisible(false)
			self._layout_objs["delta"..k]:SetText("")
		end
	end

	self._layout_objs["combat_txt"]:SetText(all_data.combat_power)

	if self.weapon_soul_data:CheckCanSaveNingHun(type_index) then
		self._layout_objs["save_btn/hd"]:SetVisible(true)
	else
		self._layout_objs["save_btn/hd"]:SetVisible(false)
	end
end

function WeaponSoulNHTemplate:SetCostItem(multiple)

	local cost_item_id = config.weapon_soul_base[1].conden_soul_items[1]
	local cost_item_num = config.weapon_soul_base[1].conden_soul_items[2] * multiple
	local cur_num = game.BagCtrl.instance:GetNumById(cost_item_id)

	self.cost_item:SetItemInfo({ id = cost_item_id, num = cost_item_num})
	self.cost_item:SetNumText(cur_num.."/"..cost_item_num)

	if cur_num >= cost_item_num then
		self.cost_item:SetColor(224, 214, 189)
		self.cost_item:SetShowTipsEnable(true)
	else
		self.cost_item:SetColor(255, 0, 0)
		self.cost_item:SetShowTipsEnable(true)
	end

	self._layout_objs["cost_gold"]:SetText(config.weapon_soul_base[1].conden_soul_coin * multiple)

	if self.weapon_soul_data:CheckCanNingHun(multiple) then
		self._layout_objs["nh_btn/hd"]:SetVisible(true)
		self.parent:SetTabRedPoint("hd3", true)
	else
		self._layout_objs["nh_btn/hd"]:SetVisible(false)
		self.parent:SetTabRedPoint("hd3", false)
	end
end

function WeaponSoulNHTemplate:OnClickChangeAttr(index)

	local soul_part_info = self.weapon_soul_data:GetSoulPartInfoByType(self.select_type_index)
	local attr_info = soul_part_info.attr[index]

	local params = {}
	params.type = self.select_type_index
	params.btn_index = index
	params.cur_attr_id = attr_info.id

	game.WeaponSoulCtrl.instance:OpenChangeAttrView(params)
end

function WeaponSoulNHTemplate:SetModel()

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

function WeaponSoulNHTemplate:RefreshView()
	self:SetAttr(self.select_type_index or 1)
end

return WeaponSoulNHTemplate