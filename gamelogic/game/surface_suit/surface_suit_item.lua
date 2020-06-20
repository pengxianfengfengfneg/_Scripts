local SurfaceSuitItem = Class(game.UITemplate)

function SurfaceSuitItem:_init(data)
    self.item_data = data
end

function SurfaceSuitItem:OpenViewCallBack()
	self:Init()
	
end

function SurfaceSuitItem:CloseViewCallBack()
    if self.goods_item then
    	self.goods_item:DeleteMe()
    	self.goods_item = nil
    end
end

function SurfaceSuitItem:Init()
	local fashion_id = self.item_data.fashion
	local fashion_cfg = config.fashion[fashion_id]
	local item_id = fashion_cfg.item_id

	self.txt_name = self._layout_objs["txt_name"]
	self.img_select = self._layout_objs["img_select"]

	self.txt_name:SetText(self.item_data.name)

	local info = {
	    id = item_id,
	    num = 0
	}
    self.goods_item = game_help.GetGoodsItem(self._layout_objs["item"])
    self.goods_item:SetItemInfo(info)
end

function SurfaceSuitItem:GetData()
	return self.item_data
end

function SurfaceSuitItem:SetSelected(val)
	self.goods_item:SetSelect(val)
end

return SurfaceSuitItem
