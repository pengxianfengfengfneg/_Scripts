local AuctionTabTemplate = Class(game.UITemplate)

function AuctionTabTemplate:_init(parent_view)
	self.parent_view = parent_view
end

function AuctionTabTemplate:OpenViewCallBack()

end

function AuctionTabTemplate:CloseViewCallBack()

end

function AuctionTabTemplate:RefreshItem(idx)

	local type_list = self.parent_view:GetTypeList()
	local item_type = type_list[idx]
	self.item_type = item_type

	self._layout_objs["title"]:SetText(config.words[4214+idx])
end

function AuctionTabTemplate:GetItemType()
	return self.item_type
end

return AuctionTabTemplate