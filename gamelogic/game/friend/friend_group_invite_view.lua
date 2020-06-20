local FriendGroupInviteView = Class(game.BaseView)

function FriendGroupInviteView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_group_invite_view"
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
    self.friend_data = self.ctrl:GetData()
end

function FriendGroupInviteView:OpenViewCallBack(group_info)

    self.group_info = group_info

	self._layout_objs["common_bg/txt_title"]:SetText(config.words[1714])

	self._layout_objs["common_bg/btn_back"]:AddClickCallBack(function()
		self:Close()
    end)

	self._layout_objs["common_bg/btn_close"]:AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs["clear_btn"]:AddClickCallBack(function()
        self:ClearList()
    end)

    self._layout_objs["recv_btn"]:AddClickCallBack(function()
        self:RecvList()
    end)

    self:BindEvent(game.FriendEvent.RefreshGroupList, function()
        self:UpdateList()
    end)

    self:InitList()

    self:UpdateList()
end

function FriendGroupInviteView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FriendGroupInviteView:InitList()

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/friend_group_invite_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(0)
end

function FriendGroupInviteView:UpdateList()

    local group_id = self.group_info.id
    self.group_info = self.friend_data:GetGroupData(group_id)

    local num = #self.group_info.apply_list
    self.ui_list:SetItemNum(num)
end

function FriendGroupInviteView:GetListData()
    return self.group_info
end

function FriendGroupInviteView:ClearList()

    if self.group_info.apply_list then
        for k, v in pairs(self.group_info.apply_list) do
            local role_id = v.roleId
            game.FriendCtrl.instance:CsFriendSysConfirmInGroup(self.group_info.id, 0, 0)
        end
    end
end

function FriendGroupInviteView:RecvList()

    if self.group_info.apply_list then
        for k, v in pairs(self.group_info.apply_list) do
            local role_id = v.roleId
            game.FriendCtrl.instance:CsFriendSysConfirmInGroup(self.group_info.id, 0, 1)
        end
    end
end


return FriendGroupInviteView