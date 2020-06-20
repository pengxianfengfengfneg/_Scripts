local MakeTeamPlatformItem = Class(game.UITemplate)

function MakeTeamPlatformItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function MakeTeamPlatformItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamPlatformItem:CloseViewCallBack()
    
end

function MakeTeamPlatformItem:Init()
	self.img_career = self._layout_objs["img_career"]
	self.txt_lv = self._layout_objs["txt_lv"]
	self.txt_name = self._layout_objs["txt_name"]
	
	self.bar_num = self._layout_objs["bar_num"]

	self.btn_apply = self._layout_objs["btn_apply"]
	self.btn_apply:AddClickCallBack(function()
		self.ctrl:SendTeamApplyFor(self.team_id)
	end)
end

function MakeTeamPlatformItem:UpdateData(data)
	if not data then return end
	
	local data = data.team

	self.team_id = data.id
	self.role_name = data.name
	self.role_level = data.level
	self.career = data.career
	self.leader_id = data.leader
	self.mem_num = data.mem_num

	self.txt_name:SetText(self.role_name)
	self.txt_lv:SetText(self.role_level)
	self.bar_num:SetValue(self.mem_num)

	self:UpdateCareer(data.career)
end

function MakeTeamPlatformItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career]
	if res then
		self.img_career:SetSprite("ui_main", res)
	end
end

return MakeTeamPlatformItem
