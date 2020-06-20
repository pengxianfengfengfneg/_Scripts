local SuggestFriendView = Class(game.BaseView)

function SuggestFriendView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "suggest_friend_view"
    self._view_level = game.UIViewLevel.Second
    self.ctrl = ctrl
end

function SuggestFriendView:OpenViewCallBack()
    self._layout_objs["cancel_btn"]:AddClickCallBack(function ()
        self:Close()
    end)

    self._layout_objs["ok_btn"]:AddClickCallBack(function ()
        self.ctrl:CsFriendSysApplyAdd()
    end)

end

return SuggestFriendView