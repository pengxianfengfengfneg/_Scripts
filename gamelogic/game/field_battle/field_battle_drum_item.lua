local FieldBattleDrumItem = Class(game.UITemplate)

function FieldBattleDrumItem:_init()
    
end

function FieldBattleDrumItem:OpenViewCallBack()
    self:Init()
end

function FieldBattleDrumItem:CloseViewCallBack()
    self:CloseTipsView()
end

function FieldBattleDrumItem:Init()
    self.txt_word = self._layout_objs["txt_word"]
    self.txt_effect = self._layout_objs["txt_effect"]
    self.btn_drum = self._layout_objs["btn_drum"]
    self.img_gold = self._layout_objs["img_gold"]
    self.txt_gold = self._layout_objs["txt_gold"]
    
    self.btn_drum:AddClickCallBack(function()
    	if self.is_drum_used then
    		game.GameMsgCtrl.instance:PushMsg(config.words[5267])
    		return
    	end

    	if not self:CheckGold() then
    		return
    	end

        local title = config.words[1660]
        local content = string.format(config.words[5279], self.cost_num)
        self.tips_view = game.GameMsgCtrl.instance:CreateMsgBox(title, content)
        self.tips_view:SetOkBtn(function()
            game.FieldBattleCtrl.instance:SendTerritoryBeatDrum(self:GetDrumId())

            self:CloseTipsView()
        end, config.words[100])
        self.tips_view:SetCancelBtn(function()
            self:CloseTipsView()
        end, config.words[101], true)
        self.tips_view:Open()
	end)
end

function FieldBattleDrumItem:CloseTipsView()
    if self.tips_view then
        self.tips_view:Close()
        self.tips_view = nil
    end
end

function FieldBattleDrumItem:UpdateData(data)
    self.drum_id = data.id
    self.cost_num = data.cost
    self.drum_desc = data.desc
    self.drum_effect = data.effect

    self.txt_word:SetText(self.drum_desc)
    self.txt_effect:SetText(self.drum_effect)
    self.txt_gold:SetText(self.cost_num)

	self:UpdateState()
end

function FieldBattleDrumItem:GetDrumId()
	return self.drum_id
end

function FieldBattleDrumItem:CheckGold()
	local gold_num = game.BagCtrl.instance:GetGold()
	if gold_num >= self.cost_num then
		return true
	end

	game.GameMsgCtrl.isntance:PushMsg(config.words[5266])
	return false
end

function FieldBattleDrumItem:UpdateState()
	self.is_drum_used = game.FieldBattleCtrl.instance:IsDrumUsed(self:GetDrumId())
	self.btn_drum:SetGray(self.is_drum_used)
end

return FieldBattleDrumItem