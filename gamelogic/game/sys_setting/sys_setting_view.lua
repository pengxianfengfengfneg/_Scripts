local SysSettingView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/setting_sys",
        item_class = "game/sys_setting/setting_sys_template",
    },
    {
        item_path = "list_page/setting_game",
        item_class = "game/sys_setting/setting_game_template",
    },
}
function SysSettingView:_init(ctrl)
    self._package_name = "ui_sys_setting"
    self._com_name = "sys_setting_view"

    self._show_money = true

    self.ctrl = ctrl
end

function SysSettingView:OpenViewCallBack(open_index)
    self:Init()
    self:InitPage()
    self:InitBg()

    self:RegisterAllEvents()
end

function SysSettingView:CloseViewCallBack()
    
end

function SysSettingView:RegisterAllEvents()
    local events = {
        
    }
    for _,v in ipairs(events) do
        self:BindEvent(v[1], v[2])
    end
end

function SysSettingView:Init()
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)
end

function SysSettingView:InitPage()
    for k,v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end

    local controller = self:GetRoot():GetController("tab")
    controller:SetSelectedIndexEx(0)
end

function SysSettingView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1670])
end

function SysSettingView:InitBtns()
    
end

return SysSettingView
