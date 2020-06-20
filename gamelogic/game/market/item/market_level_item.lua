local MarketLevelItem = Class(game.UITemplate)

function MarketLevelItem:_init(ctrl)
    self.ctrl = ctrl
end

function MarketLevelItem:OpenViewCallBack()

end

function MarketLevelItem:CloseViewCallBack()

end

function MarketLevelItem:SetItemInfo(item_info, idx)
    self._layout_objs.txt_name:SetText(item_info.name)
    self._layout_objs.txt_turnover:SetText(game.Utils.NumberFormat(item_info.turnover))
    self._layout_objs.txt_volume:SetText(game.Utils.NumberFormat(item_info.volume))
    self._layout_objs.txt_num:SetText(item_info.num)

    self._layout_objs.img_bg:SetVisible(idx % 2 == 1)
end

return MarketLevelItem