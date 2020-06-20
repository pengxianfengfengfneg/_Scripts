local GuildArenaHurtItem = Class(game.UITemplate)

function GuildArenaHurtItem:_init(parent)
	self.parent = parent
end

function GuildArenaHurtItem:OpenViewCallBack()

end

function GuildArenaHurtItem:RefreshItem(idx)

	local hurt_rank = self.parent:GetHurtRank()
	if hurt_rank and hurt_rank[idx] then
		local rank_info = hurt_rank[idx]
		self._layout_objs["rank_txt"]:SetText(rank_info.rank)
		self._layout_objs["guild_name"]:SetText(rank_info.guild_name)

		local hurt = string.format("%.2f", rank_info.hurt/100)
		self._layout_objs["hurt_txt"]:SetText(tostring(hurt).."%")
	end
end

return GuildArenaHurtItem