local MarketLogView = Class(game.BaseView)

function MarketLogView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_log_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function MarketLogView:_delete()
    
end

function MarketLogView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitLogList()
    self:RegisterAllEvents()
    self.ctrl:SendMarketLog()
end

function MarketLogView:CloseViewCallBack()

end

function MarketLogView:RegisterAllEvents()
    local events = {
        {game.MarketEvent.OnMarketLog, handler(self, self.OnMarketLog)},
    }
    for k, v in pairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function MarketLogView:Init()
    self._layout_objs.txt_name:SetText(config.words[5622])
    self._layout_objs.txt_type:SetText(config.words[5623])
    self._layout_objs.txt_money :SetText(config.words[5624])
    self._layout_objs.txt_time:SetText(config.words[5625])

    local market_info = self.ctrl:GetMarketInfo()
    self._layout_objs.txt_num:SetText(string.format(config.words[5620], game.Utils.NumberFormat(market_info.turnover)))
    self._layout_objs.txt_volume:SetText(string.format(config.words[5621], game.Utils.NumberFormat(market_info.volume)))
end

function MarketLogView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5626])
end

function MarketLogView:InitLogList()
    self.list_log = self:CreateList("list_log", "game/market/item/market_log_item")
    self.list_log:SetRefreshItemFunc(function(item, idx)
        local item_info = self.log_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)
end

function MarketLogView:UpdateLogList(log_list_data)
    self.log_list_data = log_list_data or {}
    self.list_log:SetItemNum(#log_list_data)
end

function MarketLogView:OnMarketLog(data)
    self:UpdateLogList(data.logs)
end

return MarketLogView
