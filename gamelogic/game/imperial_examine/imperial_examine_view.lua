local ImperialExamineView = Class(game.BaseView)

local PageConfig = {
    {
        item_path = "list_page/examine_template",
        item_class = "game/imperial_examine/examine_template",
    },
    {
        item_path = "list_page/rank_template",
        item_class = "game/imperial_examine/rank_template",
    },
}

function ImperialExamineView:_init(ctrl)
    self._package_name = "ui_imperial_examine"
    self._com_name = "examine_view"
    self.ctrl = ctrl

    self._show_money = true

    self._mask_type = game.UIMaskType.Full
    self._view_level = game.UIViewLevel.First

    self:AddPackage("ui_daily_task")
end

function ImperialExamineView:_delete()
    
end

function ImperialExamineView:OpenViewCallBack(open_idx)
    self:Init(open_idx)
    self:InitBg()
end

function ImperialExamineView:CloseViewCallBack()

end

function ImperialExamineView:Init(open_idx)
    self.list_page = self._layout_objs["list_page"]
    self.list_page:SetHorizontalBarTop(true)
    self:InitView()
    self.ctrl_page = self:GetRoot():AddControllerCallback("ctrl_page", function(idx)
        self:OnClickPage(idx+1)
    end)

    open_idx = open_idx or 1
    self.ctrl_page:SetSelectedIndexEx(open_idx-1)
end

function ImperialExamineView:InitBg()
    self:GetBgTemplate("common_bg"):SetTitleName(config.words[5126])
end

function ImperialExamineView:InitView()
    for _, v in ipairs(PageConfig) do
        self:GetTemplate(v.item_class, v.item_path)
    end
end

function ImperialExamineView:OnClickPage(index)
    local page = self:GetTemplate(PageConfig[index].item_class, PageConfig[index].item_path)
    page:Active(true)
end

return ImperialExamineView
