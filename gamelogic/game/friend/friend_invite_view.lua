local FriendInviteView = Class(game.BaseView)

function FriendInviteView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_invite_view"
    self._view_level = game.UIViewLevel.Second
    self._show_money = true

    self.ctrl = ctrl
    self.friend_data = self.ctrl:GetData()
end

function FriendInviteView:OpenViewCallBack()

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

    self:BindEvent(game.FriendEvent.RefreshRoleIdList, function()
        self:UpdateList()
    end)

    self:InitList()

    self:UpdateList()
end

function FriendInviteView:CloseViewCallBack()
    if self.ui_list then
        self.ui_list:DeleteMe()
        self.ui_list = nil
    end
end

function FriendInviteView:InitList()

    self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/friend_invite_template").New(self)
        item:SetVirtual(obj)
        item:Open()

        return item
    end)

    self.ui_list:SetRefreshItemFunc(function (item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:SetItemNum(0)
end

function FriendInviteView:UpdateList()
    
    self.apply_list = self.friend_data:GetApplyList()
    local num = #self.apply_list
    self.ui_list:SetItemNum(num)
end

function FriendInviteView:GetListData()
    return self.apply_list
end

function FriendInviteView:ClearList()

    if self.apply_list then
        for k, v in pairs(self.apply_list) do
            local role_id = v.roleId
            game.FriendCtrl.instance:CsFriendSysConfirmAdd(0, 0)
        end
    end
end

function FriendInviteView:RecvList()

    if self.apply_list then
        for k, v in pairs(self.apply_list) do
            local role_id = v.roleId
            game.FriendCtrl.instance:CsFriendSysConfirmAdd(0, 1)
        end
    end
end


return FriendInviteView