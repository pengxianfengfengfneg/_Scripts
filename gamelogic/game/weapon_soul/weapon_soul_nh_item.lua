local WeaponSoulNHItem = Class(game.UITemplate)

function WeaponSoulNHItem:_init(parent)
	self.parent = parent
end

function WeaponSoulNHItem:_delete()
end

function WeaponSoulNHItem:OpenViewCallBack()

end

function WeaponSoulNHItem:CloseViewCallBack()
end

function WeaponSoulNHItem:RefreshItem(idx)

	local list_data = self.parent:GetListData()
	local data = list_data[idx]

	self.ret_index = data.ret.index

	self._layout_objs["times"]:SetText(idx)

	self._layout_objs["tj_img"]:SetVisible(data.ret.recommend == 1)

	self._layout_objs.btn_checkbox:SetSelected(data.ret.recommend == 1)

	for k, v in ipairs(data.ret.alters) do

		self._layout_objs["attr"..k]:SetText(v.value)

		if v.value > 0 then
			self._layout_objs["attr"..k]:SetColor(54,122,33,255)
		elseif v.value < 0 then
			self._layout_objs["attr"..k]:SetColor(255,0,0,255)
		else
			self._layout_objs["attr"..k]:SetColor(112,83,52,255)
		end
	end
end

function WeaponSoulNHItem:GetSelectFlag()
	return self._layout_objs.btn_checkbox:GetSelected()
end

return WeaponSoulNHItem