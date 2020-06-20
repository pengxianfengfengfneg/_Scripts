local SwornValueView = Class(game.BaseView)

function SwornValueView:_init(ctrl)
    self._package_name = "ui_sworn"
    self._com_name = "sworn_value_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.Fouth
    self._mask_type = game.UIMaskType.Full
end

function SwornValueView:OpenViewCallBack()
    self:Init()
end

function SwornValueView:Init()
    local daily_value = config.sworn_base.daily_sworn_value
    local sworn_quality_cfg = config.sworn_quality
    local quality_name = sworn_quality_cfg[#sworn_quality_cfg].name
    local txt = string.format(config.words[6281], daily_value, quality_name)

    local exp_add_list = {}
    for k, v in pairs(config.sworn_exp_add) do
        table.insert(exp_add_list, v)
    end
    table.sort(exp_add_list, function(m, n)
        return m.sworn_value < n.sworn_value
    end)
    for k, v in ipairs(exp_add_list) do
        txt = txt .. string.format(config.words[6282], v.sworn_value, v.exp_add)
    end

    self._layout_objs.n2:SetText(txt)

    self:GetRoot():AddClickCallBack(function()
        self:Close()
    end)
end

return SwornValueView
