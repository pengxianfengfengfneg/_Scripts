local GroupInfoEditView = Class(game.BaseView)

function GroupInfoEditView:_init(ctrl)
	self._package_name = "ui_friend"
    self._com_name = "group_info_edit_view"
    self._view_level = game.UIViewLevel.Third

    self.ctrl = ctrl
    self.friend_data = self.ctrl:GetData()
end

function GroupInfoEditView:OpenViewCallBack(group_info)
    local main_role_id = game.Scene.instance:GetMainRoleID()
    self.is_group_owner = false--(main_role_id==group_info.owner)

    self.common_bg = self:GetBgTemplate("common_bg"):SetTitleName(config.words[1738])

    self.btn_cancel = self._layout_objs["cancel_btn"]
    self.btn_cancel:AddClickCallBack(function ()
        self:Close()
    end)

    self.btn_edit = self._layout_objs["edit_btn"]
    self.btn_edit:AddClickCallBack(function ()
        local title = self._layout_objs["input_title"]:GetText()
        local notice = self._layout_objs["input_notice"]:GetText()

        if title ~= "" then
            if notice ~= "" then
                if game.Utils.CheckMaskChatWords(title) then
                    game.GameMsgCtrl.instance:PushMsgCode(1413)
                else
                    if game.Utils.CheckMaskChatWords(notice) then
                        game.GameMsgCtrl.instance:PushMsgCode(1413)
                    else
                        game.FriendCtrl.instance:CsFriendSysChangeGroupInfo(group_info.id, title, notice)
                    end
                end
            else
                game.GameMsgCtrl.instance:PushMsg(config.words[1721])
            end
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[1720])
        end

        self:Close()
    end)

    self.btn_ok = self._layout_objs["btn_ok"]
    self.btn_ok:AddClickCallBack(function()
        self:Close()
    end)

    self.btn_cancel:SetVisible(self.is_group_owner)
    self.btn_edit:SetVisible(self.is_group_owner)
    self.btn_ok:SetVisible(not self.is_group_owner)

    self._layout_objs["input_title"]:SetTouchEnable(self.is_group_owner)
    self._layout_objs["input_notice"]:SetTouchEnable(self.is_group_owner)

    self._layout_objs["input_title"]:SetText(group_info.name)
    self._layout_objs["input_notice"]:SetText(group_info.announce)
    self._layout_objs["group_type_name"]:SetText(game.FriendGroupTypeName[group_info.type])
end

function GroupInfoEditView:CloseViewCallBack()

end

function GroupInfoEditView:OnEmptyClick()
    self:Close()
end

return GroupInfoEditView