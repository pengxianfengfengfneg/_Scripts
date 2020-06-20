local AuctionCtrl = Class(game.BaseCtrl)

function AuctionCtrl:_init()
	if AuctionCtrl.instance ~= nil then
		error("AuctionCtrl Init Twice!")
	end
	AuctionCtrl.instance = self
	
	self.auction_data = require("game/auction/auction_data").New()

	self:RegisterAllProtocal()
	self:RegisterAllEvents()
end

function AuctionCtrl:_delete()
	self.auction_data:DeleteMe()
	self.auction_data = nil

	if self.auction_view then
		self.auction_view:DeleteMe()
		self.auction_view = nil
	end

	if self.auction_his_view then
		self.auction_his_view:DeleteMe()
		self.auction_his_view = nil
	end

	if self.auction_tips_view then
		self.auction_tips_view:DeleteMe()
		self.auction_tips_view = nil
	end

	AuctionCtrl.instance = nil
end

function AuctionCtrl:RegisterAllProtocal()
	self:RegisterProtocalCallback(30802, "ScAuctionInfo")
	self:RegisterProtocalCallback(30804, "ScAuctionLogs")
	self:RegisterProtocalCallback(30806, "ScAuctionBid")
	self:RegisterProtocalCallback(30808, "ScAuctionItem")
	self:RegisterProtocalCallback(30809, "ScAuctionItemNotify")
	self:RegisterProtocalCallback(30810, "ScAuctionNotifyNew")
end

function AuctionCtrl:RegisterAllEvents()
    local events = {
        {game.LoginEvent.LoginSuccess, handler(self, self.CsAuctionInfo)},
    }

    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function AuctionCtrl:OpenMainView()

	if not self.auction_view then
		self.auction_view = require("game/auction/auction_view").New(self)
	end
	if not self.auction_view:IsOpen() then
		self.auction_view:Open()
	else
		self:FireEvent(game.AuctionEvent.UpdateList, data)
	end
end

function AuctionCtrl:GetData()
	return self.auction_data
end

function AuctionCtrl:OpenHisView(oper_type)

	if not self.auction_his_view then
		self.auction_his_view = require("game/auction/auction_his_view").New(self)
	end
	self.auction_his_view:Open(oper_type)
end

function AuctionCtrl:OpenTipsView(oper_type, data)

	if not self.auction_tips_view then
		self.auction_tips_view = require("game/auction/auction_tips_view").New(self)
	end
	self.auction_tips_view:SetOperType(oper_type)
	self.auction_tips_view:Open(data)
end

--拍卖信息
function AuctionCtrl:CsAuctionInfo(need_open)
	self:SendProtocal(30801,{})
	self.need_open = need_open
end

function AuctionCtrl:ScAuctionInfo(data)
	self.auction_data:SetData(data)

	self:FireEvent(game.AuctionEvent.UpdateInfo, data)

	if self.need_open then
		self:OpenMainView()
		self.need_open = nil
	end
end

--拍卖日志
function AuctionCtrl:CsAuctionLogs(oper_type)
	self:SendProtocal(30803,{type = oper_type})
end

function AuctionCtrl:ScAuctionLogs(data)
	self.auction_data:SetLogs(data)
	self:OpenHisView(data.type)
end

--竞价
function AuctionCtrl:CsAuctionBid(a_id, u_id, type_i)
	self:SendProtocal(30805,{aid = a_id, uid = u_id, type = type_i})
end

function AuctionCtrl:ScAuctionBid(data)
	self.auction_data:UpdateData(data)
	self:FireEvent(game.AuctionEvent.UpdateList, data)
end

function AuctionCtrl:ScAuctionItem(data)

end

--同步竞价价格变化
function AuctionCtrl:ScAuctionItemNotify(data)
	self.auction_data:ModifyItemInfo(data)
	self:FireEvent(game.AuctionEvent.UpdateList, data)
end

function AuctionCtrl:ScAuctionNotifyNew()
	self:CsAuctionInfo()
end

game.AuctionCtrl = AuctionCtrl

return AuctionCtrl