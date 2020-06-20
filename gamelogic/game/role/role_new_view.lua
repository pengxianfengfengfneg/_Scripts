local RoleView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/role_base",
        item_class = "game/role/role_base_template",
    },
    {
        item_path = "list_page/role_attr",
        item_class = "game/role/role_attr_template",
    },
    {
        item_path = "list_page/role_coin",
        item_class = "game/role/role_coin_template",
    },
    {
        item_path = "list_page/role_title",
        item_class = "game/role/role_title_template",
    },
    {
        item_path = "list_page/role_other",
        item_class = "game/role/role_other_template",
    },
}

function RoleView:_init(ctrl)
    self._package_name = "ui_role"
    self._com_name = "role_new_view"

    self._show_money = true

    self.ctrl = ctrl
end

function RoleView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()

    self:InitPage()
end

function RoleView:Init(open_idx)
    local list_tab = self._layout_objs["list_tab"]

    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true, 116)

    self.page_controller = self:GetRoot():AddControllerCallback("c1", function(idx)
        self:OnClickPage(idx)
    end)

    local open_idx = open_idx or 1
    self.page_controller:SetSelectedIndexEx(open_idx-1)
end

function RoleView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[1651])
end

function RoleView:InitPage()
    for k,v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function RoleView:OnClickPage(idx)
    
end

return RoleView
