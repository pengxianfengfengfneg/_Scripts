local WeaponSoulJPItem = Class(game.UITemplate)

function WeaponSoulJPItem:_init(parent)
	self.parent = parent
	self.weapon_soul_data = game.WeaponSoulCtrl.instance:GetData()
end

function WeaponSoulJPItem:_delete()
end

function WeaponSoulJPItem:OpenViewCallBack()

end

function WeaponSoulJPItem:CloseViewCallBack()
	if self.goods_item then
        self.goods_item:DeleteMe()
        self.goods_item = nil
    end
end

function WeaponSoulJPItem:RefreshItem(idx)
	
	self.idx = idx

	local list_data = self.parent:GetListData()
	local jp_id = list_data[idx]
	local jp_cfg = config.weapon_soul_avatar[jp_id]

	self._layout_objs["n3"]:SetText(jp_cfg.name)

	local state_str = self.weapon_soul_data:GetJPStateStr(jp_id)
	self._layout_objs["n4"]:SetText(state_str)

	local is_wear = self.weapon_soul_data:CheckJPWear(jp_id)
	self._layout_objs["ycd_img"]:SetVisible(is_wear)

	if not self.goods_item then
		self.goods_item =  require("game/bag/item/goods_item").New()
        self.goods_item:SetVirtual(self._layout_objs["item"])
        self.goods_item:Open()
	end

	self.goods_item:SetItemInfo({id = jp_cfg.icon})
end

function WeaponSoulJPItem:SetSelected(val)
	self._layout_objs["n1"]:SetVisible(val)
end

return WeaponSoulJPItem