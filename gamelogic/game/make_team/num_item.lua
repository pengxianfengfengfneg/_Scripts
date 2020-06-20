local NumItem = Class(game.UITemplate)

function NumItem:_init()
    
end

function NumItem:OpenViewCallBack()
	self:Init()
end

function NumItem:CloseViewCallBack()
    
end

function NumItem:Init()
	self._num = 0

	self.txt_title = self._layout_objs["title"]
end

function NumItem:UpdateData(data)
	self._num = data

	local str = (data>0 and data or "")
	self.txt_title:SetText(str)
end

function NumItem:GetNum()
	return self._num
end

return NumItem
