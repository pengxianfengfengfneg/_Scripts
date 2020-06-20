local GuildArenaRankItem = Class(game.UITemplate)

function GuildArenaRankItem:_init(parent)
	self.parent = parent
end

function GuildArenaRankItem:OpenViewCallBack()

end

function GuildArenaRankItem:RefreshItem(idx)

	local score_rank = self.parent.score_rank

	if score_rank and score_rank[idx] then
		
		local rank_info = score_rank[idx]
		self._layout_objs["rank_num"]:SetText(rank_info.rank)
		self._layout_objs["role_name"]:SetText(rank_info.name)
		self._layout_objs["guild_name"]:SetText(rank_info.guild_name)
		self._layout_objs["score"]:SetText(rank_info.score)
		self._layout_objs["kill"]:SetText(rank_info.kill_role)

		if rank_info.rank == 1 then
			self._layout_objs["rank_img"]:SetSprite("ui_common", "sl_13")
			self._layout_objs["rank_img"]:SetVisible(true)
		elseif rank_info.rank == 2 then
			self._layout_objs["rank_img"]:SetSprite("ui_common", "sl_14")
			self._layout_objs["rank_img"]:SetVisible(true)
		elseif rank_info.rank == 3 then
			self._layout_objs["rank_img"]:SetSprite("ui_common", "sl_15")
			self._layout_objs["rank_img"]:SetVisible(true)
		else
			self._layout_objs["rank_img"]:SetVisible(false)
		end

		if (idx%2) == 1 then
			self._layout_objs["bg"]:SetSprite("ui_common", "006")
		else
			self._layout_objs["bg"]:SetSprite("ui_common", "006_bt")
		end
	end
end

return GuildArenaRankItem