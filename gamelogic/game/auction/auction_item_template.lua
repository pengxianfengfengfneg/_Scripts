local AuctionItemTemplate = Class(game.UITemplate)

function AuctionItemTemplate:_init(tab_index)
	self.tab_index = tab_index
end

function AuctionItemTemplate:OpenViewCallBack()

	if not self.icon then
		self.icon = require("game/bag/item/goods_item").New()
    	self.icon:SetVirtual(self._layout_objs["n0"])
    	self.icon:Open()
	end

	--竞价
	self._layout_objs["n8"]:AddClickCallBack(function()
		game.AuctionCtrl.instance:OpenTipsView(1, self.one_item)
    end)

	--一口价
    self._layout_objs["n9"]:AddClickCallBack(function()
    	game.AuctionCtrl.instance:OpenTipsView(2, self.one_item)
    end)
end

function AuctionItemTemplate:CloseViewCallBack()

	if self.icon then
		self.icon:DeleteMe()
	end

	self:DelTimer()
end

function AuctionItemTemplate:RefreshItem(idx)

	local auction_data = game.AuctionCtrl.instance:GetData()
	local item_list = {}
	item_list = self.parent:GetCurItemList()

	local one_item = item_list[idx]
	self.one_item = one_item

	local cid = one_item.cid

	local item_cfg = config.auction_items[cid]
	if not self.icon then
		self.icon = require("game/bag/item/goods_item").New()
    	self.icon:SetVirtual(self._layout_objs["n0"])
    	self.icon:Open()
	end
	self.icon:SetItemInfo({id = item_cfg.item[1], num = item_cfg.item[2]})

	if one_item.value == 1 then
		self._layout_objs["value_img"]:SetVisible(true)
	else
		self._layout_objs["value_img"]:SetVisible(false)
	end

	local item_name = config.goods[item_cfg.item[1]].name
	self._layout_objs["n1"]:SetText(item_name)

	local expire_time = one_item.expire
	self:SetExpireTime(expire_time)

	local cur_price = one_item.price

	self._layout_objs["jj_txt"]:SetText(cur_price)

	self._layout_objs["ykj_txt"]:SetText(item_cfg.now_price)

	if one_item.bid > 0 then
		self._layout_objs["n8"]:SetText(config.words[4224])
	else
		self._layout_objs["n8"]:SetText(config.words[4223])
	end

	local top_role_id = one_item.top
	local my_role_id = game.Scene.instance:GetMainRoleID()

	if top_role_id == 0 then
		self._layout_objs["n2"]:SetText("")
	else
		if one_item.bid == 0 then
			self._layout_objs["n2"]:SetText(config.words[4219])
		else
			if top_role_id == my_role_id then
				self._layout_objs["n2"]:SetText(config.words[4211])
			else
				self._layout_objs["n2"]:SetText(config.words[4210])
			end
		end
	end
end

function AuctionItemTemplate:SetExpireTime(expire_time)

	local cur_time = global.Time:GetServerTime()
	local offset = expire_time - cur_time

	self:DelTimer()
	self.timer = global.TimerMgr:CreateTimer(1, function()

		offset = offset - 1

		if offset < 0 then
			self:DelTimer()
			self._layout_objs["n3"]:SetText(config.words[4222])

			local auction_data = game.AuctionCtrl.instance:GetData()
			auction_data:RemoveOutTimeItem(self.one_item.aid, self.one_item.uid)
			return
		end
		local str = game.Utils.SecToTime2(offset)
		self._layout_objs["n3"]:SetText(string.format(config.words[4201], str))
	end)
end

function AuctionItemTemplate:DelTimer()
	if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function AuctionItemTemplate:SetParent(parent)
	self.parent = parent
end

return AuctionItemTemplate