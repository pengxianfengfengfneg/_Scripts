local RankCtrl = Class(game.BaseCtrl)

function RankCtrl:_init()
	if RankCtrl.instance ~= nil then
		error("RankCtrl Init Twice!")
	end
	RankCtrl.instance = self
	
	self.rank_data = require("game/rank/rank_data").New()

	self:RegisterAllProtocal()
	self:RegisterAllEvents()
end

function RankCtrl:_delete()
	self.rank_data:DeleteMe()
	self.rank_data = nil

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	if self.rank_sub_view then
		self.rank_sub_view:DeleteMe()
		self.rank_sub_view = nil
	end

	RankCtrl.instance = nil
end

function RankCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(40502, "GetRankDataResponse")
	self:RegisterProtocalCallback(40504, "ScRankGetTargetRank")
end

function RankCtrl:RegisterAllEvents()
    local events = {

    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function RankCtrl:OpenRankView()
	if not self.rank_view then
		self.rank_view = require("game/rank/rank_view").New(self)
	end
	self.rank_view:Open()
end

function RankCtrl:CloseRankView()
	if self.rank_view and self.rank_view:IsOpen() then
		self.rank_view:Close()
		self.rank_view = nil
	end
end

function RankCtrl:GetRankDataReq(type, page)
--print("---------40501------------", type)
	self:SendProtocal(40501,{type = type, page = page})
end

function RankCtrl:GetRankDataResponse(data)
	self.rank_data:SetRankData(data)
-- print("---------40502------------") PrintTable(data)
	self:FireEvent(game.RankEvent.UpdateRightList, data)
end

function RankCtrl:GetRankData()
	return self.rank_data
end

function RankCtrl:GetNextPageData(rank_type)

	local cur_page = self.rank_data:GetCurPage(rank_type)
	local next_page = cur_page + 1

	self:GetRankDataReq(rank_type, next_page)
end

function RankCtrl:GetRoleInfo(rank_type, rank)
	local rank_item = self.rank_data:GetRankItem(rank_type, rank)

	if rank_item then
		game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.Rank, rank_item.id, rank_item.platform, rank_item.server_num)
	else
		print("---------rank_item is null------------")
	end
end

function RankCtrl:OpenRankSubView(main_type, rank_id)

	if not self.rank_sub_view then
		self.rank_sub_view = require("game/rank/rank_sub_view").New(self)
	end
	self.rank_sub_view:Open(main_type, rank_id)
end

function RankCtrl:CsRankGetTargetRank(rank_id)
	self:SendProtocal(40503, {type = rank_id})
end

function RankCtrl:ScRankGetTargetRank(data)
	self:FireEvent(game.RankEvent.UpdateMainViewRankInfo, data)
end

game.RankCtrl = RankCtrl

return RankCtrl