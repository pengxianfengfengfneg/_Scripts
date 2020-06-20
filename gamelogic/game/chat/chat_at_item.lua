local ChatAtItem = Class(game.UITemplate)

function ChatAtItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function ChatAtItem:OpenViewCallBack()
	self:Init()
end

function ChatAtItem:CloseViewCallBack()
    
end

function ChatAtItem:Init()
	self.head_icon = self:GetIconTemplate("head_icon")

	self.txt_name = self._layout_objs["txt_name"]	
	self.txt_lv = self._layout_objs["txt_lv"]	
	self.img_career = self._layout_objs["img_career"]	

end

function ChatAtItem:UpdateData(data)
	self.role_id = data.id
	self.role_name = data.name

	self.item_data = data

	self.head_icon:UpdateData(data)

	self.txt_name:SetText(data.name)
	self.txt_lv:SetText(data.level)

	self:UpdateCareer(data.career)
end

function ChatAtItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career]
	self.img_career:SetSprite("ui_main", res or "")
end

function ChatAtItem:GetName()
	return self.role_name
end

function ChatAtItem:GetId()
	return self.role_id
end

function ChatAtItem:GetData()
	return self.item_data
end

function ChatAtItem:IsSelected()
	return self:GetRoot():GetSelected()
end

return ChatAtItem
