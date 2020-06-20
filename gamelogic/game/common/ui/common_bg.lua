local CommonBg = Class(game.UITemplate)

function CommonBg:_init(view)
    self.parent_view = view
end

function CommonBg:OpenViewCallBack()
	self:Init()
end

function CommonBg:CloseViewCallBack()
    
end

function CommonBg:Init()
	self.txt_title = self._layout_objs["txt_title"]	
	
	self.btn_close = self._layout_objs["btn_close"]	
	self.btn_close:AddClickCallBack(function()
		self.parent_view:Close()
	end)

	self.btn_back = self._layout_objs["btn_back"]
	self.btn_back:AddClickCallBack(function()
		self.parent_view:Close()
	end)	

	self.btn_wh = self._layout_objs["btn_wh"]	
	if self.btn_wh then
		self.btn_wh:AddClickCallBack(function()
			if self.wh_callback then
				self.wh_callback()
			end
		end)
	end
end

function CommonBg:SetTitleName(name)
	self.txt_title:SetText(name or "")
	return self
end

function CommonBg:SetInfoCallback(callback)
	self.wh_callback = callback
	return self
end

function CommonBg:HideBtnBack()
	self.btn_back:SetVisible(false)
	return self
end

function CommonBg:ShowBtnBack()
	self.btn_back:SetVisible(true)
	return self
end

function CommonBg:AddBackFunc(func)
	self.btn_back:AddClickCallBack(func)
end

function CommonBg:SetBtnWhVisible(val)
	if self.btn_wh then
		self.btn_wh:SetVisible(val)
	end
	return self
end

function CommonBg:SetBtnCloseVisible(val)
	self.btn_close:SetVisible(val)
end

return CommonBg
