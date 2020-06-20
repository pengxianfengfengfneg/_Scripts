local GroupInviteFriendTemplate = Class(game.UITemplate)

function GroupInviteFriendTemplate:_init(parent)
	self.parent = parent
    self.friend_data = game.FriendCtrl.instance:GetData()
end

function GroupInviteFriendTemplate:OpenViewCallBack()
	self.head_icon = self:GetIconTemplate("head_icon")
	self.icon_data = {
        icon = self.icon_id,
        frame = 0,
        lock = false,   
    }
	self._layout_objs["n13"]:AddClickCallBack(function()
		local group_id = self.parent:GetGroupId()
		game.FriendCtrl.instance:CsFriendSysInviteInGroup(group_id, self.role_id)
    end)
end

function GroupInviteFriendTemplate:RefreshItem(idx)
	local role_list = self.parent:GetListData()
	local role_id = role_list[idx]
	local role_info = self.friend_data:GetRoleInfoById(role_id)
	if role_info then

		self.role_id = role_id

		local career = role_info.unit.career
	    self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. career)

	    self._layout_objs["n3"]:SetText(role_info.unit.level)

	    self._layout_objs["role_name"]:SetText(role_info.unit.name)

		if role_info.unit.offline == 0 then
			self.head_icon:SetGray(false)
		else
			self.head_icon:SetGray(true)
		end

		self.icon_data.icon = role_info.unit.icon
    	self.head_icon:UpdateData(self.icon_data)
	end
end

return GroupInviteFriendTemplate