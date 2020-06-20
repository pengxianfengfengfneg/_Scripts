local FireworkTipsItem = Class(game.UITemplate)

function FireworkTipsItem:_init()
    
end

function FireworkTipsItem:OpenViewCallBack()
	self.head_icon = self:GetIconTemplate("head_icon")

	self.img_career = self._layout_objs["img_career"]

	self.txt_lv = self._layout_objs["txt_lv"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_relation = self._layout_objs["txt_relation"]
end

function FireworkTipsItem:CloseViewCallBack()
    
end

function FireworkTipsItem:UpdateData(data)
	self.role_id = data.id

	self.txt_lv:SetText(data.level)
	self.txt_name:SetText(data.name)

	local color = game.FriendRelationColor[data.stat] or game.Color.White
	self.txt_relation:SetText(game.FriendRelationName[data.stat] or "")
	self.txt_relation:SetColor(table.unpack(color))

	self:UpdateCareer(data.career)
	self:UpdateHeadIcon(data)
end

function FireworkTipsItem:GetRoleId()
	return self.role_id
end

function FireworkTipsItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career]
	self.img_career:SetSprite("ui_main", res)
end

function FireworkTipsItem:UpdateHeadIcon(data)
    self.head_icon:UpdateData(data)
end

return FireworkTipsItem
