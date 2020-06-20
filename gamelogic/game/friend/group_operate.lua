local GroupOperate = Class(game.UITemplate)

function GroupOperate:_init()
	self.ctrl = game.FriendCtrl.instance
	self.friend_data = self.ctrl:GetData()
end

function GroupOperate:OpenViewCallBack()
	--群组信息
    self._layout_objs["btn_info"]:AddClickCallBack(function ()
        game.FriendCtrl.instance:OpenGroupInfoView(self.select_info.group)
    end)

    --信息修改
    self._layout_objs["btn_edit"]:AddClickCallBack(function ()
        game.FriendCtrl.instance:OpenGroupInfoEditView(self.select_info.group)
    end)

    --邀请好友
    self._layout_objs["btn_invite_friend"]:AddClickCallBack(function ()
        game.FriendCtrl.instance:OpenGroupInviteFriendView(self.select_info.group.id)
    end)

    --删除群组
    self._layout_objs["btn_remove"]:AddClickCallBack(function ()

        local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], config.words[1762])
        msg_box:SetOkBtn(function()
            game.FriendCtrl.instance:CsFriendSysDismissGroup(self.select_info.group.id)
        end)
        msg_box:SetCancelBtn(function()
        end)
        msg_box:Open()
    end)

    --退出群组
    self._layout_objs["btn_quit"]:AddClickCallBack(function ()
        local msg_box = game.GameMsgCtrl.instance:CreateMsgBox(config.words[1660], config.words[1763])
        msg_box:SetOkBtn(function()
            game.FriendCtrl.instance:CsFriendSysLeaveGroup(self.select_info.group.id)
        end)
        msg_box:SetCancelBtn(function()
        end)
        msg_box:Open()
    end)

    --删除记录
    self._layout_objs["btn_del_info"]:AddClickCallBack(function ()

    end)

    --申请列表
    self._layout_objs["btn_apply"]:AddClickCallBack(function ()
        game.FriendCtrl.instance:OpenGroupInviteView(self.select_info.group)
    end)

    self._layout_objs["touch_com"]:AddClickCallBack(function()
    	self:GetRoot():SetVisible(false)
	end)
end

function GroupOperate:UpdateData(info)
	self.select_info = info

    self._layout_objs["group_name"]:SetText(info.group.name)

    local total_num, online_num = self.friend_data:GetGroupOnlineNum(info.group.id)
    self._layout_objs["online_num"]:SetText(tostring(online_num))

    --申请列表红点检测
    local apply_list = info.group.apply_list
    if #apply_list > 0 then
        self._layout_objs["apply_rp"]:SetVisible(true)
    else
        self._layout_objs["apply_rp"]:SetVisible(false)
    end

    local my_role_id = game.Scene.instance:GetMainRoleID()

    --系统群
    if info.group.type > 10 then
        self._layout_objs["btn_invite_friend"]:SetVisible(false)
        self._layout_objs["btn_remove"]:SetVisible(false)
        self._layout_objs["btn_apply"]:SetVisible(false)
        self._layout_objs["btn_edit"]:SetVisible(false)
        self._layout_objs["btn_quit"]:SetVisible(false)
    else
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
end

return GroupOperate