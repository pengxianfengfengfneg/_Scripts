local AuctionHisTemplate = Class(game.UITemplate)

function AuctionHisTemplate:_init(parent_view)
	self.parent_view = parent_view
end

function AuctionHisTemplate:OpenViewCallBack()

end

function AuctionHisTemplate:CloseViewCallBack()

end

function AuctionHisTemplate:RefreshItem(idx)

	local oper_type = self.parent_view:GetOperType()
	local auction_data = game.AuctionCtrl.instance:GetData()
	local log_list = auction_data:GetLogs(oper_type)
	local one_item = log_list[idx]

	local str = game.Utils.ConvertToStyle1(one_item.time)
	self._layout_objs["time_txt"]:SetText(str)

	local item_id = config.auction_items[one_item.cid].item[1]
	local item_num = config.auction_items[one_item.cid].item[2]
	local item_name = config.goods[item_id].name
	self._layout_objs["item_name"]:SetText(item_name.."x"..tostring(item_num))


	self._layout_objs["cost_txt"]:SetText(one_item.price)

	if one_item.type == 1 then
		self._layout_objs["n4"]:SetText(config.words[4220])
	else
		self._layout_objs["n4"]:SetText(config.words[4221])
	end
end

return AuctionHisTemplate