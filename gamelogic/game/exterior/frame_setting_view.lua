local FrameSettingView = Class(game.BaseView)

function FrameSettingView:_init(ctrl)
    self._package_name = "ui_exterior"
    self._com_name = "mount_setting_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function FrameSettingView:OnEmptyClick()
    self:Close()
end

function FrameSettingView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:LoadSetting()
end

function FrameSettingView:CloseViewCallBack()
    self:SaveSetting()
end

function FrameSettingView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5520])
end

function FrameSettingView:Init()
    self._layout_objs["txt_content"]:SetText(config.words[5513])
    self._layout_objs["txt_forever"]:SetText(config.words[5514])
    self._layout_objs["txt_not_active"]:SetText(config.words[5515])
    self._layout_objs["txt_expire"]:SetText(config.words[5516])
end

function FrameSettingView:SaveSetting()
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
    if val ~= self.ctrl:GetFrameSettingValue() then
        self.ctrl:SetFrameSettingValue(val)
    end
end

function FrameSettingView:LoadSetting()
    local val = self.ctrl:GetFrameSettingValue()
    local ExteriorSettingKey = self.ctrl:GetExteriorSettingKey()

    self._layout_objs["btn_forever"]:SetSelected(val & ExteriorSettingKey.Forever > 0)
    self._layout_objs["btn_not_active"]:SetSelected(val & ExteriorSettingKey.NotActive > 0)
    self._layout_objs["btn_expire"]:SetSelected(val & ExteriorSettingKey.Expire > 0)
end

return FrameSettingView
