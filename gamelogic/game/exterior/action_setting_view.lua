local ActionSettingView = Class(game.BaseView)

function ActionSettingView:_init(ctrl)
    self._package_name = "ui_exterior"
    self._com_name = "mount_setting_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function ActionSettingView:OnEmptyClick()
    self:Close()
end

function ActionSettingView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:LoadSetting()
end

function ActionSettingView:CloseViewCallBack()
    self:SaveSetting()
end

function ActionSettingView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5520])
end

function ActionSettingView:Init()
    self._layout_objs["txt_content"]:SetText(config.words[5513])
    self._layout_objs["txt_forever"]:SetText(config.words[5514])
    self._layout_objs["txt_not_active"]:SetText(config.words[5515])
    self._layout_objs["txt_expire"]:SetText(config.words[5516])
end

function ActionSettingView:SaveSetting()
    local val = 0
    local ExteriorSettingKey = self.ctrl:GetExteriorSettingKey()

    if self._layout_objs["btn_forever"]:GetSelected() then
        val = val | ExteriorSettingKey.Forever
    end
    if self._layout_objs["btn_not_active"]:GetSelected() then
        val = val | ExteriorSettingKey.NotActive
    end
    if self._layout_objs["btn_expire"]:GetSelected() then
        val = val | ExteriorSettingKey.Expire
    end
    if val ~= self.ctrl:GetActionSettingValue() then
        self.ctrl:SetActionSettingValue(val)
    end
end

function ActionSettingView:LoadSetting()
    local val = self.ctrl:GetActionSettingValue()
    local ExteriorSettingKey = self.ctrl:GetExteriorSettingKey()

    self._layout_objs["btn_forever"]:SetSelected(val & ExteriorSettingKey.Forever > 0)
    self._layout_objs["btn_not_active"]:SetSelected(val & ExteriorSettingKey.NotActive > 0)
    self._layout_objs["btn_expire"]:SetSelected(val & ExteriorSettingKey.Expire > 0)
end

return ActionSettingView
