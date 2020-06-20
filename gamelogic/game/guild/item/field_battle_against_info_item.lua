local FieldBattleAgainstInfoItem = Class(game.UITemplate)

function FieldBattleAgainstInfoItem:_init()
    
end

function FieldBattleAgainstInfoItem:OpenViewCallBack()
    self:Init()
end

function FieldBattleAgainstInfoItem:CloseViewCallBack()

end

function FieldBattleAgainstInfoItem:Init()
    self.txt_left = self._layout_objs["txt_left"]
    self.txt_right = self._layout_objs["txt_right"]

end

function FieldBattleAgainstInfoItem:UpdateData(data)
	self.blue_id = data.blue_id
	self.red_id = data.red_id

	local blue_info = game.FieldBattleCtrl.instance:GetTerritoryInfoForId(data.blue_id)
	local red_info = game.FieldBattleCtrl.instance:GetTerritoryInfoForId(data.red_id)

    self.txt_left:SetText(red_info.name)
    self.txt_right:SetText(blue_info.name)

end

return FieldBattleAgainstInfoItem