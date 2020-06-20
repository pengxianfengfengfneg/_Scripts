local GuildArenaRewardTemplate = Class(game.UITemplate)

function GuildArenaRewardTemplate:_init(parent)
	self.parent = parent
end

function GuildArenaRewardTemplate:OpenViewCallBack()

end

function GuildArenaRewardTemplate:CloseViewCallBack()
	for k, v in pairs(self.goods_items or {}) do
		v:DeleteMe()
	end
	self.goods_items = nil
end

function GuildArenaRewardTemplate:RefreshItem(idx)

	if not self.goods_items then
		self.goods_items = {}
	end

	local reward_cfg = self.parent:GetRewardCfg()
	local cfg = reward_cfg[idx]
	local drop_id = cfg[3]
	local item_infos = config.drop[drop_id].client_goods_list

	self._layout_objs["n0"]:SetText(string.format(config.words[5212], cfg[1]))

	for i = 1, 3 do

		local item_info = item_infos[i]

		if item_info then

			if not self.goods_items[i] then
				self.goods_items[i] = require("game/bag/item/goods_item").New()
				self.goods_items[i]:SetVirtual(self._layout_objs["item"..i])
				self.goods_items[i]:SetShowTipsEnable(true)
				self.goods_items[i]:Open()
			end
			self.goods_items[i]:SetItemInfo({ id = item_info[1], num = item_info[2]})
			self._layout_objs["item"..i]:SetVisible(true)
		else
			self._layout_objs["item"..i]:SetVisible(false)
		end
	end

	if (idx % 2) == 1 then
		self._layout_objs["n4"]:SetSprite("ui_common", "006")
	else
		self._layout_objs["n4"]:SetSprite("ui_common", "006_bt")
	end
end

return GuildArenaRewardTemplate