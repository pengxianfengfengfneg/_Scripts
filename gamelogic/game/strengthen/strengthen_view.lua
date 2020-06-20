local StrengthenView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/stren_template",
        item_class = "game/strengthen/strengthen_template",
        type = 1,
    },
    {
        item_path = "list_page/break_template",
        item_class = "game/strengthen/strengthen_template",
        type = 2,
    },
}

local PackageList = {
    "ui_activity",
}

local BreakOpenLv = config.strengthen_info.break_open_lv or 1

function StrengthenView:_init(ctrl)
    self._package_name = "ui_strengthen"
    self._com_name = "strengthen_view"

    self._show_money = true
    self.ctrl = ctrl

    for k, v in ipairs(PackageList) do
        self:AddPackage(v)
    end
end

function StrengthenView:OpenViewCallBack(open_index)
    self:Init()
    self:InitPage()
    self:InitBg()
end

function StrengthenView:CloseViewCallBack()
    
end

function StrengthenView:Init()
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)

    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self:OnPageClick(idx+1)
    end)

    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    local last_index = #PageConfig

    if role_lv < BreakOpenLv then
        last_index = 1
    end

    self.list_page:SetLastPageCallBack(last_index, function() end)
end

function StrengthenView:InitPage()
    for k, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path, v.type)
    end

    local controller = self:GetRoot():GetController("ctrl_page")
    controller:SetSelectedIndexEx(0)
end

function StrengthenView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[6200]):AddBackFunc(handler(self, self.BackPage))
end

function StrengthenView:OnPageClick(idx)
    local role_lv = game.RoleCtrl.instance:GetRoleLevel()
    if idx == 2 then
        if role_lv < BreakOpenLv then
            game.GameMsgCtrl.instance:PushMsg(BreakOpenLv .. config.words[2101])
        end
    end
    self.page_idx = idx
end

function StrengthenView:BackPage()
    local cfg = PageConfig[self.page_idx]
    local page = self:GetTemplate(cfg.item_class, cfg.item_path, cfg.type)

    if not page:BackPage() then
        self:Close()
    end
end

return StrengthenView
