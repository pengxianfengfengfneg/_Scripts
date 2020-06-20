local SongliaoWarPrepareView = Class(game.BaseView)

function SongliaoWarPrepareView:_init(ctrl)
	self._package_name = "ui_songliao_war"
    self._com_name = "songliao_prepare_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.None
    self._ui_order = game.UIZOrder.UIZOrder_Main_UI+1
    self._view_level = game.UIViewLevel.Standalone
end

function SongliaoWarPrepareView:OpenViewCallBack()

	self:BindEvent(game.SongliaoWarEvent.UpdateRoleNum, function(data)
        self:UpdateInfo(data)
    end)

    local data = self.ctrl:GetData()
    local t = {}
    t.role_num = data:GetPrepareRoleNum()

    self:UpdateInfo(t)
end

function SongliaoWarPrepareView:UpdateInfo(data)
	local role_num = data.role_num
	local cfg_num = config.sys_config["dynasty_war_match_num"].value
	self._layout_objs["n1"]:SetText(string.format(config.words[4101], role_num, cfg_num))
end

return SongliaoWarPrepareView