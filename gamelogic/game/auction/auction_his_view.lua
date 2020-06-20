local AuctionHisView = Class(game.BaseView)

function AuctionHisView:_init(ctrl)
	self._package_name = "ui_auction"
    self._com_name = "auction_his_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Second
end

function AuctionHisView:OpenViewCallBack(oper_type)

	self.oper_type = oper_type

	self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[4202])

	self:InitList()

	self:UpdateLog()

	self:BindEvent(game.AuctionEvent.UpdateLog, function(data)
		self:UpdateLog()
	end)
end

function AuctionHisView:CloseViewCallBack()

	if self.ui_list then
		self.ui_list:DeleteMe()
	end
end

function AuctionHisView:InitList()

	self.list = self._layout_objs["list"]
	self.ui_list = game.UIList.New(self.list)
	self.ui_list:SetVirtual(true)

	self.ui_list:SetCreateItemFunc(function(obj)
		local item = require("game/auction/auction_his_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
	end)

	self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddItemProviderCallback(function(idx)
        return "ui_auction:auction_his_template"
    end)

    self.ui_list:SetItemNum(0)
end

function AuctionHisView:UpdateLog()
	local auction_data = self.ctrl:GetData()
	local log_list = auction_data:GetLogs(self.oper_type)

	self.ui_list:SetItemNum(#log_list)
end

function AuctionHisView:GetOperType()
	return self.oper_type
end

return AuctionHisView