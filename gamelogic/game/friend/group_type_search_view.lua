local GroupTypeSearchView = Class(game.BaseView)

function GroupTypeSearchView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "group_type_search_view"
    self._view_level = game.UIViewLevel.Third
    self.ctrl = ctrl
end

function GroupTypeSearchView:OnEmptyClick()
    self:Close()
end

function GroupTypeSearchView:OpenViewCallBack()
    self._layout_objs["ok_btn"]:AddClickCallBack(function()
        if self.select_index then
            self.ctrl:CsFriendSysFindGroup("", self.select_index)
            self:Close()
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[1722])
        end
    end)

    for i = 1, 8 do
        self._layout_objs["btn_checkbox"..i]:SetSelected(false)
        self._layout_objs["btn_checkbox"..i]:AddClickCallBack(function()
            self.select_index = nil
            if self._layout_objs["btn_checkbox"..i]:GetSelected() then
                self:OnSelect(i)
            end
        end)
    end
end

function GroupTypeSearchView:CloseViewCallBack()

end

function GroupTypeSearchView:OnSelect(index)
    for i = 1, 8 do
        if i ~= index then
            self._layout_objs["btn_checkbox"..i]:SetSelected(false)
        end
    end

    self.select_index = index
end

return GroupTypeSearchView