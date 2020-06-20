local HairTemplate = Class(game.UITemplate)

function HairTemplate:_init(view)
	self.parent_view = view

    self.ctrl = game.FashionCtrl.instance    
end

function HairTemplate:OpenViewCallBack()
	self:Init()
	self:InitSlider()
	self:InitHairList()

	self:RegisterAllEvents()
end

function HairTemplate:CloseViewCallBack()
    for _,v in ipairs(self.hair_item_list or {}) do
    	v:DeleteMe()
    end
    self.hair_item_list = {}
end

function HairTemplate:Init()
	self.txt_cost_name = self._layout_objs["txt_cost_name"]	
	self.txt_cost_num = self._layout_objs["txt_cost_num"]	

	self.btn_get_mat = self._layout_objs["btn_get_mat"]	
	self.btn_change_hair = self._layout_objs["btn_change_hair"]	

	self.btn_get_mat:AddClickCallBack(function()

	end)

	self.btn_change_hair:AddClickCallBack(function()
		self.ctrl:SendHairSwitch(self:CalcHairId())
	end)
end

function HairTemplate:RegisterAllEvents()
    local events = {
    	{game.BagEvent.BagItemChange, function(change_list)
    		self:OnBagItemChange(change_list)
    	end},
    	{game.FashionEvent.SwitchHairId, function(id)
    		self:OnSwitchHairId(id)
    	end},    	
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function HairTemplate:InitSlider()
	self.slider_red = self._layout_objs["slider_red"]	
	self.slider_green = self._layout_objs["slider_green"]	
	self.slider_blue = self._layout_objs["slider_blue"]	

	self.slider_red:AddChangeCallback(function(value)
		self:UpdateHairColor(self.slider_red, 1, value)
	end)

	self.slider_green:AddChangeCallback(function(value)
		self:UpdateHairColor(self.slider_green, 2, value)
	end)

	self.slider_blue:AddChangeCallback(function(value)
		self:UpdateHairColor(self.slider_blue, 3, value)
	end)

	local main_role = game.Scene.instance:GetMainRole()
	local hair = main_role:GetHair()
	local r,g,b = self:CalcColorRgb(hair)
	self.hair_color = { r,g,b }

	self.slider_red:SetValue(r)
	self.slider_green:SetValue(g)
	self.slider_blue:SetValue(b)

end

function HairTemplate:CalcColorRgb(hair)
	local mask = 0xff
	local b = hair&mask
	local g = (hair>>8)&mask
	local r = (hair>>16)&mask
	return r, g, b
end

function HairTemplate:InitHairList()
	local item_control = self:GetRoot():AddControllerCallback("item_control",function(idx)
		local hair_item = self.hair_item_list[idx+1]
		if hair_item then
			hair_item:OnClick()

			self.cur_hair_item = hair_item
			self:UpdateHair()
		end
	end)

	local sex = game.RoleCtrl.instance:GetSex()
	local hair_cfg = {}
	for _,v in pairs(config.hair_style or {}) do
		if v.sex == sex then
			table.insert(hair_cfg, v)
		end
	end
	table.sort(hair_cfg, function(v1, v2)
		return v1.id < v2.id
	end)

	local item_num = #hair_cfg
	item_control:SetPageCount(item_num)

	self.list_hair_items = self._layout_objs["list_hair_items"]
	self.list_hair_items:SetItemNum(item_num)

	self.hair_item_list = {}
	for k,v in ipairs(hair_cfg) do
		local child = self.list_hair_items:GetChildAt(k-1)

		local hair_item = require("game/fashion/hair_item").New(v)
		hair_item:SetVirtual(child)
		hair_item:Open()

		table.insert(self.hair_item_list, hair_item)
	end

	item_control:SetSelectedIndexEx(0)
end

function HairTemplate:Active()
	
end

function HairTemplate:UpdateHair()
	local hair_id = self.cur_hair_item:GetId()

	local role_model = self.parent_view:GetRoleModel()
	role_model:UpdateHair(hair_id)

	self:UpdateCost()
end

function HairTemplate:UpdateHairColor(slider, idx, value)
	self.hair_color[idx] = math.floor(value)

	local role_model = self.parent_view:GetRoleModel()
	role_model:UpdateHairColor(table.unpack(self.hair_color))
end

function HairTemplate:CalcHairId()
	local id = self.cur_hair_item:GetId()

	local hair_id = id<<24
	for k,v in ipairs(self.hair_color) do
		hair_id = hair_id + (v<<(16-(k-1)*8))
	end
	return hair_id
end

function HairTemplate:UpdateCost()
	local hair_id = self.cur_hair_item:GetId()

	local hair_cfg = config.hair_style[hair_id]
	local cost_cfg = hair_cfg.cost or {}

	local cost_id = cost_cfg[1][1]
	local cost_num = cost_cfg[1][2]

	self.cur_cost_id = cost_id

    local goods_cfg = config.goods[cost_id]
    self.txt_cost_name:SetText(goods_cfg.name)

	local item_num = game.BagCtrl.instance:GetNumById(cost_id)
	local is_enough = (item_num>=cost_num)
	
	self.txt_cost_num:SetText(string.format("(%s/%s)", item_num, cost_num))

	local color = (is_enough and game.Color.DarkGreen or game.Color.Red)
	self.txt_cost_num:SetColor(table.unpack(color))

end

function HairTemplate:OnBagItemChange(change_list)
	if not change_list[self.cur_cost_id] then return end

	self:UpdateCost()
end

function HairTemplate:SwitchHair(id)
	--self:UpdateCost()

	for _,v in ipairs(self.hair_item_list or {}) do
		v:UpdateState()
	end
end

return HairTemplate
