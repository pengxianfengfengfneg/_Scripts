local InfoDescItem = Class(game.UITemplate)

function InfoDescItem:SetItemInfo(desc, param)
	if param then
	    self._layout_objs.content:SetText(string.format(desc, table.unpack(param)))
	else
	    self._layout_objs.content:SetText(desc)
	end
end

function InfoDescItem:SetBGVisible(val)
    self._layout_objs.bg:SetVisible(val)
end

return InfoDescItem