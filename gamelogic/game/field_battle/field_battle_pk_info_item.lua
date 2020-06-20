local FieldBattlePkInfoItem = Class(game.UITemplate)

local BlueRes = {
	[0] = "024",
	[1] = "019",
	[2] = "018",
}
local RedRes = {
	[0] = "024",
	[1] = "018",
	[2] = "019",
}
local FieldRes = {
	[1] = "010",
	[2] = "012",
	[3] = "014",
}

function FieldBattlePkInfoItem:_init(room)
    self.room = room
end

function FieldBattlePkInfoItem:OpenViewCallBack()
    self:Init()
end

function FieldBattlePkInfoItem:CloseViewCallBack()

end

function FieldBattlePkInfoItem:Init()
    self.img_blue = self._layout_objs["img_blue"]
    self.img_red = self._layout_objs["img_red"]
    self.img_field = self._layout_objs["img_field"]
    self.txt_blue = self._layout_objs["txt_blue"]
    self.txt_red = self._layout_objs["txt_red"]

    self.txt_blue:SetVisible(false)
	self.txt_red:SetVisible(false)

    self.img_field:SetSprite("ui_field_battle", FieldRes[self.room])
end

function FieldBattlePkInfoItem:UpdateData(data)
	local is_visible = data.fin==1
	self.img_blue:SetVisible(is_visible)
	self.img_red:SetVisible(is_visible)

	self.txt_blue:SetVisible(true)
	self.txt_red:SetVisible(true)

	if is_visible then
		self.img_blue:SetSprite("ui_field_battle", BlueRes[data.win])
		self.img_red:SetSprite("ui_field_battle", RedRes[data.win])
	end

	self.txt_blue:SetText(string.format(config.words[5265], data.blue))
	self.txt_red:SetText(string.format(config.words[5265], data.red))
end

return FieldBattlePkInfoItem