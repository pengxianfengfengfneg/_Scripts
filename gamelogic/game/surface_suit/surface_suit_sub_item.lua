local SurfaceSuitSubItem = Class(game.UITemplate)

function SurfaceSuitSubItem:_init(data)
    self.item_data = data
end

function SurfaceSuitSubItem:OpenViewCallBack()
	self:Init()
	
	self:UpdateState()
end

function SurfaceSuitSubItem:CloseViewCallBack()
    if self.goods_item then
    	self.goods_item:DeleteMe()
    	self.goods_item = nil
    end
end

function SurfaceSuitSubItem:Init()	
	self.txt_state = self._layout_objs["txt_state"]

	self.rtx_name = self._layout_objs["rtx_name"]	
	self.rtx_name:SetText(self.item_data.name)
	self.rtx_name:AddClickCallBack(function()
		-- 跳转皮肤界面
		if self.item_data.click_func then
			self.item_data.click_func(self:GetId())
		end
	end)

	local info = {
	    id = self.item_data.item_id,
	    num = 0
	}
    self.goods_item = game_help.GetGoodsItem(self._layout_objs["item"])
    self.goods_item:SetItemInfo(info)
end

function SurfaceSuitSubItem:GetId()
	return self.item_data.id
end

function SurfaceSuitSubItem:GetSuitId()
	return self.item_data.suit_id
end

function SurfaceSuitSubItem:GetModelId()
	return self.item_data.model_id
end

function SurfaceSuitSubItem:GetModelType()
	return self.item_data.model_type
end

function SurfaceSuitSubItem:UpdateState()
	local suit_id = self:GetSuitId()
	local info = game.SurfaceSuitCtrl.instance:GetSuitInfo(suit_id)
	if not info then
		return
	end

	local color
	local word_id
	local val = info[self.item_data.key]
	if val then
		word_id = (val>0 and 2851 or 2850)
		color = (val>0 and game.Color.DarkGreen or game.Color.GrayBrown)
	else
		word_id = 2852
		color = game.Color.GrayBrown
	end
	self.txt_state:SetText(config.words[word_id])
	self.txt_state:SetColor(table.unpack(color))
end

return SurfaceSuitSubItem
