local RankMainTemplate = Class(game.UITemplate)

function RankMainTemplate:_init(parent, param)
	self.parent = parent
	self.idx = param
	self.rank_data = game.RankCtrl.instance:GetRankData()
end

function RankMainTemplate:OpenViewCallBack()

	self._layout_objs["main_type_img"]:SetSprite("ui_rank", "zi_0"..tostring(self.idx))

	local rank_id_list = self.rank_data:GetSubTypeList(self.idx)
	local num = #rank_id_list
	self.rank_id_list = rank_id_list

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/rank/rank_sub_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
        game.RankCtrl.instance:OpenRankSubView(self.idx, item:GetRankId())
    end)

    self.ui_list:SetVirtual(false)

    self.ui_list:SetItemNum(num)

    for k, rank_id in pairs(rank_id_list) do
        game.RankCtrl.instance:CsRankGetTargetRank(rank_id)
    end
end

function RankMainTemplate:GetListData()
	return self.rank_id_list
end

function RankMainTemplate:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

return RankMainTemplate