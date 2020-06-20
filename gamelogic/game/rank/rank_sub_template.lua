local RankSubTemplate = Class(game.UITemplate)

function RankSubTemplate:_init(parent)
	self.parent = parent
end

function RankSubTemplate:OpenViewCallBack()
	self:BindEvent(game.RankEvent.UpdateMainViewRankInfo, function(data)
        if data.type == self.rank_id then
        	if data.target_rank == 0 then
        		self._layout_objs["my_rank_txt"]:SetText(config.words[1411])
        	else
        		self._layout_objs["my_rank_txt"]:SetText(string.format(config.words[1423], data.target_rank))
        	end
        end
    end)
end

function RankSubTemplate:RefreshItem(idx)
	local rank_id_list = self.parent:GetListData()
	local rank_id = rank_id_list[idx]
	self.rank_id = rank_id
	local rank_cfg = config.rank_ex[rank_id]

	self._layout_objs["sub_type_name"]:SetText(rank_cfg.name)

	self._layout_objs["img"]:SetSprite("ui_rank", rank_cfg.icon)
end

function RankSubTemplate:GetRankId()
	return self.rank_id
end

return RankSubTemplate