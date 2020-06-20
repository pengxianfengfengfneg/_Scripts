local HairItem = Class(game.UITemplate)

function HairItem:_init(data)
    self.item_data = data
    
end

function HairItem:OpenViewCallBack()
	self:Init()
	
end

function HairItem:CloseViewCallBack()
    if self.goods_item then
    	self.goods_item:DeleteMe()
    	self.goods_item = nil
    end
end

function HairItem:Init()
	self.img_used = self._layout_objs["img_used"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_get_way = self._layout_objs["txt_get_way"]

	self.hair_id = self.item_data.id or 0
	self.item_id = self.item_data.item_id or 0
	self.hair_name = self.item_data.name or ""
	self.get_way = self.item_data.way or ""

	self.txt_name:SetText(self.hair_name)
	self.txt_get_way:SetText("来源：" .. self.get_way)
	
	local info = {
		id = self.item_id,
		num = 0	
	}
	self.goods_item = game_help.GetGoodsItem(self._layout_objs["item"])
	self.goods_item:SetItemInfo(info)

	self:UpdateState()
end

function HairItem:OnClick()
	
end

function HairItem:GetName()
	return self.hair_name
end

function HairItem:GetWay()
	return self.get_way
end

function HairItem:GetId()
	return self.hair_id
end

function HairItem:UpdateState()
	local is_used = game.FashionCtrl.instance:IsHairUsed(self:GetId())
	self.img_used:SetVisible(is_used)
end

return HairItem
