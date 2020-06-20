local WeaponSoulJPTemplate = Class(game.UITemplate)

function WeaponSoulJPTemplate:_init(parent)
	self.parent = parent
	self.ctrl = game.WeaponSoulCtrl.instance
	self.weapon_soul_data = self.ctrl:GetData()
end

function WeaponSoulJPTemplate:_delete()
end

function WeaponSoulJPTemplate:OpenViewCallBack()

	self:InitView()

	self:ShowList(1)

	self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
		self:ShowList(idx+1)
	end)

    self._layout_objs["attr_btn"]:AddClickCallBack(function()
    	self.ctrl:OpenWeaponSoulJPAttrView()
    end)

    self._layout_objs["huanhua_btn"]:AddClickCallBack(function()
    	self.ctrl:CsWarriorSoulChangeAvatar(self.huanhua_jp_id)
    end)

    self.get_way = self._layout_objs["get_way"]
    self.get_way:AddClickCallBack(handler(self, self.OnClickGetWay))

    self:BindEvent(game.WeaponSoulEvent.ChangeAvatar, function(data)
    	self:ShowList(self.select_type or 1)
    end)

    self.tab_controller:SetSelectedIndexEx(0)
end

function WeaponSoulJPTemplate:CloseViewCallBack()
	if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end
end

function WeaponSoulJPTemplate:InitView()

	local all_data = self.weapon_soul_data:GetAllData()
	local star_lv = all_data.star_lv
	local star_up_cfg = config.weapon_soul_star_up[star_lv]

	self._layout_objs["combat_txt"]:SetText(all_data.a_combat_power)

	self.list = self._layout_objs["n139"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/weapon_soul/weapon_soul_jp_item").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
    	self:OnClickItem(item.idx)
    end)

    self.ui_list:SetItemNum(0)
end

function WeaponSoulJPTemplate:ShowList(type)
	self.select_type = type

	self.id_list = self.ctrl:GetGpIdList(type)

	self.ui_list:SetItemNum(#self.id_list)

	self:OnClickItem(1)
end

function WeaponSoulJPTemplate:GetListData()
	return self.id_list
end

function WeaponSoulJPTemplate:OnClickItem(click_index)
	self.ui_list:Foreach(function(item)
		item:SetSelected(item.idx == click_index)
	end)

	local jp_id = self.id_list[click_index]
	local jp_cfg = config.weapon_soul_avatar[jp_id]
	self.jp_goods_id = jp_cfg.icon

	self._layout_objs["name"]:SetText(jp_cfg.name)

	local attr_str = ""
	local count = 1
	for k,v in ipairs(jp_cfg.attr) do
		local attr_name = config_help.ConfigHelpAttr.GetAttrName(v[1])
		local str = attr_name.."  +"..tostring(v[2])

		if count == 1 then
			attr_str = attr_str..str
		else
			attr_str = attr_str.."    "..str
		end

		count = count + 1
	end
	self._layout_objs["attr"]:SetText(attr_str)

	local all_data = self.weapon_soul_data:GetAllData()
	local txt
	if self.select_type == 1 then
		txt = self._layout_objs["get_way"]
		self._layout_objs["get_way"]:SetVisible(true)
		self._layout_objs["get_way2"]:SetVisible(false)
	else
		txt = self._layout_objs["get_way2"]
		self._layout_objs["get_way2"]:SetVisible(true)
		self._layout_objs["get_way"]:SetVisible(false)
	end
	if jp_cfg.type == 3 then
		local nh_times = all_data.conden_num
		txt:SetText(string.format(jp_cfg.way, nh_times))
	else
		txt:SetText(jp_cfg.way)
	end

	local state = self.weapon_soul_data:GetJPState(jp_id)
	if state == 0 then
		self._layout_objs["huanhua_btn"]:SetTouchEnable(false)
		self._layout_objs["huanhua_btn"]:SetGray(true)
		self._layout_objs["huanhua_btn"]:SetText(config.words[6109])
	elseif state == 1 then
		self._layout_objs["huanhua_btn"]:SetTouchEnable(true)
		self._layout_objs["huanhua_btn"]:SetGray(false)
		self._layout_objs["huanhua_btn"]:SetText(config.words[6109])
		self.huanhua_jp_id = jp_id
	elseif state == 2 then
		self._layout_objs["huanhua_btn"]:SetTouchEnable(true)
		self._layout_objs["huanhua_btn"]:SetGray(false)
		self._layout_objs["huanhua_btn"]:SetText(config.words[6110])
		self.huanhua_jp_id = 0
	end

	self:SetModel(jp_cfg.model)
end

function WeaponSoulJPTemplate:SetModel(model_id)

	if not self.model then
	    self.model = require("game/character/model_template").New()
	    self.model:CreateDrawObj(self._layout_objs["model"], game.ModelType.WuHunUI)
	    self.model:SetPosition(0, -0.31, 0.82)
	    self.model:SetRotation(-2.583, 218, -2.76)
	    self.model:SetAlwaysAnim(true)
	end

    self.model:SetModel(game.ModelType.WuHunUI, model_id, true)
    self.model:PlayAnim(game.ObjAnimName.Idle, game.ModelType.WuHunUI)
end

function WeaponSoulJPTemplate:OnClickGetWay()
	if self.jp_goods_id then
		game.ShopCtrl.instance:OpenViewByShopId(2, self.jp_goods_id)
	end
end

return WeaponSoulJPTemplate