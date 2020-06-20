local AuctionData = Class(game.BaseData)

function AuctionData:_init()
	self.logs = {}
end

function AuctionData:SetData(data)
	self.guild_item_list = data.guild
	self.world_item_list = data.world
end

function AuctionData:GetGuildItemList()
	return self.guild_item_list or {}
end

function AuctionData:GetWorldItemList()
	return self.world_item_list
end

function AuctionData:SetLogs(data)
	self.logs[data.type] = data.logs
end

function AuctionData:GetLogs(oper_type)
	return self.logs[oper_type]
end

function AuctionData:UpdateData(data)

	local oper_type = data.type
	local aid = data.aid
	local uid = data.uid
	local my_role_id = game.Scene.instance:GetMainRoleID()
	
	--帮会拍卖
	for key, var in pairs(self.guild_item_list or {}) do

		if var.uid == uid and var.aid == aid then
			--竞价
			if oper_type == 1 then

				-- local cid = var.cid
				-- local inc_price = config.auction_items[cid].inc_price

				-- var.price = var.price + inc_price
				var.top = my_role_id
				var.bid = var.price
			--一口价
			elseif oper_type == 2 then

				local t = {}
				t.time = os.time()
				t.cid = var.cid
				t.price = config.auction_items[t.cid].now_price
				t.type = 2

				if not self.logs[1] then
					self.logs[1] = {}
				end
				-- table.insert(self.logs[1], t)

				table.remove(self.guild_item_list, key)
			end

			break
		end
	end

	--世界拍卖
	for key, var in pairs(self.world_item_list or {}) do

		if var.uid == uid and var.aid == aid then
			--竞价
			if oper_type == 1 then

				-- local cid = var.cid
				-- local inc_price = config.auction_items[cid].inc_price

				-- var.price = var.price + inc_price
				var.top = my_role_id
				var.bid = var.price
			--一口价
			elseif oper_type == 2 then

				local t = {}
				t.time = os.time()
				t.cid = var.cid
				t.price = config.auction_items[t.cid].now_price
				t.type = 2

				if not self.logs[2] then
					self.logs[2] = {}
				end
				-- table.insert(self.logs[2], t)

				table.remove(self.world_item_list, key)
			end

			break
		end
	end
end

function AuctionData:ModifyItemInfo(data)
	local aid = data.aid
	local uid = data.uid
	local oper_type = data.state

	for key, var in pairs(self.guild_item_list or {}) do

		if var.uid == uid and var.aid == aid then

			--竞价
			if oper_type == 1 then
				var.price = data.price
				var.top = data.top
			elseif oper_type == 2 then
				table.remove(self.guild_item_list, key)
			end

			break
		end
	end

	for key, var in pairs(self.world_item_list or {}) do

		if var.uid == uid and var.aid == aid then

			--竞价
			if oper_type == 1 then
				var.price = data.price
				var.top = data.top
			elseif oper_type == 2 then
				table.remove(self.world_item_list, key)
			end

			break
		end		
	end
end

function AuctionData:RemoveOutTimeItem(aid, uid)

	for key, var in pairs(self.guild_item_list or {}) do

		if var.aid == aid and var.uid == uid then
			table.remove(self.guild_item_list, key)
			break
		end
	end

	for key, var in pairs(self.world_item_list or {}) do

		if var.aid == aid and var.uid == uid then
			table.remove(self.world_item_list, key)
			break
		end
	end

	self:FireEvent(game.AuctionEvent.UpdateList, nil)
end

function AuctionData:CheckRedPoint()

	local flag = false

	if self.guild_item_list and #self.guild_item_list > 0 then
		flag = true
	end

	if self.world_item_list and #self.world_item_list > 0 then
		flag = true
	end

	return flag
end

return AuctionData