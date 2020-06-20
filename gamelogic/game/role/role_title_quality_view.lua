local RoleTitleQualityView = Class(game.BaseView)

function RoleTitleQualityView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_title_quality_view"

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.Second

    self.ctrl = ctrl
    self.data = ctrl.role_data
end

function RoleTitleQualityView:OpenViewCallBack()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1682])
    local control = self:GetRoot():AddControllerCallback("g1", function(idx)
        self:Refresh(idx + 1)
    end)
    control:SetSelectedIndexEx(0)
end

function RoleTitleQualityView:CloseViewCallBack()
    self:SaveValue()
end

function RoleTitleQualityView:Refresh(idx)
    self:SaveValue()

    self.cur_idx = idx
    local val = self.data:GetTitleShow(idx)
    for i=1,6 do
        self._layout_objs["c" .. i]:SetSelected(val & (1 << i) > 0)
    end
end

function RoleTitleQualityView:SaveValue()
    if self.cur_idx then
        local val = 0
        for i=1,6 do
            if self._layout_objs["c" .. i]:GetSelected() then
                val = val + (1 << i)
            end
        end
        self.data:SetTitleShow(self.cur_idx, val)
    end
end

return RoleTitleQualityView
