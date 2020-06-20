local FashionSettingView = Class(game.BaseView)

function FashionSettingView:_init(ctrl)
    self._package_name = "ui_exterior"
    self._com_name = "mount_setting_view"
    self.ctrl = ctrl

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second
end

function FashionSettingView:OnEmptyClick()
    self:Close()
end

function FashionSettingView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:LoadSetting()
end

function FashionSettingView:CloseViewCallBack()
    self:SaveSetting()
end

function FashionSettingView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5520])
end

function FashionSettingView:Init()
    self._layout_objs["txt_content"]:SetText(config.words[5513])
    self._layout_objs["txt_forever"]:SetText(config.words[5514])
    self._layout_objs["txt_not_active"]:SetText(config.words[5515])
    self._layout_objs["txt_expire"]:SetText(config.words[5516])
end

function FashionSettingView:SaveSetting()
    local val = 0
    local _FashionSettingKey = self.ctrl:GetFashionSettingKey()

    if self._layout_objs["btn_forever"]:GetSelected() then
        val = val | _FashionSettingKey.Forever
    end
    if self._layout_objs["btn_not_active"]:GetSelected() then
        val = val | _FashionSettingKey.NotActive
    end
    if self._layout_objs["btn_expire"]:GetSelected() then
        val = val | _FashionSettingKey.Expire
    end
    if val ~= self.ctrl:GetFashionSettingValue() then
        self.ctrl:SetFashionSettingValue(val)
    end
end

function FashionSettingView:LoadSetting()
    local val = self.ctrl:GetFashionSettingValue()
    local _FashionSettingKey = self.ctrl:GetFashionSettingKey()

    self._layout_objs["btn_forever"]:SetSelected(val & _FashionSettingKey.Forever > 0)
    self._layout_objs["btn_not_active"]:SetSelected(val & _FashionSettingKey.NotActive > 0)
    self._layout_objs["btn_expire"]:SetSelected(val & _FashionSettingKey.Expire > 0)
end

return FashionSettingView
