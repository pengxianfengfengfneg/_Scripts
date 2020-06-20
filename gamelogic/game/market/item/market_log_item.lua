local MarketLogItem = Class(game.UITemplate)

function MarketLogItem:_init(ctrl)
    self.ctrl = ctrl
end

function MarketLogItem:OpenViewCallBack()

end

function MarketLogItem:CloseViewCallBack()

end

function MarketLogItem:SetItemInfo(item_info, idx)
    self._layout_objs.txt_name:SetText(item_info.name .. "x" .. item_info.num)
    self._layout_objs.txt_money:SetText(game.Utils.NumberFormat(item_info.money))
    self._layout_objs.txt_time:SetText(os.date("%Y-%m-%d %H:%M:%S", item_info.time))

    self._layout_objs.img_bg:SetVisible(idx % 2 == 1)
    self._layout_objs.img_money:SetSprite("ui_common", config.money_type[item_info.mtype].icon)
    self._layout_objs.txt_type:SetText(item_info.action == 1 and config.words[5656] or config.words[5657])
end

return MarketLogItem