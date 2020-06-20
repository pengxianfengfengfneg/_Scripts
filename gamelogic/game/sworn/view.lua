local XXXView = Class(game.BaseView)

function XXXView:_init(ctrl)
    self._package_name = "ui_xxx"
    self._com_name = "xxx_view"
    self.ctrl = ctrl

    self._show_money = true

    self._view_level = game.UIViewLevel.First
    self._mask_type = game.UIMaskType.Full
end

function XXXView:OpenViewCallBack()
    self:Init()
    self:InitBg()
    self:RegisterAllEvents()
end

function XXXView:CloseViewCallBack()

end

function XXXView:RegisterAllEvents()
    local events = {
        
    }
    for k, v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function XXXView:Init()
    
end

function XXXView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[0])
end

return XXXView
