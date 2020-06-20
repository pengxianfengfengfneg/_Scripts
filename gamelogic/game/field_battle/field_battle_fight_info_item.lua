local FieldBattleFightInfoItem = Class(game.UITemplate)

function FieldBattleFightInfoItem:_init()
    
end

function FieldBattleFightInfoItem:OpenViewCallBack()
    self:Init()

    
end

function FieldBattleFightInfoItem:CloseViewCallBack()

end

function FieldBattleFightInfoItem:Init()
    self.img_bg = self._layout_objs["img_bg"]
    self.img_rank = self._layout_objs["img_rank"]
    self.txt_name = self._layout_objs["txt_name"]
    self.txt_kill = self._layout_objs["txt_kill"]
    self.txt_score = self._layout_objs["txt_score"]
    self.txt_rank = self._layout_objs["txt_rank"]
    
end

function FieldBattleFightInfoItem:UpdateData(data)
	self.img_bg:SetSprite("ui_common", data.rank%2==1 and "sl_11" or "sl_12")

	local is_top3 = data.rank<=3
    self.img_rank:SetVisible(is_top3)
    if is_top3 then
    	self.img_rank:SetSprite("ui_common", "sl_1" .. (2+data.rank))
    end

    self.txt_name:SetText(data.name)
    self.txt_kill:SetText(data.kill)
    self.txt_score:SetText(data.score)
    self.txt_rank:SetText(data.rank)

    self.txt_rank:SetVisible(not is_top3)


end

return FieldBattleFightInfoItem