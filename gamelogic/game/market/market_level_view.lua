local MarketLevelView = Class(game.BaseView)

function MarketLevelView:_init(ctrl)
    self._package_name = "ui_market"
    self._com_name = "market_level_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function MarketLevelView:_delete()
    
end

function MarketLevelView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:InitLevelList()
end

function MarketLevelView:CloseViewCallBack()

end

function MarketLevelView:Init()
    self._layout_objs.txt_level:SetText(config.words[5612])
    self._layout_objs.txt_turnover:SetText(config.words[5613])
    self._layout_objs.txt_volume :SetText(config.words[5614])
    self._layout_objs.txt_num:SetText(config.words[5615])

    local market_info = self.ctrl:GetMarketInfo()
    local lv = self.ctrl:GetMarketLevel()

    self._layout_objs.txt_cur_level:SetText(string.format(config.words[5619], config.market_level[lv].name))
    self._layout_objs.txt_total_num:SetText(string.format(config.words[5620], game.Utils.NumberFormat(market_info.volume)))
    self._layout_objs.txt_money:SetText(string.format(config.words[5621], game.Utils.NumberFormat(market_info.turnover)))
end

function MarketLevelView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5611])
end

function MarketLevelView:InitLevelList()
    self.list_level = self:CreateList("list_level", "game/market/item/market_level_item")
    self.list_level:SetRefreshItemFunc(function(item, idx)
        local item_info = self.level_list_data[idx]
        item:SetItemInfo(item_info, idx)
    end)
    self:UpdateLevelList()
end

function MarketLevelView:UpdateLevelList()
    local level_list = {}
    for k, v in pairs(config.market_level) do
        table.insert(level_list, v)
    end
    table.sort(level_list, function(m, n)
        return m.level < n.level
    end)
    self.level_list_data = level_list
    self.list_level:SetItemNum(#level_list)
end

return MarketLevelView
