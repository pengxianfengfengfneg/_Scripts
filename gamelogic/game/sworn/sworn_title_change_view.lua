local SwornTitleChangeView = Class(game.BaseView)

function SwornTitleChangeView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "title_change_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.None
end

function SwornTitleChangeView:OpenViewCallBack()
    self:Init()
end

function SwornTitleChangeView:Init()
    self.btn_upgrade = self._layout_objs.btn_upgrade
    self.btn_upgrade:AddClickCallBack(function()
        local sworn_info = self.ctrl:GetSwornInfo()
        local group_name = sworn_info.group_name
        if group_name ~= "" then
            self.ctrl:OpenSwornTitleUpgradeView()
        else
            game.GameMsgCtrl.instance:PushMsg(config.words[6242])
        end
        self:Close()
    end)

    self.btn_modify = self._layout_objs.btn_modify
    self.btn_modify:AddClickCallBack(function()
        self:TalkToNpc(config.sworn_base.npc1)
        self.ctrl:CloseSwornView()
        self.ctrl:CloseHomeView()
        self:Close()
    end)

    self:GetRoot():AddClickCallBack(handler(self, self.OnEmptyClick))
end

function SwornTitleChangeView:OnEmptyClick()
    self:Close()
end

function SwornTitleChangeView:TalkToNpc(npc_id)
    local scene = game.Scene.instance
    local main_role = scene and scene:GetMainRole()
    if main_role then
        main_role:GetOperateMgr():DoGoToTalkNpc(npc_id)
    end
end

return SwornTitleChangeView
