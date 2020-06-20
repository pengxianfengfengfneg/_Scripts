local FashionItem = Class(game.UITemplate)

function FashionItem:_init(data)
    self.item_data = data
    
    self.ctrl = game.FashionCtrl.instance
end

function FashionItem:OpenViewCallBack()
	self:Init()
	
end

function FashionItem:CloseViewCallBack()
    if self.goods_item then
    	self.goods_item:DeleteMe()
    	self.goods_item = nil
    end
end

function FashionItem:Init()
	self.img_used = self._layout_objs["img_used"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_get_way = self._layout_objs["txt_get_way"]

	self.fashion_id = self.item_data.id or 0
	self.item_id = self.item_data.item_id or 0
	self.fashion_name = self.item_data.name or ""
	self.get_way = self.item_data.way or ""
	self.func_id = self.item_data.func_id or 0
	self.fashion_cost = self.item_data.cost or {}
	self.fashion_attr = self.item_data.attr or {}

	self.txt_name:SetText(self.fashion_name)
	self.txt_get_way:SetText(string.format(config.words[2002], self.get_way))

    local info = {
	    id = self.item_id,
	    num = 0
	}
    self.goods_item = game_help.GetGoodsItem(self._layout_objs["item"])
    self.goods_item:SetItemInfo(info)

    self:DoUpdate()
end

function FashionItem:OnClick()
	
end

function FashionItem:GetName()
	return self.fashion_name
end

function FashionItem:GetWay()
	return self.get_way
end

function FashionItem:GetId()
	return self.fashion_id
end

function FashionItem:GetItemId()
	return self.item_id
end

function FashionItem:GetFuncId()
	return self.func_id
end

function FashionItem:GetCost()
	return self.fashion_cost
end

function FashionItem:GetAttr()
	return self.fashion_attr
end

function FashionItem:DoUpdate()
	local is_weared = self.ctrl:IsFashionWeared(self:GetId())
	self.img_used:SetVisible(is_weared)

	local is_actived = self.ctrl:IsFashionActived(self:GetId())
	if is_actived then
		local cur_num,max_num = self.ctrl:GetFashionColorActivedNum(self:GetId())
		local str_actived = string.format(config.words[2003], cur_num, max_num)
		local color = game.Color.DarkGreen
		if max_num <= 1 then
			color = game.Color.Red
			str_actived = config.words[2004]
		end
		self.txt_get_way:SetText(str_actived)
		self.txt_get_way:SetColor(table.unpack(color))
	end
end

return FashionItem
