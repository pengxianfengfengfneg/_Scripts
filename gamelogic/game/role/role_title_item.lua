local RoleTitleItem = Class(game.UITemplate)

function RoleTitleItem:_init()

end

function RoleTitleItem:UpdateData(index, data)
	self.id = data.id
	self._layout_objs["bg"]:SetVisible(index % 2 == 0)
	self._layout_objs["txt"]:SetText(data.name)
	self._layout_objs["sel_bg"]:SetVisible(self.sel_id == self.id)

	local clr = game.TitleUIColor2[data.quality]
	self._layout_objs["txt"]:SetColor(clr[1], clr[2], clr[3], clr[4])

	self:SetGray(data.valid ~= 1)
end

function RoleTitleItem:GetID()
	return self.id
end

function RoleTitleItem:SetSelTitleID(id)
	self.sel_id = id
	self._layout_objs["sel_bg"]:SetVisible(self.sel_id == self.id)
end

function RoleTitleItem:SetGray(val)
	self._layout_objs["txt"]:SetGray(val)
end

return RoleTitleItem
