local SwornTitleUpgradeView = Class(game.BaseView)

function SwornTitleUpgradeView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "title_upgrade_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Third
    self._mask_type = game.UIMaskType.Full
end

function SwornTitleUpgradeView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function SwornTitleUpgradeView:CloseViewCallBack()

end

function SwornTitleUpgradeView:RegisterAllEvents()
    local events = {
        {game.SwornEvent.UpdateQuality, handler(self, self.UpdateTitleInfo)},
        {game.SwornEvent.UpdateSwornValue, handler(self, self.SetSwornValueText)},
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SwornTitleUpgradeView:Init()
    self.txt_cur_name = self._layout_objs.txt_cur_name 
    self.txt_next_name = self._layout_objs.txt_next_name 
    self.txt_cost = self._layout_objs.txt_cost
    self.txt_sworn_value = self._layout_objs.txt_sworn_value

    self.btn_cancel = self._layout_objs.btn_cancel
    self.btn_cancel:AddClickCallBack(function()
        self:Close()
    end)

    self.btn_ok = self._layout_objs.btn_ok
    self.btn_ok:AddClickCallBack(function()
        self.ctrl:SendSwornUpQuality()
    end)

    self:UpdateTitleInfo()
end

function SwornTitleUpgradeView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6283])
end

function SwornTitleUpgradeView:UpdateTitleInfo()
    if self.ctrl:HaveSwornGroup() then
        local sworn_info = self.ctrl:GetSwornInfo()
        self.txt_cur_name:SetText(self:GetGroupColorName(sworn_info.group_name, sworn_info.quality))

        if self:CanUpgrade(sworn_info.quality+1) then
            self.txt_next_name:SetText(self:GetGroupColorName(sworn_info.group_name, sworn_info.quality+1))
        else
            self.txt_next_name:SetText(config.words[6270])
        end

        self.txt_cost:SetText(string.format(config.words[6284], config.sworn_quality[sworn_info.quality].sworn_value_need))
        self:SetSwornValueText(sworn_info.sworn_value)
    end
end

function SwornTitleUpgradeView:GetGroupColorName(group_name, quality)
    local color = game.TitleColor[quality]
    return string.format("[color=#%s]%s[/color]", color, group_name)
end

function SwornTitleUpgradeView:CanUpgrade(quality)
    return config.sworn_quality[quality] ~= nil
end

function SwornTitleUpgradeView:SetSwornValueText(sworn_value)
    self.txt_sworn_value:SetText(string.format(config.words[6285], sworn_value))
end

return SwornTitleUpgradeView
