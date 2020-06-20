local SwornItemOptionView = Class(game.BaseView)

function SwornItemOptionView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "sworn_item_option_view"
    self.ctrl = ctrl

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None
end

function SwornItemOptionView:OpenViewCallBack(info, idx)
    self:Init(info, idx)
end

function SwornItemOptionView:Init(info, idx)
    self.list_option = self._layout_objs.list_option

    self.btn_check = self.list_option:GetChildAt(0)
    self.btn_check:AddClickCallBack(function()
        game.ViewOthersCtrl.instance:SendViewOthersInfo(game.GetViewRoleType.ViewOthers, info.role_id)
    end)

    self.btn_chat = self.list_option:GetChildAt(1)
    self.btn_chat:AddClickCallBack(function()
        local chat_info = {
            id = info.role_id,
            name = info.name,
            lv = info.lv,
            career = info.career,
            svr_num = 1,
        }
        game.ChatCtrl.instance:OpenFriendChatView(chat_info)
    end)

    self.btn_team = self.list_option:GetChildAt(2)
    self.btn_team:AddClickCallBack(function()
        game.MakeTeamCtrl.instance:DoTeamInviteJoin(info.role_id)
    end)

    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)

    self._layout_objs.group:SetPositionY(145 + (idx-1) * 110)
end

return SwornItemOptionView
