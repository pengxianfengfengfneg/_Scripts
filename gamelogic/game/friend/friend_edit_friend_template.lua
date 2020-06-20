local FriendEditFriendTemplate = Class(game.UITemplate)

function FriendEditFriendTemplate:_init(parent)
	self.parent = parent
    self.friend_data = game.FriendCtrl.instance:GetData()
end

function FriendEditFriendTemplate:OpenViewCallBack()

end

function FriendEditFriendTemplate:RefreshItem(idx)

    local list_data = self.parent:GetFriendListData()
    local role_id = list_data[idx].roleId
    local role_info = self.friend_data:GetRoleInfoById(role_id)

    if role_info then
        self.role_info = role_info
        local career = role_info.unit.career
        self._layout_objs["career_img"]:SetSprite("ui_common", "career" .. career)

        self._layout_objs["role_lv"]:SetText(role_info.unit.level)

        self._layout_objs["role_name"]:SetText(role_info.unit.name)

        local block_name = self.friend_data:GetBlockNameByRoleId(role_id)
        self._layout_objs["txt2"]:SetText(block_name)

        self._layout_objs["txt1"]:SetText(config.words[1700])
    end
end

function FriendEditFriendTemplate:SetSelect()

    if self.is_visible then
        self._layout_objs["select_img"]:SetVisible(false)
        self.is_visible = false
    else
        self._layout_objs["select_img"]:SetVisible(true)
        self.is_visible = true
    end
end

function FriendEditFriendTemplate:GetVisible()
    return self.is_visible
end

function FriendEditFriendTemplate:GetRoleId()
    return self.role_info.unit.id
end

function FriendEditFriendTemplate:Reset()
    self._layout_objs["select_img"]:SetVisible(false)
    self.is_visible = false
end

return FriendEditFriendTemplate