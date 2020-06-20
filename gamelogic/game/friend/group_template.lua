local GroupTemplate = Class(game.UITemplate)

function GroupTemplate:_init()
	self.friend_data = game.FriendCtrl.instance:GetData()
end

function GroupTemplate:OpenViewCallBack()

    self.select_info = nil
	self._layout_objs["n4/type_name"]:SetText(config.words[1718])

	self._layout_objs["n4/arrow_img"]:SetTouchDisabled(false)
	self._layout_objs["n4/arrow_img"]:AddClickCallBack(function()

    end)

    

    -- self._layout_objs["detail_bg"]:SetTouchDisabled(false)
    -- self._layout_objs["detail_bg"]:AddClickCallBack(function()
    -- end)

    self._layout_objs["group_search_btn"]:AddClickCallBack(function()
        game.FriendCtrl.instance:OpenGroupSearchView()
    end)

    self._layout_objs["group_create_btn"]:AddClickCallBack(function()
    	game.FriendCtrl.instance:OpenCreateGroupView()
    end)

    --群组信息
    -- self._layout_objs["btn_info"]:AddClickCallBack(function ()
    --     game.FriendCtrl.instance:OpenGroupInfoView(self.select_info.group)
    -- end)

    -- --信息修改
    -- self._layout_objs["btn_edit"]:AddClickCallBack(function ()
    --     game.FriendCtrl.instance:OpenGroupInfoEditView(self.select_info.group)
    -- end)

    -- --邀请好友
    -- self._layout_objs["btn_invite_friend"]:AddClickCallBack(function ()
    --     game.FriendCtrl.instance:OpenGroupInviteFriendView(self.select_info.group.id)
    -- end)

    -- --删除群组
    -- self._layout_objs["btn_remove"]:AddClickCallBack(function ()

    --     local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], config.words[1762])
    --     msg_box:SetOkBtn(function()
    --         game.FriendCtrl.instance:CsFriendSysDismissGroup(self.select_info.group.id)
    --     end)
    --     msg_box:SetCancelBtn(function()
    --     end)
    --     msg_box:Open()
    -- end)

    -- --退出群组
    -- self._layout_objs["btn_quit"]:AddClickCallBack(function ()
    --     local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], config.words[1763])
    --     msg_box:SetOkBtn(function()
    --         game.FriendCtrl.instance:CsFriendSysLeaveGroup(self.select_info.group.id)
    --     end)
    --     msg_box:SetCancelBtn(function()
    --     end)
    --     msg_box:Open()
    -- end)

    -- --删除记录
    -- self._layout_objs["btn_del_info"]:AddClickCallBack(function ()

    -- end)

    --申请列表
    -- self._layout_objs["btn_apply"]:AddClickCallBack(function ()
    --     game.FriendCtrl.instance:OpenGroupInviteView(self.select_info.group)
    -- end)

    self:BindEvent(game.FriendEvent.RefreshGroupList, function()

        if self.select_info then
            self:ShowDetailInfo(self.select_info)
        end

        self:UpdateList()
    end)

    self:BindEvent(game.FriendEvent.RemoveGroup, function()

        if self.select_info then
            self:ShowDetailInfo(self.select_info)
        end

        self:UpdateList()

        self.select_info = nil
    end)

    self:InitList()

    self:UpdateList()
end

function GroupTemplate:InitList()

	self.list = self._layout_objs["list"]
    self.ui_list = game.UIList.New(self.list)
    self.ui_list:SetVirtual(true)

    self.ui_list:SetCreateItemFunc(function(obj)

        local item = require("game/friend/group_item_template").New(self)
        item:SetVirtual(obj)
        item:Open()
        return item
    end)

    self.ui_list:SetRefreshItemFunc(function(item, idx)
        item:RefreshItem(idx)
    end)

    self.ui_list:AddClickItemCallback(function(item)
        -- self:OnClick(item)
    end)

    self.ui_list:SetItemNum(0)
end

function GroupTemplate:UpdateList()

    self.list_data = self.friend_data:GetGroupList()

    self.ui_list:SetItemNum(#self.list_data)
end

function GroupTemplate:OnClick(item)

    local group_data = item:GetData()
    local chat_info = {
        channel = game.ChatChannel.Group,
        group_info = group_data.group,
    }

    game.ChatCtrl.instance:OpenFriendChatView(chat_info)
end

function GroupTemplate:GetListData()
	return self.list_data
end

function GroupTemplate:ShowDetailInfo(info)

    self.select_info = info

    self._layout_objs["group_name"]:SetText(info.group.name)

    local total_num, online_num = self.friend_data:GetGroupOnlineNum(info.group.id)
    self._layout_objs["online_num"]:SetText(tostring(online_num))

    self._layout_objs["bot_pannel"]:SetVisible(true)

    --申请列表红点检测
    local apply_list = info.group.apply_list
    if #apply_list > 0 then
        self._layout_objs["apply_rp"]:SetVisible(true)
    else
        self._layout_objs["apply_rp"]:SetVisible(false)
    end

    local my_role_id = game.Scene.instance:GetMainRoleID()

    --是群主
    if my_role_id == info.group.owner then
        self._layout_objs["btn_quit"]:SetVisible(false)
        self._layout_objs["btn_apply"]:SetVisible(true)
        self._layout_objs["btn_edit"]:SetVisible(true)
        self._layout_objs["btn_remove"]:SetVisible(true)
    else
        self._layout_objs["btn_quit"]:SetVisible(true)
        self._layout_objs["btn_apply"]:SetVisible(false)
        self._layout_objs["btn_edit"]:SetVisible(false)
        self._layout_objs["btn_remove"]:SetVisible(false)
        self._layout_objs["apply_rp"]:SetVisible(false)
    end

end

return GroupTemplate