local SongliaoWarRankTemplate = Class(game.UITemplate)

function SongliaoWarRankTemplate:_init(ctrl)

end

function SongliaoWarRankTemplate:OpenViewCallBack()

end

function SongliaoWarRankTemplate:RefreshItem(idx)

	local songliao_data = game.SongliaoWarCtrl.instance:GetData()
	local rank_data = songliao_data:GetRankData()
	local rank_list = rank_data.rank_list

	local one_rank_data = rank_list[idx]

	local rank_num = one_rank_data.rank
	if rank_num < 4 then
		local str = "sl_1"  .. tostring(2+rank_num)
		self._layout_objs["rank_img"]:SetSprite("ui_common", str)
	else
		self._layout_objs["rank_img"]:SetVisible(false)
		self._layout_objs["rank_num"]:SetText(tostring(rank_num))
	end

	self._layout_objs["role_name"]:SetText(one_rank_data.role_name)
	self._layout_objs["win_num"]:SetText(tostring(one_rank_data.score_t))
	self._layout_objs["rank_point_num"]:SetText(tostring(one_rank_data.score_r))
	self._layout_objs["result_num"]:SetText(tostring(one_rank_data.score_w))
	self._layout_objs["guild_name"]:SetText(tostring(config.career_init[one_rank_data.career].name))

	if one_rank_data.camp == 1 then
		self._layout_objs["n0"]:SetSprite("ui_common", "sl_11")
	else
		self._layout_objs["n0"]:SetSprite("ui_common", "sl_12")
	end

	if one_rank_data.hurt > 10000 then
		local str = string.format(config.words[4209], one_rank_data.hurt/10000)
		self._layout_objs["hurt_num"]:SetText(str)
	else
		self._layout_objs["hurt_num"]:SetText(tostring(one_rank_data.hurt))
	end
end

return SongliaoWarRankTemplate