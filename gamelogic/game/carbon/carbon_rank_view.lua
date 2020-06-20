local CarbonRankView = Class(game.BaseView)

function CarbonRankView:_init(ctrl)
	self._package_name = "ui_carbon"
    self._com_name = "carbon_rank"
    self._view_level = game.UIViewLevel.Second
    self._mask_type = game.UIMaskType.Full
	self.ctrl = ctrl
end

function CarbonRankView:CloseViewCallBack()
    self.ui_list:DeleteMe()
end

function CarbonRankView:OpenViewCallBack(rank_id)

	self:GetBgTemplate("common_bg"):SetTitleName(config.words[1413])

	self:InitList()

	self.cur_rank_type = rank_id

	game.RankCtrl.instance:GetRankDataReq(self.cur_rank_type, 1)

	self:BindEvent(game.RankEvent.UpdateRightList, function(data)
        self:UpdateList(self.cur_rank_type)
    end)
end

function CarbonRankView:OnEmptyClick()
    self:Close()
end

function CarbonRankView:InitList()

	self.list = self._layout_objs["n12"]
	self.ui_list = game.UIList.New(self.list)
	self.ui_list:SetVirtual(true)

	self.ui_list:SetCreateItemFunc(function(obj)
		local item = require("game/carbon/carbon_rank_item").New(self.cur_rank_type)
        item:SetVirtual(obj)
        item:Open()
        return item
	end)

	self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_carbon:carbon_rank_item"
    end)

    self.ui_list:AddScrollEndCallback(function(perX, perY)
        if perY > 0 then
            game.RankCtrl.instance:GetNextPageData(self.cur_rank_type)
        end
    end)
end

function CarbonRankView:UpdateList()

	local rank_data = game.RankCtrl.instance:GetRankData()
	local type_list = rank_data:GetRankDataByType(self.cur_rank_type)

	local num = #type_list

	self.ui_list:SetItemNum(num)

	self:OnUpdateMyRank()
end

function CarbonRankView:OnUpdateMyRank()
    local rank_data = game.RankCtrl.instance:GetRankData()
    local my_rank_data = rank_data:GetMyRank(self.cur_rank_type)

    if my_rank_data and my_rank_data[1] then

        local my_rank_num = my_rank_data[1].item.rank
        local level = my_rank_data[1].item.columns[3].column
        self._layout_objs["n16"]:SetText(tostring(my_rank_num))
        self._layout_objs["n18"]:SetText(tostring(level))
    else
        self._layout_objs["n16"]:SetText(config.words[1411])
        self._layout_objs["n18"]:SetText(tostring(0))
    end
end

return CarbonRankView