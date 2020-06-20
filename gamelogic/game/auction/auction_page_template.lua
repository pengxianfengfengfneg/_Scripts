local AuctionPageTemplate = Class(game.UITemplate)

function AuctionPageTemplate:_init(parent, param)
	self.parent = parent
	self.idx = param
	self.auction_data = game.AuctionCtrl.instance:GetData()
end

function AuctionPageTemplate:OpenViewCallBack()

	self:BindEvent(game.AuctionEvent.UpdateList, function(data)
		self:UpdateList()
	end)

	self:InitList()

	local item_list = {}

	if self.idx == 1 then
		item_list = self.auction_data:GetGuildItemList()
	elseif self.idx == 2 then
		item_list = self.auction_data:GetWorldItemList()
	end

	self.all_item_list = item_list

	self.type_item_list = {}
	self.type_list = {}
	for key, var in pairs(item_list) do

		local cid = var.cid
		local cfg = config.auction_items[cid]
		local item_type = cfg.type

		if not self.type_item_list[item_type] then
			self.type_item_list[item_type] = {}
		end
		table.insert(self.type_item_list[item_type], var)
	end

	for item_type, var in pairs(self.type_item_list) do
		table.insert(self.type_list, item_type)
	end
end

function AuctionPageTemplate:GetTypeList()
	return self.type_list
end

--btn_type 1:我的竞拍  2: 全部  3：子列表
--sub_type 子列表index
function AuctionPageTemplate:GetCurTabData(btn_type, sub_type)

	self.cur_item_list = {}

	if btn_type == 1 then
		for key, var in pairs(self.all_item_list) do

			if var.bid > 0 then
				table.insert(self.cur_item_list, var)
			end
		end
	elseif btn_type == 2 then

		for key, var in pairs(self.all_item_list) do

			if self.parent.is_cheap then
				local cid = var.cid
				local value = var.value
				if value == 1 then
					table.insert(self.cur_item_list, var)
				end
			else
				self.cur_item_list = self.all_item_list
			end
		end

	elseif btn_type == 3 then

		for key, var in pairs(self.all_item_list) do

			if self.parent.is_cheap then
				local cid = var.cid
				local value = config.auction_items[cid].value
				local item_type = var.type
				if value == 1 and item_type == sub_type then
					table.insert(self.cur_item_list, var)
				end
			else
				local cid = var.cid
				local item_type = config.auction_items[cid].type
				if item_type == sub_type then
					table.insert(self.cur_item_list, var)
				end
			end
		end
	end

	self:UpdateList()
end

function AuctionPageTemplate:InitList()

	self.list = self._layout_objs["list1"]
	self.ui_list = game.UIList.New(self.list)
	self.ui_list:SetVirtual(true)

	self.ui_list:SetCreateItemFunc(function(obj)
		local item = require("game/auction/auction_item_template").New(self.tab_index)
		item:SetParent(self)
        item:SetVirtual(obj)
        item:Open()
        return item
	end)

	self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_auction:auction_item_template"
    end)

    self.ui_list:SetItemNum(0)
end

function AuctionPageTemplate:UpdateList()
	if self.cur_item_list then
		local num = #self.cur_item_list
		self.ui_list:SetItemNum(num)
	else
		self.ui_list:SetItemNum(0)
	end
end

function AuctionPageTemplate:GetCurItemList()
	return self.cur_item_list
end

return AuctionPageTemplate