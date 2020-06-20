local FriendInviteTemplate = Class(game.UITemplate)

function FriendInviteTemplate:_init(parent)
	self.parent = parent
    self.friend_data = game.FriendCtrl.instance:GetData()
end

function FriendInviteTemplate:OpenViewCallBack()
    --接 受
    self._layout_objs["ok_btn"]:AddClickCallBack(function()
        if self.role_info then
            game.FriendCtrl.instance:CsFriendSysConfirmAdd(self.role_info.unit.id, 1)
        end
    end)

    --拒 绝
    self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        if self.role_info then
            game.FriendCtrl.instance:CsFriendSysConfirmAdd(self.role_info.unit.id, 0)
        end
    end)
end

function FriendInviteTemplate:RefreshItem(idx)

    local list_data = self.parent:GetListData()
    local role_id = list_data[idx].roleId
    local role_info = self.friend_data:GetRoleInfoById(role_id)

    if role_info then
        self.role_info = role_info
        local career = role_info.unit.career
        self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. career)

        self._layout_objs["role_lv"]:SetText(role_info.unit.level)

        self._layout_objs["role_name"]:SetText(role_info.unit.name)
    end
end

return FriendInviteTemplate