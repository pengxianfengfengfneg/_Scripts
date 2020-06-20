local FriendCreateBlockView = Class(game.BaseView)

function FriendCreateBlockView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "create_group_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
end

function FriendCreateBlockView:OpenViewCallBack()

    self._layout_objs["create_btn"]:AddClickCallBack(function()

        local str = self._layout_objs["n2"]:GetText()
        if str ~= "" then
            if game.Utils.CheckMaskChatWords(str) then
                game.GameMsgCtrl.instance:PushMsgCode(1413)
            else
                self.ctrl:CsFriendSysCreateBlock(str)
                self:Close()
            end
        end
    end)

    self._layout_objs["cancel_btn"]:AddClickCallBack(function()
        self:Close()
    end)
end


return FriendCreateBlockView