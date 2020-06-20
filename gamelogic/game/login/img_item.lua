local ImgItem = Class(game.UITemplate)

function ImgItem:Refresh(id, bundle_name, sp_name)
	self.id = id
    self._layout_objs["item"]:SetSprite(bundle_name, sp_name, true)
end

function ImgItem:GetID()
	return self.id
end

function ImgItem:SetRotation(val)
	self._layout_root:SetRotation(val)
end

function ImgItem:SetIconType(type)
	if type == 1 then
		self._layout_objs.color_bg:SetSprite("ui_login", "cj_019")
	else
		self._layout_objs.color_bg:SetSprite("ui_login", "cj_020")
	end
end

return ImgItem
