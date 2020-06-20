local FoundryComposeTemplate = Class(game.UITemplate)

function FoundryComposeTemplate:_init()
	self._package_name = "ui_foundry"
    self._com_name = "foundry_compose_template"
end

function FoundryComposeTemplate:OpenViewCallBack()

    self._layout_objs["n7"]:AddClickCallBack(function()
    	self:ComposeOnce()
    end)

    self._layout_objs["n8"]:AddClickCallBack(function()
    	self:ComposeAll()
    end)

    self:InitTopGoodsItem()

    self:InitList()

    self:BindEvent(game.FoundryEvent.ComposeSucc, function(data)
    	self:PLayEffect()
        self:RefreshView(data)
    end)

    self._layout_objs["n12"]:SetVisible(false)
end

function FoundryComposeTemplate:CloseViewCallBack()
	for key, var in pairs(self.left_items or {}) do
		var:DeleteMe()
	end
	self.left_items = nil

	for key, var in pairs(self.right_items or {}) do
		var:DeleteMe()
	end
	self.right_items = nil

	if self.ui_list then
		self.ui_list:DeleteMe()
		self.ui_list = nil
	end
end

function FoundryComposeTemplate:InitTopGoodsItem()

	self._layout_objs["left_item1/sub_btn"]:AddClickCallBack(function()
		self:SubSelect(1)
	end)

	self._layout_objs["left_item2/sub_btn"]:AddClickCallBack(function()
		self:SubSelect(2)
	end)

	self.left_items = {}
	self.right_items = {}

	for i = 1, 2 do
		self.left_items[i] = require("game/bag/item/goods_item").New()
	    self.left_items[i]:SetVirtual(self._layout_objs["left_item" .. i])
	    self.left_items[i]:Open()
	    self.left_items[i]:SetTouchEnable(true)
	    self.left_items[i]:ResetItem()
	end

	for i = 1, 2 do
		self.right_items[i] = require("game/bag/item/goods_item").New()
	    self.right_items[i]:SetVirtual(self._layout_objs["right_item" .. i])
	    self.right_items[i]:Open()
	    self.right_items[i]:SetTouchEnable(true)
	    self.right_items[i]:ResetItem()
	end
end

