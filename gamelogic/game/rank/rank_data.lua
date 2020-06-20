local RankData = Class(game.BaseData)

function RankData:_init()
	self.rank_list = {}
end

function RankData:SetRankData( data )

	local rank_type = data.info.type
	local page = data.info.page

	--请求第一页的时候会删除整个列表
	if not self.rank_list[rank_type] or page == 1 then
		self.rank_list[rank_type] = {}
	end

	if not self.rank_list[rank_type].list then
		self.rank_list[rank_type].list = {}
	end

	--增加新页面数据才保存数据, 旧页面的不保存了
	if not self.rank_list[rank_type].cur_page or page > self.rank_list[rank_type].cur_page then

		for key, var in ipairs(data.info.items) do
			table.insert(self.rank_list[rank_type].list, var)
		end

		self.rank_list[rank_type].cur_page = page

		self.rank_list[rank_type].relative = data.info.relative
	end
end

function RankData:GetRankDataByType(rank_type)

	if self.rank_list[rank_type] then
		return self.rank_list[rank_type].list
	else
		return {}
	end
end

function RankData:GetCurPage(rank_type)

	if self.rank_list[rank_type] then
		return self.rank_list[rank_type].cur_page
	else
		return 0
	end
end

function RankData:GetRankItem(rank_type, rank)

	local rank_item

	if self.rank_list[rank_type] and self.rank_list[rank_type].list then

		for key, var in pairs(self.rank_list[rank_type].list) do

			if var.item.rank == rank then
				rank_item = var.item
			end
		end
	end

	return rank_item
end

function RankData:GetMyRank(rank_type)

	if self.rank_list[rank_type] then
		return self.rank_list[rank_type].relative
	end
end

function RankData:GetRankViewTabs()

	if self.rank_tabs then
		return self.rank_tabs
	end

	if not self.rank_tabs then

		self.rank_tabs = {}

		local cfg = config.rank

		for key,var in pairs(cfg) do
			if var.show == 1 then
				table.insert(self.rank_tabs, var)
			end
		end

		local sort_func = function(a, b)
			return a.sort < b.sort
		end
		table.sort( self.rank_tabs, sort_func)

		return self.rank_tabs
	end
end

function RankData:GetSubTypeList(main_type)

	local rank_id_list = {}

	for k, v in pairs(config.rank) do

		if v.main_type == main_type then

			table.insert(rank_id_list, v.id)
		end
	end

	return rank_id_list
end

return RankData