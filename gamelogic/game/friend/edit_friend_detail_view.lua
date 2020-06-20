local EditFriendDetailView = Class(game.BaseView)

function EditFriendDetailView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "edit_friend_detail_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
end

function EditFriendDetailView:OpenViewCallBack(role_id)

    local role_nick_name = self.ctrl:GetData():GetFriendNickName(role_id)
    self._layout_objs["n2"]:SetText(role_nick_name)

	self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        self:Close()
    end)

	self._layout_objs["ok_btn"]:AddClickCallBack(function()
        local str = self._layout_objs["n2"]:GetText()
        self.ctrl:CsFriendSysSetNickName(role_id, str)
        self:Close()
    end)

    local role_info = self.ctrl:GetData():GetRoleInfoById(role_id)
    local str = string.format(config.words[1765], role_info.unit.name)
    self._layout_objs["n11"]:SetText(str)
end

return EditFriendDetailView