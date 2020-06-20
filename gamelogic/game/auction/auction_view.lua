local AuctionView = Class(game.BaseView)

function AuctionView:_init(ctrl)
	self._package_name = "ui_auction"
    self._com_name = "auction_new_view"

    self._show_money = true
    
    self.ctrl = ctrl
    self.auction_data = self.ctrl:GetData()
end

function AuctionView:OpenViewCallBack()

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[4200])

	self._layout_objs["n4"]:SetHorizontalBarTop(true)

	self.template1 = self:GetTemplateByObj("game/auction/auction_page_template", self._layout_objs["n4"]:GetChildAt(0), 1)
    self.template2 = self:GetTemplateByObj("game/auction/auction_page_template", self._layout_objs["n4"]:GetChildAt(1), 2)
    self.template3 = self:GetTemplateByObj("game/auction/auction_page_template", self._layout_objs["n4"]:GetChildAt(2), 3)

    self.tab_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
		self:SetBottomInfo(idx+1)
		self:OnClick(2)
		self:OnClickCheckBox(false)
	end)

	self._layout_objs["my_auction_btn"]:AddClickCallBack(function()
    	self:OnClick(1)
    end)

	self._layout_objs["all_auction_btn"]:AddClickCallBack(function()
    	self:OnClick(2)
    end)

    self._layout_objs["auction_his_btn"]:AddClickCallBack(function()
    	self.ctrl:CsAuctionLogs(self.tab_index)
    end)

    self._layout_objs["n5"]:AddChangeCallback(function(event_type)
        local is_selected = (event_type == game.ButtonChangeType.Selected)
        self:OnClickCheckBox(is_selected)
    end)

    self:SetBottomInfo(1)
    self:OnClick(2)
    self:OnClickCheckBox(false)
end

function AuctionView:SetBottomInfo(tab_index)
	self.tab_index = tab_index
	self.cur_page_template = self["template"..tab_index]

	local item_list = {}
	if tab_index == 1 then
		item_list = self.auction_data:GetGuildItemList()
	elseif tab_index == 2 then
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

	for i = 1, 8 do

		local item_type = self.type_list[i]
		if item_type then

			self._layout_objs["sub_btn"..i]:SetText(config.words[4225+item_type])

			local img1 = "type_u"..tostring(item_type)
			local img2 = "type_d"..tostring(item_type)

			self._layout_objs["sub_btn"..i]:GetChild("n1"):SetSprite("ui_auction", img1)
			self._layout_objs["sub_btn"..i]:GetChild("n2"):SetSprite("ui_auction", img2)
			self._layout_objs["sub_btn"..i]:SetVisible(true)
			self._layout_objs["sub_btn"..i]:AddClickCallBack(function()
				self:OnClick(3, i, item_type)
		    end)
		else
			self._layout_objs["sub_btn"..i]:SetVisible(false)
		end
	end
end

function AuctionView:OnClick(main_index, sub_index, item_type)
	self.main_index = main_index
	self.sub_index = sub_index
	self.item_type = item_type

	if main_index ==1 then
		self._layout_objs["my_auction_btn"]:SetSelected(true)
		self._layout_objs["all_auction_btn"]:SetSelected(false)

		for i = 1, 8 do
			self._layout_objs["sub_btn"..i]:SetSelected(false)
		end
	elseif main_index == 2 then

		self._layout_objs["my_auction_btn"]:SetSelected(false)
		self._layout_objs["all_auction_btn"]:SetSelected(true)

		for i = 1, 8 do
			self._layout_objs["sub_btn"..i]:SetSelected(false)
		end
	elseif main_index == 3 then
		self._layout_objs["my_auction_btn"]:SetSelected(false)
		self._layout_objs["all_auction_btn"]:SetSelected(false)

		for i = 1, 8 do
			self._layout_objs["sub_btn"..i]:SetSelected(i==sub_index)
		end
	end

	self.cur_page_template:GetCurTabData(main_index, item_type)
end

function AuctionView:OnClickCheckBox(val)
	self._layout_objs["n5"]:SetSelected(val)
	self.is_cheap = val
	self.cur_page_template:GetCurTabData(self.main_index, self.item_type)
end

return AuctionView