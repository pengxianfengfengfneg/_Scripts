local AuctionTipsView = Class(game.BaseView)

function AuctionTipsView:_init(ctrl)
	self._package_name = "ui_auction"
    self._com_name = "auction_tips_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Second
end

function AuctionTipsView:OpenViewCallBack(one_item)

	local cid = one_item.cid
	local item_cfg = config.auction_items[cid]
	local cur_price = one_item.price
	local inc_price = item_cfg.inc_price
	cur_price = cur_price + inc_price
	local item_name = config.goods[item_cfg.item[1]].name

	self._layout_objs["common_bg/txt_title"]:SetText(config.words[1660])
	self._layout_objs["common_bg/txt_content"]:SetText(string.format(config.words[4204], cur_price, item_name))
	self._layout_objs["common_bg/btn1"]:SetText(config.words[100])
	self._layout_objs["common_bg/btn2"]:SetText(config.words[101])

	local my_price = one_item.bid
	local top_role_id = one_item.top
	local my_role_id = game.Scene.instance:GetMainRoleID()

	--竞价
	if self.oper_type == 1 then

		--竞价超越一口价, 直接按照一口价购买
		if cur_price >= item_cfg.now_price then
			self.oper_type = 2
			self._layout_objs["common_bg/txt_content"]:SetText(string.format(config.words[4225], item_cfg.now_price, item_name))

		else
			if my_price == 0 then
				self._layout_objs["common_bg/txt_content"]:SetText(string.format(config.words[4204], cur_price, item_name))
			else
				if top_role_id == my_role_id then
					self._layout_objs["common_bg/txt_content"]:SetText(string.format(config.words[4212], cur_price - my_price, item_name))
				else
					self._layout_objs["common_bg/txt_content"]:SetText(string.format(config.words[4213], cur_price - my_price, item_name))
				end
			end
		end
		self:SetTimeTip(one_item.expire)
	--一口价
	else
		self._layout_objs["common_bg/txt_content"]:SetText(string.format(config.words[4214], item_cfg.now_price, item_name))
		self._layout_objs["time"]:SetText("")
	end

	--确定
	self._layout_objs["common_bg/btn1"]:AddClickCallBack(function()
		game.AuctionCtrl.instance:CsAuctionBid(one_item.aid, one_item.uid, self.oper_type)
		self:Close()
	end)

	--取消
	self._layout_objs["common_bg/btn2"]:AddClickCallBack(function()
		self:Close()
	end)

	self._layout_objs["btn_close"]:AddClickCallBack(function()
		self:Close()
	end)
end

function AuctionTipsView:CloseViewCallBack()

	self:DelTimer()
end

function AuctionTipsView:SetTimeTip(expire_time)

	local cur_time = global.Time:GetServerTime()
	local offset = expire_time - cur_time

	self.timer = global.TimerMgr:CreateTimer(1, function()

		offset = offset - 1

		if offset < 0 then
			self:DelTimer()
		end
		local str = game.Utils.SecToTime2(offset)
		self._layout_objs["time"]:SetText(string.format(config.words[4201], str))
	end)
end

function AuctionTipsView:DelTimer()
	if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function AuctionTipsView:SetOperType(oper_type)
	self.oper_type = oper_type
end

return AuctionTipsView