local FriendGroupInviteTemplate = Class(game.UITemplate)

function FriendGroupInviteTemplate:_init(parent)
	self.parent = parent
    self.friend_data = game.FriendCtrl.instance:GetData()
end

function FriendGroupInviteTemplate:OpenViewCallBack()
    --接 受
    self._layout_objs["ok_btn"]:AddClickCallBack(function()
        if self.role_id then
            game.FriendCtrl.instance:CsFriendSysConfirmInGroup(self.group_id, self.role_id, 1)
        end
    end)

    --拒 绝
    self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        if self.role_id then
            game.FriendCtrl.instance:CsFriendSysConfirmInGroup(self.group_id, self.role_id, 0)
        end
    end)
end

function FriendGroupInviteTemplate:RefreshItem(idx)

    local list_data = self.parent:GetListData()
    local role_id = list_data.apply_list[idx].roleId
    local role_info = self.friend_data:GetRoleInfoById(role_id)

    self.group_id = list_data.id

    if role_info then
        self.role_id = role_id
        local career = role_info.unit.career
        self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. career)

        self._layout_objs["role_lv"]:SetText(role_info.unit.level)

        self._layout_objs["role_name"]:SetText(role_info.unit.name)
    end
end

return FriendGroupInviteTemplate