local RoleTitleAttrItem = Class(game.UITemplate)

function RoleTitleAttrItem:_init()

end

function RoleTitleAttrItem:UpdateData(index, name, val)
	self._layout_objs["bg"]:SetVisible(index % 2 == 1)
	self._layout_objs["name"]:SetText(name)
	self._layout_objs["val"]:SetText(val)
end

return RoleTitleAttrItem
