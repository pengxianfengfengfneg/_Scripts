local FriendOnlineTipsView = Class(game.BaseView)

function FriendOnlineTipsView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_online_tips_view"
    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None
    self.ctrl = ctrl
end

function FriendOnlineTipsView:OpenViewCallBack(role_id)

    local visible = false
    self._layout_objs["pannel"]:SetVisible(false)
    
    local friend_data = self.ctrl:GetData()
    local role_info = friend_data:GetRoleInfoById(role_id)

    self._layout_objs["role_name"]:SetText(role_info.unit.name)
    self._layout_objs["relation_name"]:SetText(game.FriendRelationName[role_info.unit.stat])

    self._layout_objs["oper_btn"]:AddClickCallBack(function()
        visible = not visible
        self._layout_objs["pannel"]:SetVisible(visible)
    end)

    --邀请入队
    self._layout_objs["invite_btn"]:AddClickCallBack(function()
        game.MakeTeamCtrl.instance:DoTeamInviteJoin(role_id)
    end)

    --私聊
    self._layout_objs["chat_btn"]:AddClickCallBack(function()

        local main_role_vo = game.Scene.instance:GetMainRoleVo()

        local chat_info = {
            id = role_info.unit.id,
            name = role_info.unit.name,
            career = role_info.unit.career,
            gender = role_info.unit.gender,
            channel = game.ChatChannel.Private,
            lv = role_info.unit.level,
            svr_num = main_role_vo.server_num,
            stat = role_info.unit.stat,           --两人关系 参考 game.FriendRelationName
            offline = role_info.unit.offline,     --0表示在线
            vip = role_info.unit.vip,   
        }

        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end)

    local elapse_time = 0
    self.timer = global.TimerMgr:CreateTimer(1,
    function()

        if elapse_time == 8 then
            self:Close()
        end

        elapse_time = elapse_time + 1
    end)
end

function FriendOnlineTipsView:DelTimer()
    if self.timer then
        global.TimerMgr:DelTimer(self.timer)
        self.timer = nil
    end
end

function FriendOnlineTipsView:CloseViewCallBack()
    self:DelTimer()
end

return FriendOnlineTipsView