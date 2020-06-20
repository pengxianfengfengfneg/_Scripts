local FriendGroupInfoTemplate = Class(game.UITemplate)

function FriendGroupInfoTemplate:_init(parent)
	self.parent = parent
    self.friend_data = game.FriendCtrl.instance:GetData()
    self.my_role_id = game.Scene.instance:GetMainRoleID()
end

function FriendGroupInfoTemplate:OpenViewCallBack()

    --删除成员
    self._layout_objs["remove_btn"]:AddClickCallBack(function()
        game.FriendCtrl.instance:CsFriendSysDelGroupMem(self.group_id, self.role_id)
    end)
end

function FriendGroupInfoTemplate:RefreshItem(idx)

    local list_data = self.parent:GetListData()
    local role_id = list_data[idx].roleId
    local role_info = self.friend_data:GetRoleInfoById(role_id)
    local group_data = self.parent:GetGroupData()

    if role_info then
        self.role_id = role_id
        self.group_id = group_data.id
        local career = role_info.unit.career
        self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. career)

        self._layout_objs["role_lv"]:SetText(role_info.unit.level)

        self._layout_objs["role_name"]:SetText(role_info.unit.name)
    end

    self._layout_objs["remove_btn"]:SetVisible(false)

    if role_id == group_data.owner then
        self._layout_objs["invite_role_name"]:SetText(config.words[1736])
    else
        self._layout_objs["invite_role_name"]:SetText(config.words[1737])

        if self.my_role_id == group_data.owner then
            self._layout_objs["remove_btn"]:SetVisible(true)
        end
    end
end

return FriendGroupInfoTemplate