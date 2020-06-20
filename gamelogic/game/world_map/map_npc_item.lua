local MapNpcItem = Class(game.UITemplate)

function MapNpcItem:_init(cfg,x,y, type)
    self.npc_cfg = cfg    
    self.unit_x = x
    self.unit_y = y

    self.item_type = type
end

function MapNpcItem:OpenViewCallBack()
	self:Init()
	
	self.list_link_datas = {}
end

function MapNpcItem:CloseViewCallBack()
    
end

function MapNpcItem:Init()
	self.txt_func_name = self._layout_objs["txt_func_name"]	
	self.txt_name = self._layout_objs["txt_name"]	
	self.img_selected = self._layout_objs["img_selected"]	

	if self.item_type == 1 then
		self.txt_func_name:SetText(self.npc_cfg.func_name or config.words[2413])
	elseif self.item_type == 2 then
		self.txt_func_name:SetText(self.npc_cfg.drama_name or config.words[2410])
	elseif self.item_type == 3 then
		self.txt_func_name:SetText(self.npc_cfg.func_name or config.words[2415])
	end

	self.txt_name:SetText(self.npc_cfg.name)

	self:GetRoot():AddClickCallBack(function()
		if self.click_callback then
			self.click_callback(self)
		end
	end)
end

function MapNpcItem:SetClickCallback(callback)
	self.click_callback = callback
end

function MapNpcItem:GetXY()
	return self.unit_x,self.unit_y
end

function MapNpcItem:SetSelected(val)
	self.img_selected:SetVisible(val)
end

function MapNpcItem:GetItemType()
	return self.item_type
end

function MapNpcItem:GetId()
	return self.npc_cfg.id
end

return MapNpcItem
