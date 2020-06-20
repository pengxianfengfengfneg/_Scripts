local FriendSettingView = Class(game.BaseView)

function FriendSettingView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "friend_setting_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function FriendSettingView:OpenViewCallBack()
    
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1743])

    self._layout_objs["btn_checkbox1"]:SetSelected(self.ctrl.show_friend_nick_name)
    self._layout_objs["btn_checkbox1"]:AddClickCallBack(function()
        
    end)

    self._layout_objs["btn_checkbox2"]:SetSelected(self.ctrl.show_captain_suggest)
    self._layout_objs["btn_checkbox2"]:AddClickCallBack(function()
    end)
end

function FriendSettingView:CloseViewCallBack()
    if self._layout_objs["btn_checkbox1"]:GetSelected() then
        self.ctrl.show_friend_nick_name = true
    else
        self.ctrl.show_friend_nick_name = false
    end

    if self._layout_objs["btn_checkbox2"]:GetSelected() then
        self.ctrl.show_captain_suggest = true
    else
        self.ctrl.show_captain_suggest = false
    end

    self:FireEvent(game.FriendEvent.RefreshNickName)
end

return FriendSettingView