function FoundryComposeTemplate:InitList()

    self.item_list = game.FoundryCtrl.instance:GetComposeBagItemList()

    self.list = self._layout_objs["n19"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)
        local item = require("game/bag/item/goods_item").New()
		item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        item:SetShowTipsEnable(true)
        return item
    end)

    self:GetCanComposeItemList()
    
    self.ui_list:SetRefreshItemFunc(function (item, idx)
        local item_info = self.item_list[idx]

		item:SetItemInfo({ id = item_info.goods.id, num = item_info.goods.num, bind = item_info.goods.bind})
		item:AddClickEvent(function()

			--第二次选中
			if self.item_info then
				item:SetSelect(true)
				self:OnClick(item_info, idx)
			--第一次选中
			else
	            self.ui_list:Foreach(function(v)
	            	local v_item_info = v:GetItemInfo()
	            	if v_item_info.id ~= item_info.goods.id then
	                	v:SetSelect(false)
	                	v:SetTouchEnable(false)
	                	v:SetGrayMask(true)
	                else
	                	v:SetTouchEnable(true)
	                	v:SetGrayMask(false)
	                end
	            end)

	            item:SetSelect(true)
	            item:SetTouchEnable(false)

	            self:OnClick(item_info, idx)
	        end
        end)
        item:SetLongClickFunc(function()
        	item:ShowTips()
        end)

        if self.item_info then
         	if self.item_info.id ~= item_info.goods.id then
	        	item:SetSelect(false)
	        	item:SetTouchEnable(false)
	     	else
	        	item:SetTouchEnable(true)
	        end
	    else
	    	item:SetTouchEnable(true)
	    end

	    if self.can_compose_item_id_list[item_info.goods.id] then
	    	item:SetGrayMask(false)
	    else
	    	item:SetGrayMask(true)
	    end
    end)

    self.ui_list:SetItemNum(#self.item_list)

    self.ui_list:Foreach(function(v)
        v:SetSelect(false)
        v:SetTouchEnable(true)
    end)
end

function FoundryComposeTemplate:UpdateList()
	self.item_list = game.FoundryCtrl.instance:GetComposeBagItemList()
	self:GetCanComposeItemList()
	self.ui_list:SetItemNum(#self.item_list)
end

function FoundryComposeTemplate:OnClick(item_info, idx)

	--已经选择了一个
	if self.item_info then
		self.item_info2 = item_info
		self.select_idx2 = idx
	else
		self.item_info = item_info
		self.select_idx = idx
	end

	self:ShowTopItems()
end

function FoundryComposeTemplate:ShowTopItems()

	self.left_items[1]:ResetItem()
	self.left_items[2]:ResetItem()
	self.right_items[1]:ResetItem()
	self.right_items[2]:ResetItem()
	self._layout_objs["n12"]:SetVisible(false)

	if self.item_info then
		self:ShowSingleSelect(self.item_info)
	end

	if self.item_info2 then
		self:ShowSecondSelect(self.item_info2)
	end
end

--只选了一个
function FoundryComposeTemplate:ShowSingleSelect(item_info)

	--左侧物品
	local sour_item_id = item_info.goods.id
	local sour_item_num = item_info.goods.num
	local sour_item_bind = item_info.goods.bind
	local target_item_id = config.compose[sour_item_id].target
	local target_cost_num = config.compose[sour_item_id].cost_num
	local can_comp_num = math.floor(sour_item_num/target_cost_num)

	self.left_items[1]:SetItemInfo({ id = sour_item_id, num = sour_item_num, bind = sour_item_bind})
	self.left_items[1]:SetShowTipsEnable(true)
	self._layout_objs["left_item1/item_name"]:SetText(config.goods[sour_item_id].name)
	-- local color = cc.GoodsColor_light[config.goods[sour_item_id].color]
	-- self._layout_objs["left_item1/item_name"]:SetColor(color.x, color.y, color.z, color.w)

	self._layout_objs["left_item1/sub_btn"]:SetVisible(true)
	self._layout_objs["left_item1"]:SetPosition(94, 250)
	self._layout_objs["left_item2"]:SetVisible(false)

	self._layout_objs["n12"]:SetText(string.format(config.words[1223], target_cost_num))
	self._layout_objs["n12"]:SetVisible(true)

	--右侧物品
	self.right_items[1]:SetItemInfo({ id = target_item_id, num = can_comp_num, bind = sour_item_bind})
	self.right_items[1]:SetShowTipsEnable(true)
	self._layout_objs["right_item1/item_name"]:SetText(config.goods[target_item_id].name)
	-- local color = cc.GoodsColor_light[config.goods[target_item_id].color]
	-- self._layout_objs["right_item1/item_name"]:SetColor(color.x, color.y, color.z, color.w)
	self._layout_objs["right_item1"]:SetPosition(467, 250)
	self._layout_objs["right_item2"]:SetVisible(false)
end

--选了两个
function FoundryComposeTemplate:ShowSecondSelect(item_info)

	--左侧物品
	local sour_item2_id = item_info.goods.id
	local sour_item2_num = item_info.goods.num
	local sour_item2_bind = item_info.goods.bind
	local target_item_id = config.compose[sour_item2_id].target
	local target_cost_num = config.compose[sour_item2_id].cost_num
	local can_comp_num = math.floor(sour_item2_num/target_cost_num)

	self.left_items[2]:SetItemInfo({ id = sour_item2_id, num = sour_item2_num, bind = sour_item2_bind})
	self.left_items[2]:SetShowTipsEnable(true)
	self._layout_objs["left_item2/item_name"]:SetText(config.goods[sour_item2_id].name)
	-- local color = cc.GoodsColor_light[config.goods[sour_item2_id].color]
	-- self._layout_objs["left_item2/item_name"]:SetColor(color.x, color.y, color.z, color.w)
	self._layout_objs["left_item2/sub_btn"]:SetVisible(true)
	self._layout_objs["left_item1"]:SetPosition(25, 250)
	self._layout_objs["left_item2"]:SetPosition(175, 250)
	self._layout_objs["left_item2"]:SetVisible(true)

	self._layout_objs["n12"]:SetText(string.format(config.words[1223], target_cost_num))
	self._layout_objs["n12"]:SetVisible(true)

	--右侧物品 根据数量有两个的可能
	local sour_bind_num = 0
	local sour_unbind_num = 0
	local target_bind_num = 0
	local target_unbind_num = 0

	if item_info.goods.bind == 1 then
		sour_bind_num = item_info.goods.num
		sour_unbind_num = self.item_info.goods.num
	else
		sour_bind_num = self.item_info.goods.num
		sour_unbind_num = item_info.goods.num
	end

	local unbind_off = sour_unbind_num % target_cost_num
	target_unbind_num = math.floor(sour_unbind_num/target_cost_num)
	target_bind_num = math.floor((unbind_off+sour_bind_num)/target_cost_num)

	self.right_items[1]:SetItemInfo({ id = target_item_id, num = target_bind_num, bind = 1})
	self.right_items[1]:SetShowTipsEnable(true)
	self._layout_objs["right_item1/item_name"]:SetText(config.goods[target_item_id].name)
	-- local color = cc.GoodsColor_light[config.goods[target_item_id].color]
	-- self._layout_objs["right_item1/item_name"]:SetColor(color.x, color.y, color.z, color.w)

	if target_unbind_num > 0 then
		self.right_items[2]:SetItemInfo({ id = target_item_id, num = target_unbind_num, bind = 0})
		self.right_items[2]:SetShowTipsEnable(true)
		self._layout_objs["right_item2/item_name"]:SetText(config.goods[target_item_id].name)
		-- local color = cc.GoodsColor_light[config.goods[target_item_id].color]
		-- self._layout_objs["right_item2/item_name"]:SetColor(color.x, color.y, color.z, color.w)
		self._layout_objs["right_item1"]:SetPosition(380, 250)
		self._layout_objs["right_item2"]:SetPosition(540, 250)
		self._layout_objs["right_item2"]:SetVisible(true)
	else
		self.right_items[2]:ResetItem()
	end
end

function FoundryComposeTemplate:ComposeOnce()

	local sour_item_pos = {}

	if self.item_info then
		local pos1 = self.item_info.goods.pos
		table.insert(sour_item_pos, {pos = pos1})
	end

	if self.item_info2 then
		local pos2 = self.item_info2.goods.pos
		table.insert(sour_item_pos, {pos = pos2})
	end

	game.FoundryCtrl.instance:CsRefineCompose(1, sour_item_pos, 1)
end

function FoundryComposeTemplate:ComposeAll()

	local sour_item_pos = {}

	if self.item_info then
		local pos1 = self.item_info.goods.pos
		table.insert(sour_item_pos, {pos = pos1})
	end

	if self.item_info2 then
		local pos2 = self.item_info2.goods.pos
		table.insert(sour_item_pos, {pos = pos2})
	end

	game.FoundryCtrl.instance:CsRefineCompose(1, sour_item_pos, 2)
end

function FoundryComposeTemplate:SubSelect(index)

	if index == 1 then
		if not self.item_info2 then
			self.item_info = nil
		else
			self.item_info = self.item_info2
			self.item_info2 = nil
		end
	end

	if index == 2 then
		if self.item_info2 then
			self.item_info2 = nil
		end
	end

	self:ShowTopItems()

	if not self.item_info then
		self.ui_list:Foreach(function(v)
	        v:SetSelect(false)
	        v:SetTouchEnable(true)

	        local item_info = v:GetItemInfo()
	        local item_id = item_info.id
	        if self.can_compose_item_id_list[item_id] then
	        	v:SetGrayMask(false)
	        else
	        	v:SetGrayMask(true)
	        end
	    end)
	elseif self.item_info and not self.item_info2 then

		self.ui_list:Foreach(function(v)

	    	local v_item_info = v:GetItemInfo()
	    	if v_item_info.id ~= self.item_info.goods.id then
	        	v:SetSelect(false)
	        	v:SetTouchEnable(false)
	        	v:SetGrayMask(true)
	        else
	        	if v_item_info.bind == self.item_info.goods.bind then
	        		v:SetSelect(true)
	        		v:SetTouchEnable(false)
	        	else
	        		v:SetSelect(false)
	        		v:SetTouchEnable(true)
	        	end
	        	v:SetGrayMask(false)
	        end
	    end)
	elseif self.item_info and self.item_info2 then
		self.ui_list:Foreach(function(v)

	    	local v_item_info = v:GetItemInfo()
	    	if v_item_info.id ~= self.item_info.goods.id then
	    		v:SetGrayMask(true)
	        	v:SetSelect(false)
	        	v:SetTouchEnable(false)
	        else
	        	v:SetGrayMask(false)
	        	v:SetSelect(true)
	        	v:SetTouchEnable(true)
	        end
	    end)
	end
end

function FoundryComposeTemplate:RefreshView(data)

	--合成单个
	if data.type == 1 then
		self:ShowTopItems()

		self:UpdateList()

		self:UpdateUseItemNum()
	end

	--合成全部成功
	if data.type == 2 then
		self:UpdateList()

		self.item_info = nil
		self.item_info2 = nil

		self.left_items[1]:ResetItem()
		self.left_items[2]:ResetItem()
		self.right_items[1]:ResetItem()
		self.right_items[2]:ResetItem()

		self._layout_objs["left_item1"]:SetPosition(93, 250)
		self._layout_objs["left_item2"]:SetVisible(false)
		self._layout_objs["right_item1"]:SetPosition(467, 250)
		self._layout_objs["right_item2"]:SetVisible(false)

		self.ui_list:Foreach(function(v)
			v:SetSelect(false)
		    v:SetTouchEnable(true)
		end)
	end
end

function FoundryComposeTemplate:ResetView()
	self.item_info = nil
	self.item_info2 = nil
	self:InitTopGoodsItem()
    self:InitList()
end

function FoundryComposeTemplate:UpdateUseItemNum()

	self.ui_list:Foreach(function(v)
		v:SetSelect(false)
	    v:SetTouchEnable(false)
	end)

	if self.item_info then
		self.ui_list:Foreach(function(v)
	    	local v_item_info = v:GetItemInfo()
	    	if v_item_info.id == self.item_info.goods.id and v_item_info.bind == self.item_info.goods.bind then
	        	v:SetSelect(true)
	        	v:SetTouchEnable(false)
	        end
	    end)
	end

	if self.item_info2 then
		self.ui_list:Foreach(function(v)
	    	local v_item_info = v:GetItemInfo()
	    	if v_item_info.id == self.item_info2.goods.id and v_item_info.bind == self.item_info2.goods.bind then
	        	v:SetSelect(true)
	        	v:SetTouchEnable(false)
	        end
	    end)
	end
end

function FoundryComposeTemplate:PLayEffect()
    self._layout_objs["effect"]:SetVisible(true)
    self:CreateUIEffect(self._layout_objs["effect"], "effect/ui/ui_compound.ab")
end

function FoundryComposeTemplate:GetCanComposeItemList()

	local item_list = game.FoundryCtrl.instance:GetComposeBagItemList()
	local item_num_list = {}
	self.can_compose_item_id_list = {}

	for k,item_info in pairs(item_list) do

		local item_id = item_info.goods.id
		local item_num = item_info.goods.num
		if not item_num_list[item_id] then
			item_num_list[item_id] = item_num
		else
			item_num_list[item_id] = item_num_list[item_id] + item_num
		end
	end

	for item_id, item_num in pairs(item_num_list) do

		local target_cost_num = config.compose[item_id].cost_num
		if item_num >= target_cost_num then
			self.can_compose_item_id_list[item_id] = true
		end
	end
end

return FoundryComposeTemplate