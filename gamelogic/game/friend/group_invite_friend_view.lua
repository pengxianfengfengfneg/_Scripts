local GroupInviteFriendView = Class(game.BaseView)

function GroupInviteFriendView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "group_invite_friend_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
end

function GroupInviteFriendView:OpenViewCallBack(group_id)
    
    self.group_id = group_id

    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1719])

    local friend_data = self.ctrl:GetData()
    local role_list = friend_data:GetGroupInviteList(group_id)
    self.role_list = role_list

    self.list = self._layout_objs["list"]
    self.ui_friend_list = game.UIList.New(self.list)
    self.ui_friend_list:SetVirtual(true)

    self.ui_friend_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/group_invite_friend_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_friend_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_friend_list:AddClickItemCallback(function(item)
    end)

    self.ui_friend_list:SetItemNum(#role_list)
end

function GroupInviteFriendView:GetListData()
    return self.role_list
end

function GroupInviteFriendView:CloseViewCallBack()
    if self.ui_friend_list then
        self.ui_friend_list:DeleteMe()
        self.ui_friend_list = nil
    end
end

function GroupInviteFriendView:GetGroupId()
    return self.group_id
end

return GroupInviteFriendView