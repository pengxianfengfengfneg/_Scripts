local MakeTeamApplyItem = Class(game.UITemplate)

function MakeTeamApplyItem:_init()
    self.ctrl = game.MakeTeamCtrl.instance
    
end

function MakeTeamApplyItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamApplyItem:CloseViewCallBack()
    
end

function MakeTeamApplyItem:Init()
	self.img_career = self._layout_objs["img_career"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_lv = self._layout_objs["txt_lv"]

	self.btn_accept = self._layout_objs["btn_accept"]
	self.btn_accept:AddClickCallBack(function()
		self.ctrl:SendTeamAcceptApply(self.role_id, 1)
	end)

end

function MakeTeamApplyItem:UpdateData(data)
	self.career = data.career
	self.role_id = data.id
	self.role_name = data.name
	self.role_level = data.level

	self.txt_name:SetText(self.role_name)
	self.txt_lv:SetText(self.role_level)

	self:UpdateCareer(data.career)
end

function MakeTeamApplyItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career]
	self.img_career:SetSprite("ui_main", res)
end

return MakeTeamApplyItem
