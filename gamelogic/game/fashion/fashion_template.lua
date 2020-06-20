local FashionTemplate = Class(game.UITemplate)

function FashionTemplate:_init(view)
    self.ctrl = game.FashionCtrl.instance
    
    self.parent_view = view
end

function FashionTemplate:OpenViewCallBack()
	self:Init()
	self:InitColorList()
	self:InitFashionList()

	self:RegisterAllEvents()
end

function FashionTemplate:CloseViewCallBack()
   	for _,v in ipairs(self.fashion_item_list or {}) do
   		v:DeleteMe()
   	end
   	self.fashion_item_list = {}

   	if self.goods_item then
   		self.goods_item:DeleteMe()
   		self.goods_item = nil
   	end

    self:ClearColorList()
end

function FashionTemplate:RegisterAllEvents()
    local events = {
    	{game.BagEvent.BagItemChange, function(data)
    		self:OnBagItemChange(data)
    	end},
    	{game.FashionEvent.ActiveFashion, function(id, color)
    		self:OnActiveFashion(id, color)
    	end},
    	{game.FashionEvent.WearFashion, function(id)
    		self:OnWearFashion(id)
    	end},
    	{game.FashionEvent.DyeingFashion, function(id, color)
            self:OnDyeingFashion(id, color)
        end},
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function FashionTemplate:Init()
	self.txt_fight = self._layout_objs["role_fight_com/txt_fight"]	
	self.btn_look = self._layout_objs["role_fight_com/btn_look"]
	self.btn_look:AddClickCallBack(function()

	end)

	self.txt_total_fight = self._layout_objs["txt_total_fight"]
	self.txt_fashion_num = self._layout_objs["txt_fashion_num"]


	self.group_item = self._layout_objs["group_item"]
	self.img_item = self._layout_objs["img_item"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_num = self._layout_objs["txt_num"]
	self.txt_get_way = self._layout_objs["txt_get_way"]
	self.btn_active = self._layout_objs["btn_active"]
	self.btn_active:AddClickCallBack(function()
		if not self.cur_fashion_item then return end
		self.ctrl:SendFashionActivate(self.cur_fashion_item:GetItemId())
	end)


	self.group_active = self._layout_objs["group_active"]
	self.btn_wear = self._layout_objs["btn_wear"]
	self.btn_color = self._layout_objs["btn_color"]
	
	self.btn_wear:AddClickCallBack(function()
		if not self.cur_fashion_item then return end
		self.ctrl:SendFashionWear(self.cur_fashion_item:GetId(), self.cur_color_item:GetColor())
	end)
	
	self.btn_color:AddClickCallBack(function()
		if not self.cur_fashion_item then return end
		self.ctrl:OpenColorView(self.cur_fashion_item:GetId())
	end)
end

function FashionTemplate:InitFashionList()
	local item_control = self:GetRoot():AddControllerCallback("item_control",function(idx)
		local fashion_item = self.fashion_item_list[idx+1]
		if fashion_item then
			fashion_item:OnClick()

			self.cur_fashion_item = fashion_item
			self:UpdateFashion()
		end
	end)

	local fashion_cfg = {}
	for _,v in pairs(config.fashion or {}) do
		table.insert(fashion_cfg, v)
	end

	table.sort(fashion_cfg, function(v1, v2)
		return v1.id < v2.id
	end)

	local item_num = #fashion_cfg
	item_control:SetPageCount(item_num)
	
	self.list_fashion_items = self._layout_objs["list_fashion_items"]
	self.list_fashion_items:SetItemNum(item_num)

	self.fashion_item_list = {}
	for k,v in ipairs(fashion_cfg) do
		local child = self.list_fashion_items:GetChildAt(k-1)

		local fashion_item = require("game/fashion/fashion_item").New(v)
		fashion_item:SetVirtual(child)
		fashion_item:Open()

		table.insert(self.fashion_item_list, fashion_item)
	end
	item_control:SetSelectedIndexEx(0)

	self.list_fashion_items:ScrollToView(0)
end

function FashionTemplate:InitColorList()
	self.color_control = self:GetRoot():AddControllerCallback("color_control",function(idx)
		
		local color_item = self.color_item_list[idx+1]
		if color_item then
			color_item:OnClick()

			self.cur_color_item = color_item
			self:UpdateFashionColor()
		end
	end)

	self.list_colors = self._layout_objs["list_colors"]
end

function FashionTemplate:UpdateColorList()
	local career = game.RoleCtrl.instance:GetCareer()
	local fashion_id = self.cur_fashion_item:GetId()

	local fashion_cfg = config.fashion[fashion_id]
	local color_cfg = config.fashion_color[fashion_id][career]
	local item_num = #fashion_cfg.colors

	self.color_control:SetPageCount(item_num)
	self.list_colors:SetItemNum(item_num)

	local used_idx = 1
	self:ClearColorList()
	for k,v in ipairs(fashion_cfg.colors) do
		local cfg = color_cfg[k]
		local child = self.list_colors:GetChildAt(k-1)

		local color_item = require("game/fashion/fashion_color_item").New()
		color_item:SetVirtual(child)
		color_item:Open()
		color_item:UpdateData(cfg)

		if color_item:IsUsed() then
			used_idx = k
		end

		table.insert(self.color_item_list, color_item)
	end

	self.cur_color_item = self.color_item_list[used_idx] 
	self.color_control:SetSelectedIndex(used_idx-1)

	self.list_colors:ScrollToView(used_idx-1)
end

function FashionTemplate:ClearColorList()
	for _,v in ipairs(self.color_item_list or {}) do
   		v:DeleteMe()
   	end
   	self.color_item_list = {}
end

function FashionTemplate:UpdateInfo()
	local fashion_ctrl = game.FashionCtrl.instance
	local total_fight = fashion_ctrl:GetTotalFight()
	self.txt_total_fight:SetText(total_fight)

	local fashion_num = fashion_ctrl:GetFashionNum()
	self.txt_fashion_num:SetText(fashion_num)


end

function FashionTemplate:Active()
	
end

function FashionTemplate:UpdateFashion()
	if not self.cur_fashion_item then return end

	local fashion_name = self.cur_fashion_item:GetName()
	self.txt_name:SetText(fashion_name)

	local get_way = self.cur_fashion_item:GetWay()
	self.txt_get_way:SetText(string.format(config.words[2006],get_way))

	local func_id = self.cur_fashion_item:GetFuncId()

	local attr = self.cur_fashion_item:GetAttr()
	local power = game.Utils.CalculateCombatPower(attr)
	self.txt_fight:SetText(power)

	local item_id = self.cur_fashion_item:GetItemId()

	if not self.goods_item then
		self.goods_item = game_help.GetGoodsItem(self._layout_objs["item"], true)
	end
	local info = {
		id = item_id,
		num = 0,		
	}
	self.goods_item:SetItemInfo(info)

	self:UpdateColorList()

	self:UpdateActiveState()
	self:UpdateFashionColor()
end

function FashionTemplate:UpdateActiveState()
	local fashion_id = self.cur_fashion_item:GetId()

	local is_actived = self.ctrl:IsFashionActived(fashion_id)
	self.group_active:SetVisible(is_actived)
	self.group_item:SetVisible(not is_actived)

	if not is_actived then
		local item_id = self.cur_fashion_item:GetItemId()

		local item_num = game.BagCtrl.instance:GetNumById(item_id)
		local is_enough = (item_num>=1)
		
		self.btn_active:SetVisible(is_enough)
		self.txt_get_way:SetVisible(not is_enough)

		self.txt_num:SetText(string.format("(%s/%s)", item_num, 1))

		local color = (is_enough and game.Color.DarkGreen or game.Color.Red)
		self.txt_num:SetColor(table.unpack(color))
	end
end

function FashionTemplate:UpdateFashionColor()
	if not self.cur_color_item or not self.cur_fashion_item then
		return
	end
	
	local fashion_id = self:GetFashionId()
	local fashion_color = self:GetFashionColor()
	local role_model = self.parent_view:GetRoleModel()
	role_model:UpdateFashion(fashion_id, nil, fashion_color)
end

function FashionTemplate:GetFashionId()
	return self.cur_fashion_item:GetId()
end

function FashionTemplate:GetFashionColor()
	return self.cur_color_item:GetColor()
end

function FashionTemplate:OnBagItemChange(data)
	local item_id = self.cur_fashion_item:GetItemId()
	if not data[item_id] then return end

	self:UpdateActiveState()
end

function FashionTemplate:OnActiveFashion(id, color)
	self:UpdateActiveState()
	self:UpdateColorItemState()
end

function FashionTemplate:OnWearFashion(id)
	for _,v in ipairs(self.fashion_item_list or {}) do
		v:DoUpdate()
	end

	for _,v in ipairs(self.color_item_list or {}) do
		v:DoUpdate()
	end
end

function FashionTemplate:UpdateColorItemState()
	for _,v in ipairs(self.color_item_list or {}) do
		v:UpdateState()
	end
end

function FashionTemplate:OnDyeingFashion(id, color)
	for _,v in ipairs(self.color_item_list or {}) do
		v:UpdateState()
	end
end

return FashionTemplate
