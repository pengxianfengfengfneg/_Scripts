local MakeTeamInviteItem = Class(game.UITemplate)

local timer_mgr = global.TimerMgr

function MakeTeamInviteItem:_init(ctrl)
    self.ctrl = ctrl
    
end

function MakeTeamInviteItem:OpenViewCallBack()
	self:Init()
end

function MakeTeamInviteItem:CloseViewCallBack()
    self:ClearCd()
end

function MakeTeamInviteItem:Init()
	self.img_career = self._layout_objs["img_career"]
	self.txt_name = self._layout_objs["txt_name"]
	self.txt_lv = self._layout_objs["txt_lv"]

	self.btn_invite = self._layout_objs["btn_invite"]
	self.btn_invite:AddClickCallBack(function()
		self.ctrl:SendTeamInviteJoin(self.role_id)

		self:StartCd()
	end)

end

function MakeTeamInviteItem:UpdateData(data)
	self.career = data.career
	self.role_id = data.id
	self.role_name = data.name
	self.role_level = data.level

	self.txt_name:SetText(self.role_name)
	self.txt_lv:SetText(self.role_level)

	self:UpdateCareer(data.career)
end

function MakeTeamInviteItem:StartCd()
	self:ClearCd()

	local cd_time = 30
	self.btn_invite:SetText(string.format(config.words[4984], cd_time))
	self.btn_invite:SetTouchEnable(false)

	self.cd_timer_id = timer_mgr:CreateTimer(1, function()
		cd_time = cd_time - 1

		if cd_time <= 0 then
			self:ClearCd()
			return true
		end

		self.btn_invite:SetText(string.format(config.words[4984], cd_time))
	end)
end

function MakeTeamInviteItem:ClearCd()
	if self.cd_timer_id then
		self.btn_invite:SetText(config.words[4983])
		self.btn_invite:SetTouchEnable(true)

		timer_mgr:DelTimer(self.cd_timer_id)
		self.cd_timer_id = nil
	end
end

function MakeTeamInviteItem:UpdateCareer(career)
	self.career = career
	local res = game.CareerRes[career] or game.CareerRes[1]
	self.img_career:SetSprite("ui_main", res)
end

return MakeTeamInviteItem
