local RankTemplate = Class(game.UITemplate)

function RankTemplate:_init(parent)
	self.parent = parent
	self.rank_data = game.RankCtrl.instance:GetRankData()
end

function RankTemplate:OpenViewCallBack()

	self._layout_objs["n0"]:SetTouchDisabled(false)
	self._layout_objs["n0"]:AddClickCallBack(function()
		self:OnClick()
    end)
end

function RankTemplate:RefreshItem(idx)

	self.rank_id = self.parent:GetRankId()

	-- if (idx%2) == 1 then
	-- 	self._layout_objs["n0"]:SetSprite("ui_common", "006_bt")
	-- else
	-- 	self._layout_objs["n0"]:SetSprite("ui_common", "005")
	-- end

	if self.rank_id then
		local type_list = self.rank_data:GetRankDataByType(self.rank_id)
		local item_data = type_list[idx]

		if item_data then
			self.item_data = item_data
			self.item = item_data.item
			local rank = item_data.item.rank

			if rank == 1 then
				self._layout_objs["rank_img"]:SetSprite("ui_common", "pm_1")
				self._layout_objs["rank_img"]:SetVisible(true)
			elseif rank == 2 then
				self._layout_objs["rank_img"]:SetSprite("ui_common", "pm_2")
				self._layout_objs["rank_img"]:SetVisible(true)
			elseif rank == 3 then
				self._layout_objs["rank_img"]:SetSprite("ui_common", "pm_3")
				self._layout_objs["rank_img"]:SetVisible(true)
			else
				self._layout_objs["rank_img"]:SetVisible(false)
				self._layout_objs["rank_num"]:SetText(tostring(rank))
			end

			self._layout_objs["column1"]:SetText(item_data.item.columns[1].column)
			self._layout_objs["column2"]:SetText(item_data.item.columns[2].column)

			local str = tostring(item_data.item.columns[3].column)
			self._layout_objs["column3"]:SetText(str)

			if item_data.item.columns[4] and tonumber(item_data.item.columns[4].column) > 0 then
				self._layout_objs["column4"]:SetText(tostring(item_data.item.columns[4].column))
			else
				self._layout_objs["column4"]:SetText("")
			end

			self._layout_objs["career_img"]:SetSprite("ui_common", "career"..item_data.item.columns[5].column)
		end

		local rank_cfg = config.rank_ex[self.rank_id]
	    if rank_cfg.desc1 == "" then
	        self._layout_objs["career_img"]:SetPosition(256, 20)
	        self._layout_objs["column1"]:SetPosition(306, 14)
	        self._layout_objs["column2"]:SetPosition(306, 47)
	    else
	        self._layout_objs["career_img"]:SetPosition(156, 20)
	        self._layout_objs["column1"]:SetPosition(206, 14)
	        self._layout_objs["column2"]:SetPosition(206, 47)
	    end
	end
end

function RankTemplate:OnClick()
	if self.rank_id >= 3001 and self.rank_id <= 3008 then
		game.ViewOthersCtrl.instance:SendViewOthersInfo(self.rank_id % 3000 + 10, self.item.id)
	elseif self.rank_id == 1003 then
		game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewPet, self.item.id)
	else
		game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, self.item.id)
	end
end

return RankTemplate